import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mocktail/mocktail.dart';

import 'dio_test_doubles.dart';

/// Endpoints that must never carry a bearer token, mapped to the segment that
/// identifies them inside the auth base path.
const Map<String, String> _publicAuthEndpoints = <String, String>{
  'sign-up': 'sign-up',
  'confirm-registration': 'confirm',
  'sign-in': 'sign-in',
  'google sign-in': 'google/sign-in',
  'refresh': 'refresh',
};

void main() {
  late MockTokenLocalStorage tokenStorage;
  late DioClient dioClient;
  late RecordingHttpClientAdapter adapter;
  late DioResponder responder;
  late void Function() restoreDotEnv;

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

    tokenStorage = MockTokenLocalStorage();
    when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => null);

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

  group('DioClient request interceptor', () {
    test(
      'should attach the bearer token to a protected request when an access '
      'token is stored',
      () async {
        // Arrange
        const storedToken = 'stored-access-token';
        when(() => tokenStorage.getAccessToken())
            .thenAnswer((_) async => storedToken);

        // Act
        await dioClient.client.get<Map<String, dynamic>>(
          '${ApiConstants.apiPrefix}/analytics/dashboard',
        );

        // Assert
        expect(adapter.requests, hasLength(1));
        expect(adapter.lastRequest.headers['Authorization'], 'Bearer $storedToken');
      },
    );

    test(
      'should omit the authorization header when no access token is stored',
      () async {
        // Arrange
        when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => null);

        // Act
        await dioClient.client.get<Map<String, dynamic>>(
          '${ApiConstants.apiPrefix}/alerts',
        );

        // Assert
        expect(adapter.requests, hasLength(1));
        expect(adapter.lastRequest.headers, isNot(contains('Authorization')));
      },
    );

    test(
      'should omit the authorization header when the stored access token is '
      'empty',
      () async {
        // Arrange
        when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => '');

        // Act
        await dioClient.client.get<Map<String, dynamic>>(
          '${ApiConstants.apiPrefix}/alerts',
        );

        // Assert
        expect(adapter.requests, hasLength(1));
        expect(adapter.lastRequest.headers, isNot(contains('Authorization')));
      },
    );

    test(
      'should attach the bearer token to every protected request when several '
      'are issued',
      () async {
        // Arrange
        const storedToken = 'stored-access-token';
        when(() => tokenStorage.getAccessToken())
            .thenAnswer((_) async => storedToken);

        // Act
        await dioClient.client
            .get<Map<String, dynamic>>('${ApiConstants.apiPrefix}/alerts');
        await dioClient.client
            .get<Map<String, dynamic>>('${ApiConstants.apiPrefix}/spaces');

        // Assert
        expect(adapter.requests, hasLength(2));
        expect(
          adapter.requests.map((request) => request.headers['Authorization']),
          everyElement('Bearer $storedToken'),
        );
      },
    );

    test(
      'should send the bearer token on a body bearing write request',
      () async {
        // Arrange
        const storedToken = 'stored-access-token';
        when(() => tokenStorage.getAccessToken())
            .thenAnswer((_) async => storedToken);

        // Act
        await dioClient.client.post<Map<String, dynamic>>(
          '${ApiConstants.apiPrefix}/devices/device-1/thresholds',
          data: <String, dynamic>{'field': 'aqi', 'value': 42},
        );

        // Assert
        expect(adapter.requests, hasLength(1));
        expect(adapter.lastRequest.method, 'POST');
        expect(
          adapter.lastRequest.headers['Authorization'],
          'Bearer $storedToken',
        );
        expect(
          adapter.lastRequest.data,
          <String, dynamic>{'field': 'aqi', 'value': 42},
        );
      },
    );

    for (final MapEntry<String, String> endpoint in _publicAuthEndpoints.entries) {
      final String label = endpoint.key;
      final String segment = endpoint.value;

      test(
        'should omit the authorization header from the $label endpoint when an '
        'access token is stored',
        () async {
          // Arrange
          const storedToken = 'stored-access-token';
          when(() => tokenStorage.getAccessToken())
              .thenAnswer((_) async => storedToken);

          // Act
          await dioClient.client.post<Map<String, dynamic>>(
            '${ApiConstants.authBase}/$segment',
            data: <String, dynamic>{'email': 'user@example.test'},
          );

          // Assert
          expect(adapter.requests, hasLength(1));
          expect(
            adapter.lastRequest.headers,
            isNot(contains('Authorization')),
            reason: 'A stored token must never leak to the public $label '
                'endpoint.',
          );
          verifyNever(() => tokenStorage.getAccessToken());
        },
      );
    }

    test(
      'should keep the request untouched on a public auth endpoint when the '
      'token lookup would fail',
      () async {
        // Arrange — a lookup that would throw proves it is never performed.
        when(() => tokenStorage.getAccessToken()).thenThrow(
          StateError('token storage must not be consulted for public endpoints'),
        );

        // Act
        final response = await dioClient.client.post<Map<String, dynamic>>(
          '${ApiConstants.authBase}/sign-in',
          data: <String, dynamic>{
            'email': 'user@example.test',
            'password': 'secret',
          },
        );

        // Assert
        expect(adapter.requests, hasLength(1));
        expect(adapter.lastRequest.headers, isNot(contains('Authorization')));
        expect(response.data, <String, dynamic>{'ok': true});
      },
    );
  });
}