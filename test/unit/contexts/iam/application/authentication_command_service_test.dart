import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/application/internal/commandservices/authentication_command_service_impl.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mobile/iam/interfaces/rest/resources/google_sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/refresh_token_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/sign_in_request.resource.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/iam_test_doubles.dart';

void main() {
  late MockAuthenticationGateway gateway;
  late MockTokenLocalStorage tokenStorage;
  late MockRegistrationSessionLocalStorage registrationStorage;
  late AuthenticationCommandServiceImpl service;

  setUpAll(registerIamFallbackValues);

  setUp(() {
    gateway = MockAuthenticationGateway();
    tokenStorage = MockTokenLocalStorage();
    registrationStorage = MockRegistrationSessionLocalStorage();

    when(() => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
    when(() => tokenStorage.saveUser(
          userId: any(named: 'userId'),
          email: any(named: 'email'),
        )).thenAnswer((_) async {});
    when(() => tokenStorage.clearAll()).thenAnswer((_) async {});
    when(() => registrationStorage.saveSessionId(any()))
        .thenAnswer((_) async {});
    when(() => registrationStorage.clearSessionId()).thenAnswer((_) async {});

    service = AuthenticationCommandServiceImpl(
      gateway,
      tokenStorage,
      registrationStorage,
    );
  });

  tearDown(() => AuthSession().setAuthenticated(false));

  group('AuthenticationCommandServiceImpl.handleSignIn', () {
    test(
      'should return the authenticated user and persist credentials when the gateway succeeds',
      () async {
        // Arrange
        when(() => gateway.signIn(any()))
            .thenAnswer((_) async => IamFixtures.authenticatedUser);

        // Act
        final result = await service.handleSignIn(IamFixtures.signInCommand());

        // Assert
        expect(result.isRight(), isTrue);
        expect(expectRightValue(result), IamFixtures.authenticatedUser);

        final captured = verify(
          () => gateway.signIn(captureAny()),
        ).captured.single as SignInRequestResource;
        expect(captured.email, IamFixtures.email);
        expect(captured.password, IamFixtures.password);
      },
    );

    test(
      'should store both tokens and the user identity after a successful sign in',
      () async {
        // Arrange
        when(() => gateway.signIn(any()))
            .thenAnswer((_) async => IamFixtures.authenticatedUser);

        // Act
        await service.handleSignIn(IamFixtures.signInCommand());

        // Assert
        final tokens = verify(
          () => tokenStorage.saveTokens(
            accessToken: captureAny(named: 'accessToken'),
            refreshToken: captureAny(named: 'refreshToken'),
          ),
        ).captured;
        expect(tokens, [IamFixtures.accessToken, IamFixtures.refreshToken]);

        final user = verify(
          () => tokenStorage.saveUser(
            userId: captureAny(named: 'userId'),
            email: captureAny(named: 'email'),
          ),
        ).captured;
        expect(user, [IamFixtures.userId, IamFixtures.email]);
      },
    );

    test('should mark the session as authenticated after a successful sign in', () async {
      // Arrange
      when(() => gateway.signIn(any()))
          .thenAnswer((_) async => IamFixtures.authenticatedUser);

      // Act
      await service.handleSignIn(IamFixtures.signInCommand());

      // Assert
      expect(AuthSession().isAuthenticated, isTrue);
    });

    test('should not persist credentials when the gateway rejects the sign in', () async {
      // Arrange
      when(() => gateway.signIn(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/sign-in'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/auth/sign-in'),
            statusCode: 401,
          ),
        ),
      );

      // Act
      final result = await service.handleSignIn(IamFixtures.signInCommand());

      // Assert
      expect(result.isLeft(), isTrue);
      verifyNever(() => tokenStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ));
      verifyNever(() => tokenStorage.saveUser(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
          ));
      expect(AuthSession().isAuthenticated, isFalse);
    });
  });

  group('AuthenticationCommandServiceImpl.handleAuthenticateWithGoogle', () {
    test(
      'should forward the id token to the gateway and persist the credentials',
      () async {
        // Arrange
        when(() => gateway.googleSignIn(any()))
            .thenAnswer((_) async => IamFixtures.authenticatedUser);

        // Act
        final result = await service.handleAuthenticateWithGoogle(IamFixtures.googleCommand());

        // Assert
        expect(result.isRight(), isTrue);

        final captured =
            verify(() => gateway.googleSignIn(captureAny())).captured.single as GoogleSignInRequestResource;
        expect(captured.idToken, IamFixtures.googleIdToken);

        verify(() => tokenStorage.saveTokens(
              accessToken: IamFixtures.accessToken,
              refreshToken: IamFixtures.refreshToken,
            ));
        verify(() => tokenStorage.saveUser(
              userId: IamFixtures.userId,
              email: IamFixtures.email,
            ));
        expect(AuthSession().isAuthenticated, isTrue);
      },
    );
  });

  group('AuthenticationCommandServiceImpl.handleSignOut', () {
    test('should clear storage and reset the session when the gateway succeeds', () async {
      // Arrange
      when(() => gateway.signOut(any())).thenAnswer((_) async {});
      AuthSession().setAuthenticated(true);

      // Act
      final result = await service.handleSignOut(IamFixtures.signOutCommand());

      // Assert
      expect(result.isRight(), isTrue);
      verify(() => gateway.signOut(IamFixtures.accessToken)).called(1);
      verify(() => tokenStorage.clearAll()).called(1);
      expect(AuthSession().isAuthenticated, isFalse);
    });

    test(
      'should still clear storage and reset the session while reporting the failure',
      () async {
        // Arrange
        when(() => gateway.signOut(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/v1/auth/sign-out'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/v1/auth/sign-out'),
              statusCode: 403,
            ),
          ),
        );
        AuthSession().setAuthenticated(true);

        // Act
        final result = await service.handleSignOut(IamFixtures.signOutCommand());

        // Assert
        expect(result.isLeft(), isTrue);
        verify(() => tokenStorage.clearAll()).called(1);
        expect(AuthSession().isAuthenticated, isFalse);
      },
    );
  });

  group('AuthenticationCommandServiceImpl.handleRefreshToken', () {
    test(
      'should persist the rotated tokens and mark the session as authenticated',
      () async {
        // Arrange
        when(() => gateway.refreshToken(any()))
            .thenAnswer((_) async => IamFixtures.authenticatedUser);

        // Act
        final result = await service.handleRefreshToken(IamFixtures.refreshTokenCommand());

        // Assert
        expect(result.isRight(), isTrue);

        final captured = verify(() => gateway.refreshToken(captureAny()))
            .captured
            .single as RefreshTokenRequestResource;
        expect(captured.refreshToken, IamFixtures.refreshToken);

        verify(() => tokenStorage.saveTokens(
              accessToken: IamFixtures.accessToken,
              refreshToken: IamFixtures.refreshToken,
            ));
        expect(AuthSession().isAuthenticated, isTrue);
      },
    );

    test('should not mark the session as authenticated when the refresh fails', () async {
      // Arrange
      when(() => gateway.refreshToken(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
            statusCode: 401,
          ),
        ),
      );

      // Act
      final result = await service.handleRefreshToken(IamFixtures.refreshTokenCommand());

      // Assert
      expect(result.isLeft(), isTrue);
      expect(AuthSession().isAuthenticated, isFalse);
    });
  });

  group('AuthenticationCommandServiceImpl.handleInitiateRegistration', () {
    test('should store the returned session id when registration starts', () async {
      // Arrange
      when(() => gateway.initiateRegistration(any()))
          .thenAnswer((_) async => IamFixtures.registrationInitiated);

      // Act
      final result =
          await service.handleInitiateRegistration(IamFixtures.initiateRegistrationCommand());

      // Assert
      expect(result.isRight(), isTrue);
      verify(() => registrationStorage.saveSessionId(IamFixtures.sessionId)).called(1);
    });

    test('should not store a session id when the gateway fails', () async {
      // Arrange
      when(() => gateway.initiateRegistration(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/sign-up'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/auth/sign-up'),
            statusCode: 409,
          ),
        ),
      );

      // Act
      final result =
          await service.handleInitiateRegistration(IamFixtures.initiateRegistrationCommand());

      // Assert
      expect(result.isLeft(), isTrue);
      verifyNever(() => registrationStorage.saveSessionId(any()));
    });
  });

  group('AuthenticationCommandServiceImpl.handleConfirmRegistration', () {
    test('should clear the stored session id when confirmation succeeds', () async {
      // Arrange
      when(() => gateway.confirmRegistration(any()))
          .thenAnswer((_) async => IamFixtures.user);

      // Act
      final result =
          await service.handleConfirmRegistration(IamFixtures.confirmRegistrationCommand());

      // Assert
      expect(result.isRight(), isTrue);
      expect(
        expectRightValue(result),
        IamFixtures.user,
      );
      verify(() => registrationStorage.clearSessionId()).called(1);
    });

    test('should keep the session id when confirmation fails', () async {
      // Arrange
      when(() => gateway.confirmRegistration(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/confirm'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/auth/confirm'),
            statusCode: 400,
          ),
        ),
      );

      // Act
      final result =
          await service.handleConfirmRegistration(IamFixtures.confirmRegistrationCommand());

      // Assert
      expect(result.isLeft(), isTrue);
      verifyNever(() => registrationStorage.clearSessionId());
    });
  });

  group('AuthenticationCommandServiceImpl error mapping', () {
    DioException dioWithStatus(int statusCode) => DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/sign-in'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/auth/sign-in'),
            statusCode: statusCode,
          ),
        );

    test('should translate each HTTP status into its documented message', () async {
      // Arrange
      final expected = <int, String>{
        400: 'Invalid request. Please check your input.',
        401: 'Invalid email or password.',
        403: 'Access denied. Please contact support.',
        404: 'User not found.',
        409: 'User already exists.',
        422: 'Invalid data. Please check your input.',
        500: 'Server error. Please try again later.',
        502: 'Server error. Please try again later.',
        503: 'Server error. Please try again later.',
        418: 'Network error. Please check your connection.',
      };

      for (final entry in expected.entries) {
        when(() => gateway.signIn(any())).thenThrow(dioWithStatus(entry.key));

        // Act
        final result = await service.handleSignIn(IamFixtures.signInCommand());

        // Assert
        expect(result.isLeft(), isTrue, reason: 'status ${entry.key}');
        final failure = expectLeftFailure(result);
        expect(failure.message, entry.value, reason: 'status ${entry.key}');
      }
    });

    test('should report a network failure when the response has no status', () async {
      // Arrange
      when(() => gateway.signIn(any())).thenThrow(
        DioException.connectionTimeout(
          timeout: const Duration(seconds: 5),
          requestOptions: RequestOptions(path: '/api/v1/auth/sign-in'),
        ),
      );

      // Act
      final result = await service.handleSignIn(IamFixtures.signInCommand());

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = expectLeftFailure(result);
      expect(failure.message, 'Network error. Please check your connection.');
    });

    test('should surface the message of a thrown Exception', () async {
      // Arrange
      when(() => gateway.signIn(any())).thenThrow(Exception('socket closed'));

      // Act
      final result = await service.handleSignIn(IamFixtures.signInCommand());

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = expectLeftFailure(result);
      expect(failure.message, 'socket closed');
    });

    test('should fall back to a generic message when a non Exception is thrown', () async {
      // Arrange
      when(() => gateway.signIn(any())).thenThrow('unexpected');

      // Act
      final result = await service.handleSignIn(IamFixtures.signInCommand());

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = expectLeftFailure(result);
      expect(failure, isA<Failure>());
      expect(failure.message, 'An unexpected error occurred');
      expect(failure.statusCode, isNull);
    });
  });
}

