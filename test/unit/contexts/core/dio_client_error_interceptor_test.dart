import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mocktail/mocktail.dart';

import 'dio_test_doubles.dart';

/// A rejected request must carry the user-facing session-expired signal.
final TypeMatcher<DioException> _isSessionExpiredCancellation =
    isA<DioException>()
    .having(
      (error) => error.error,
      'error',
      'Session expired. Please sign in again.',
    )
    .having((error) => error.type, 'type', DioExceptionType.cancel);

/// A request the interceptor deliberately left alone keeps dio's own error.
final TypeMatcher<DioException> _isBadResponse = isA<DioException>()
    .having((error) => error.type, 'type', DioExceptionType.badResponse)
    .having((error) => error.response?.statusCode, 'statusCode', isNotNull);

void main() {
  late MockTokenLocalStorage tokenStorage;
  late DioClient dioClient;
  late RecordingHttpClientAdapter adapter;
  late FakeHttpClient fakeHttpClient;
  late DioResponder responder;
  late void Function() restoreDotEnv;

  // Stands in for the encrypted vault so a successful refresh really changes
  // what the next `getAccessToken()` returns.
  String? storedAccessToken;
  String? storedRefreshToken;
  String? storedUserId;
  String? storedEmail;

  setUpAll(() {
    // `DioClient` reads `ApiConstants.baseUrl` in its constructor, which is a
    // dotenv-backed getter. Swap in an in-memory stub so no `.env` file, asset
    // bundle or real configuration is read.
    restoreDotEnv = installFakeDotEnv();
  });

  tearDownAll(() {
    restoreDotEnv();
  });

  setUp(() {
    AuthSession().setAuthenticated(false);

    storedAccessToken = null;
    storedRefreshToken = null;
    storedUserId = null;
    storedEmail = null;

    tokenStorage = MockTokenLocalStorage();
    when(() => tokenStorage.getAccessToken())
        .thenAnswer((_) async => storedAccessToken);
    when(() => tokenStorage.getRefreshToken())
        .thenAnswer((_) async => storedRefreshToken);
    when(
      () => tokenStorage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((invocation) async {
      storedAccessToken = invocation.namedArguments[#accessToken] as String;
      storedRefreshToken = invocation.namedArguments[#refreshToken] as String;
    });
    when(
      () => tokenStorage.saveUser(
        userId: any(named: 'userId'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((invocation) async {
      storedUserId = invocation.namedArguments[#userId] as String;
      storedEmail = invocation.namedArguments[#email] as String;
    });
    when(() => tokenStorage.clearAll()).thenAnswer((_) async {
      storedAccessToken = null;
      storedRefreshToken = null;
      storedUserId = null;
      storedEmail = null;
    });

    // Default: the backend accepts the refresh and answers with a new identity.
    fakeHttpClient = FakeHttpClient(
      const CannedHttpResponse(
        statusCode: 200,
        body: '{"id":"user-1","email":"user@example.test",'
            '"token":"fresh-access-token","refreshToken":"fresh-refresh-token"}',
      ),
    );

    responder = (options, index) => jsonResponseBody(<String, dynamic>{
          'ok': true,
        });

    dioClient = DioClient(tokenStorage: tokenStorage);
    adapter = RecordingHttpClientAdapter(
      (options, index) => responder(options, index),
    );
    dioClient.client.httpClientAdapter = adapter;
  });

  tearDown(() {
    dioClient.client.close(force: true);
    AuthSession().setAuthenticated(false);
  });

  group('DioClient error interceptor', () {
    test(
      'should retry the original request with the new bearer token when the '
      'session refresh succeeds',
      () async {
        // Arrange
        const protectedPath = '${ApiConstants.apiPrefix}/analytics/dashboard';
        storedAccessToken = 'expired-access-token';
        storedRefreshToken = 'stored-refresh-token';

        responder = (options, index) => index == 0
            ? jsonResponseBody(
                <String, dynamic>{'message': 'Unauthorized'},
                statusCode: 401,
              )
            : jsonResponseBody(<String, dynamic>{'devices': <String>[]});

        // Act
        final response = await withFakeHttpClient(
          fakeHttpClient,
          () => dioClient.client.get<Map<String, dynamic>>(protectedPath),
        );

        // Assert — the refreshed identity is persisted.
        expect(storedAccessToken, 'fresh-access-token');
        expect(storedRefreshToken, 'fresh-refresh-token');
        expect(storedUserId, 'user-1');
        expect(storedEmail, 'user@example.test');
        verify(
          () => tokenStorage.saveTokens(
            accessToken: 'fresh-access-token',
            refreshToken: 'fresh-refresh-token',
          ),
        ).called(1);

        // Assert — the session is treated as authenticated again.
        expect(AuthSession().isAuthenticated, isTrue);

        // Assert — the retry carries the new token and is loop-guarded.
        expect(adapter.requests, hasLength(2));
        expect(adapter.requests.first.path, protectedPath);
        expect(
          adapter.requests.first.headers['Authorization'],
          'Bearer expired-access-token',
        );
        expect(
          adapter.lastRequest.headers['Authorization'],
          'Bearer fresh-access-token',
        );
        expect(adapter.lastRequest.extra['_retry_after_refresh'], isTrue);

        // Assert — the caller sees the retried, successful payload.
        expect(response.data, <String, dynamic>{'devices': <String>[]});
        expect(response.statusCode, 200);
      },
    );

    test(
      'should post the stored refresh token to the auth refresh endpoint when '
      'renewing the session',
      () async {
        // Arrange
        storedAccessToken = 'expired-access-token';
        storedRefreshToken = 'stored-refresh-token';
        responder = (options, index) => index == 0
            ? jsonResponseBody(
                <String, dynamic>{'message': 'Unauthorized'},
                statusCode: 401,
              )
            : jsonResponseBody(<String, dynamic>{'devices': <String>[]});

        // Act
        await withFakeHttpClient(
          fakeHttpClient,
          () => dioClient.client.get<Map<String, dynamic>>(
            '${ApiConstants.apiPrefix}/alerts',
          ),
        );

        // Assert
        expect(fakeHttpClient.exchanges, hasLength(1));
        final refreshExchange = fakeHttpClient.exchanges.single;
        expect(refreshExchange.method, 'POST');
        expect(refreshExchange.uri.path, '${ApiConstants.authBase}/refresh');
        expect(
          refreshExchange.bodyAsString,
          '{"refreshToken":"stored-refresh-token"}',
        );
      },
    );

    test(
      'should clear the session and reject the request when the refresh is '
      'refused by the backend',
      () async {
        // Arrange
        storedAccessToken = 'expired-access-token';
        storedRefreshToken = 'stored-refresh-token';
        AuthSession().setAuthenticated(true);

        fakeHttpClient = FakeHttpClient(
          const CannedHttpResponse(
            statusCode: 401,
            body: '{"message":"Refresh token revoked"}',
          ),
        );
        responder = (options, index) => jsonResponseBody(
              <String, dynamic>{'message': 'Unauthorized'},
              statusCode: 401,
            );

        // Act
        await expectLater(
          withFakeHttpClient(
            fakeHttpClient,
            () => dioClient.client.get<Map<String, dynamic>>(
              '${ApiConstants.apiPrefix}/alerts',
            ),
          ),
          throwsA(_isSessionExpiredCancellation),
        );

        // Assert
        verify(() => tokenStorage.clearAll()).called(1);
        expect(storedAccessToken, isNull);
        expect(storedRefreshToken, isNull);
        expect(AuthSession().isAuthenticated, isFalse);
        verifyNever(() => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ));
        expect(adapter.requests, hasLength(1));
      },
    );

    test(
      'should clear the session and reject the request when no refresh token '
      'is stored',
      () async {
        // Arrange
        storedAccessToken = 'expired-access-token';
        storedRefreshToken = null;
        AuthSession().setAuthenticated(true);

        responder = (options, index) => jsonResponseBody(
              <String, dynamic>{'message': 'Unauthorized'},
              statusCode: 401,
            );

        // Act
        await expectLater(
          withFakeHttpClient(
            fakeHttpClient,
            () => dioClient.client.get<Map<String, dynamic>>(
              '${ApiConstants.apiPrefix}/alerts',
            ),
          ),
          throwsA(_isSessionExpiredCancellation),
        );

        // Assert — no refresh round trip is even attempted.
        verify(() => tokenStorage.clearAll()).called(1);
        verify(() => tokenStorage.getRefreshToken()).called(1);
        expect(fakeHttpClient.exchanges, isEmpty);
        expect(AuthSession().isAuthenticated, isFalse);
        expect(adapter.requests, hasLength(1));
      },
    );

    test(
      'should clear the session and reject the request when the stored '
      'refresh token is empty',
      () async {
        // Arrange
        storedAccessToken = 'expired-access-token';
        storedRefreshToken = '';
        AuthSession().setAuthenticated(true);

        responder = (options, index) => jsonResponseBody(
              <String, dynamic>{'message': 'Unauthorized'},
              statusCode: 401,
            );

        // Act
        await expectLater(
          withFakeHttpClient(
            fakeHttpClient,
            () => dioClient.client.get<Map<String, dynamic>>(
              '${ApiConstants.apiPrefix}/alerts',
            ),
          ),
          throwsA(_isSessionExpiredCancellation),
        );

        // Assert
        verify(() => tokenStorage.clearAll()).called(1);
        expect(fakeHttpClient.exchanges, isEmpty);
        expect(AuthSession().isAuthenticated, isFalse);
      },
    );

    test(
      'should invalidate the session without refreshing again when the '
      'request already carries the post-refresh marker',
      () async {
        // Arrange — this is the retry of an already retried request.
        storedAccessToken = 'expired-access-token';
        storedRefreshToken = 'stored-refresh-token';
        AuthSession().setAuthenticated(true);

        responder = (options, index) => jsonResponseBody(
              <String, dynamic>{'message': 'Unauthorized'},
              statusCode: 401,
            );

        // Act
        await expectLater(
          withFakeHttpClient(
            fakeHttpClient,
            () => dioClient.client.get<Map<String, dynamic>>(
              '${ApiConstants.apiPrefix}/alerts',
              options: Options(extra: <String, dynamic>{
                '_retry_after_refresh': true,
              }),
            ),
          ),
          throwsA(_isSessionExpiredCancellation),
        );

        // Assert — the loop guard stops before any second refresh.
        verifyNever(() => tokenStorage.getRefreshToken());
        expect(fakeHttpClient.exchanges, isEmpty);
        verify(() => tokenStorage.clearAll()).called(1);
        expect(AuthSession().isAuthenticated, isFalse);
        expect(adapter.requests, hasLength(1));
      },
    );

    test(
      'should stop after a single retry and invalidate the session when the '
      'retried request is rejected again',
      () async {
        // Arrange
        storedAccessToken = 'expired-access-token';
        storedRefreshToken = 'stored-refresh-token';
        AuthSession().setAuthenticated(true);

        responder = (options, index) => jsonResponseBody(
              <String, dynamic>{'message': 'Unauthorized'},
              statusCode: 401,
            );

        // Act
        await expectLater(
          withFakeHttpClient(
            fakeHttpClient,
            () => dioClient.client.get<Map<String, dynamic>>(
              '${ApiConstants.apiPrefix}/alerts',
            ),
          ),
          throwsA(_isSessionExpiredCancellation),
        );

        // Assert — one refresh, one retry, then the session is dropped.
        expect(fakeHttpClient.exchanges, hasLength(1));
        expect(adapter.requests, hasLength(2));
        verify(() => tokenStorage.clearAll())
            .called(greaterThanOrEqualTo(1));
        expect(AuthSession().isAuthenticated, isFalse);
      },
    );

    test(
      'should pass a 401 through untouched when the request carried no bearer '
      'header',
      () async {
        // Arrange — a public auth endpoint never receives the header.
        storedAccessToken = null;
        storedRefreshToken = 'stored-refresh-token';
        AuthSession().setAuthenticated(true);

        responder = (options, index) => jsonResponseBody(
              <String, dynamic>{'message': 'Unauthorized'},
              statusCode: 401,
            );

        // Act
        await expectLater(
          withFakeHttpClient(
            fakeHttpClient,
            () => dioClient.client.post<Map<String, dynamic>>(
              '${ApiConstants.authBase}/sign-in',
              data: <String, dynamic>{'email': 'user@example.test'},
            ),
          ),
          throwsA(
            _isBadResponse.having(
              (error) => error.response?.statusCode,
              'statusCode',
              401,
            ),
          ),
        );

        // Assert — neither refreshed nor invalidated.
        verifyNever(() => tokenStorage.getRefreshToken());
        verifyNever(() => tokenStorage.clearAll());
        expect(fakeHttpClient.exchanges, isEmpty);
        expect(AuthSession().isAuthenticated, isTrue);
      },
    );

    test(
      'should pass a non 401 failure through untouched on a protected request',
      () async {
        // Arrange
        storedAccessToken = 'valid-access-token';
        storedRefreshToken = 'stored-refresh-token';
        AuthSession().setAuthenticated(true);

        responder = (options, index) => jsonResponseBody(
              <String, dynamic>{'message': 'Server exploded'},
              statusCode: 500,
            );

        // Act
        await expectLater(
          withFakeHttpClient(
            fakeHttpClient,
            () => dioClient.client.get<Map<String, dynamic>>(
              '${ApiConstants.apiPrefix}/alerts',
            ),
          ),
          throwsA(
            _isBadResponse.having(
              (error) => error.response?.statusCode,
              'statusCode',
              500,
            ),
          ),
        );

        // Assert — a server error must not log the user out.
        verifyNever(() => tokenStorage.getRefreshToken());
        verifyNever(() => tokenStorage.clearAll());
        expect(fakeHttpClient.exchanges, isEmpty);
        expect(AuthSession().isAuthenticated, isTrue);
        expect(adapter.requests, hasLength(1));
      },
    );

    test(
      'should pass a forbidden response through untouched on a protected '
      'request',
      () async {
        // Arrange
        storedAccessToken = 'valid-access-token';
        AuthSession().setAuthenticated(true);

        responder = (options, index) => jsonResponseBody(
              <String, dynamic>{'message': 'Forbidden'},
              statusCode: 403,
            );

        // Act
        await expectLater(
          withFakeHttpClient(
            fakeHttpClient,
            () => dioClient.client.get<Map<String, dynamic>>(
              '${ApiConstants.apiPrefix}/spaces',
            ),
          ),
          throwsA(
            _isBadResponse.having(
              (error) => error.response?.statusCode,
              'statusCode',
              403,
            ),
          ),
        );

        // Assert
        verifyNever(() => tokenStorage.clearAll());
        expect(AuthSession().isAuthenticated, isTrue);
      },
    );
  });
}