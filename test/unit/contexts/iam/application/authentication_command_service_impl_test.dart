import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/iam/application/internal/commandservices/authentication_command_service_impl.dart';
import 'package:mobile/iam/domain/model/commands/authenticate_with_google.command.dart';
import 'package:mobile/iam/domain/model/commands/confirm_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/initiate_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/refresh_token.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_in.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/domain/model/valueobjects/access_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/email_address.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/google_id_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/password.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/refresh_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/session_id.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/verification_code.valueobject.dart';
import 'package:mobile/iam/infrastructure/api/gateways/authentication.gateway.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mobile/iam/infrastructure/persistence/local/registration_session_local_storage.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:mobile/iam/interfaces/rest/resources/authenticated_user_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/confirm_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/google_sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/initiate_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/refresh_token_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/registration_initiated_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/user_resource.resource.dart';

class MockAuthenticationGateway extends Mock implements AuthenticationGateway {}
class MockTokenLocalStorage extends Mock implements TokenLocalStorage {}
class MockRegistrationSessionLocalStorage extends Mock implements RegistrationSessionLocalStorage {}

class FakeInitiateRegistrationRequestResource extends Fake implements InitiateRegistrationRequestResource {}
class FakeConfirmRegistrationRequestResource extends Fake implements ConfirmRegistrationRequestResource {}
class FakeSignInRequestResource extends Fake implements SignInRequestResource {}
class FakeGoogleSignInRequestResource extends Fake implements GoogleSignInRequestResource {}
class FakeRefreshTokenRequestResource extends Fake implements RefreshTokenRequestResource {}

DioException createDioException({int? statusCode, String? message}) {
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    response: statusCode != null
        ? Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: statusCode,
          )
        : null,
    message: message,
  );
}

void main() {
  late MockAuthenticationGateway mockGateway;
  late MockTokenLocalStorage mockLocalStorage;
  late MockRegistrationSessionLocalStorage mockRegistrationStorage;
  late AuthenticationCommandServiceImpl commandService;

  setUpAll(() {
    registerFallbackValue(FakeInitiateRegistrationRequestResource());
    registerFallbackValue(FakeConfirmRegistrationRequestResource());
    registerFallbackValue(FakeSignInRequestResource());
    registerFallbackValue(FakeGoogleSignInRequestResource());
    registerFallbackValue(FakeRefreshTokenRequestResource());
  });

  setUp(() {
    mockGateway = MockAuthenticationGateway();
    mockLocalStorage = MockTokenLocalStorage();
    mockRegistrationStorage = MockRegistrationSessionLocalStorage();
    commandService = AuthenticationCommandServiceImpl(
      mockGateway,
      mockLocalStorage,
      mockRegistrationStorage,
    );
    AuthSession().setAuthenticated(false);
  });

  tearDown(() {
    AuthSession().setAuthenticated(false);
  });

  group('AuthenticationCommandServiceImpl - handleInitiateRegistration', () {
    test('should return Right with RegistrationInitiatedResource and save sessionId when gateway succeeds', () async {
      // Arrange
      const initiatedResource = RegistrationInitiatedResource(
        sessionId: 'session-uuid-123',
        message: 'Code sent',
      );
      when(() => mockGateway.initiateRegistration(any()))
          .thenAnswer((_) async => initiatedResource);
      when(() => mockRegistrationStorage.saveSessionId(any()))
          .thenAnswer((_) async {});

      final command = InitiateRegistrationCommand(
        email: EmailAddress('newuser@example.com'),
        password: Password('Pass123!'),
      );

      // Act
      final result = await commandService.handleInitiateRegistration(command);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left: ${failure.message}'),
        (resource) {
          expect(resource.sessionId, equals('session-uuid-123'));
          expect(resource.message, equals('Code sent'));
        },
      );
      verify(() => mockRegistrationStorage.saveSessionId('session-uuid-123')).called(1);
    });

    test('should return Left with mapped error when gateway throws DioException 409', () async {
      // Arrange
      when(() => mockGateway.initiateRegistration(any()))
          .thenThrow(createDioException(statusCode: 409));

      final command = InitiateRegistrationCommand(
        email: EmailAddress('existing@example.com'),
        password: Password('Pass123!'),
      );

      // Act
      final result = await commandService.handleInitiateRegistration(command);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('User already exists.')),
        (_) => fail('Expected Left'),
      );
    });

    test('should return Left with mapped message when generic exception occurs', () async {
      // Arrange
      when(() => mockGateway.initiateRegistration(any()))
          .thenThrow(Exception('Custom error occurred'));

      final command = InitiateRegistrationCommand(
        email: EmailAddress('user@example.com'),
        password: Password('Pass123!'),
      );

      // Act
      final result = await commandService.handleInitiateRegistration(command);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('Custom error occurred')),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('AuthenticationCommandServiceImpl - handleConfirmRegistration', () {
    test('should return Right with UserResource and clear sessionId when gateway succeeds', () async {
      // Arrange
      const userResource = UserResource(
        id: 'user-uuid-123',
        email: 'user@example.com',
      );
      when(() => mockGateway.confirmRegistration(any()))
          .thenAnswer((_) async => userResource);
      when(() => mockRegistrationStorage.clearSessionId())
          .thenAnswer((_) async {});

      final command = ConfirmRegistrationCommand(
        sessionId: SessionId('123e4567-e89b-12d3-a456-426614174000'),
        verificationCode: VerificationCode('ABCD-1234'),
      );

      // Act
      final result = await commandService.handleConfirmRegistration(command);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (resource) {
          expect(resource.id, equals('user-uuid-123'));
          expect(resource.email, equals('user@example.com'));
        },
      );
      verify(() => mockRegistrationStorage.clearSessionId()).called(1);
    });

    test('should return Left with mapped error when confirmRegistration throws DioException 400', () async {
      // Arrange
      when(() => mockGateway.confirmRegistration(any()))
          .thenThrow(createDioException(statusCode: 400));

      final command = ConfirmRegistrationCommand(
        sessionId: SessionId('123e4567-e89b-12d3-a456-426614174000'),
        verificationCode: VerificationCode('ABCD-1234'),
      );

      // Act
      final result = await commandService.handleConfirmRegistration(command);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('Invalid request. Please check your input.')),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('AuthenticationCommandServiceImpl - handleSignIn', () {
    test('should return Right, save tokens, save user, and update AuthSession on success', () async {
      // Arrange
      const authUser = AuthenticatedUserResource(
        id: '123e4567-e89b-12d3-a456-426614174000',
        email: 'user@example.com',
        token: 'access-jwt-token',
        refreshToken: 'refresh-jwt-token',
      );
      when(() => mockGateway.signIn(any())).thenAnswer((_) async => authUser);
      when(() => mockLocalStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});
      when(() => mockLocalStorage.saveUser(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
          )).thenAnswer((_) async {});

      final command = SignInCommand(
        email: EmailAddress('user@example.com'),
        password: Password('Pass123!'),
      );

      // Act
      final result = await commandService.handleSignIn(command);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (user) {
          expect(user.id, equals(authUser.id));
          expect(user.token, equals(authUser.token));
        },
      );
      verify(() => mockLocalStorage.saveTokens(
            accessToken: 'access-jwt-token',
            refreshToken: 'refresh-jwt-token',
          )).called(1);
      verify(() => mockLocalStorage.saveUser(
            userId: '123e4567-e89b-12d3-a456-426614174000',
            email: 'user@example.com',
          )).called(1);
      expect(AuthSession().isAuthenticated, isTrue);
    });

    test('should return Left with mapped error when signIn fails with 401', () async {
      // Arrange
      when(() => mockGateway.signIn(any()))
          .thenThrow(createDioException(statusCode: 401));

      final command = SignInCommand(
        email: EmailAddress('user@example.com'),
        password: Password('Pass123!'),
      );

      // Act
      final result = await commandService.handleSignIn(command);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('Invalid email or password.')),
        (_) => fail('Expected Left'),
      );
      expect(AuthSession().isAuthenticated, isFalse);
    });
  });

  group('AuthenticationCommandServiceImpl - handleAuthenticateWithGoogle', () {
    test('should return Right, save tokens, and update AuthSession when google sign-in succeeds', () async {
      // Arrange
      const authUser = AuthenticatedUserResource(
        id: 'google-user-id',
        email: 'google@example.com',
        token: 'google-jwt-access',
        refreshToken: 'google-jwt-refresh',
      );
      when(() => mockGateway.googleSignIn(any())).thenAnswer((_) async => authUser);
      when(() => mockLocalStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});
      when(() => mockLocalStorage.saveUser(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
          )).thenAnswer((_) async {});

      final command = AuthenticateWithGoogleCommand(
        idToken: GoogleIdToken('google-token-string'),
      );

      // Act
      final result = await commandService.handleAuthenticateWithGoogle(command);

      // Assert
      expect(result.isRight(), isTrue);
      expect(AuthSession().isAuthenticated, isTrue);
      verify(() => mockLocalStorage.saveTokens(
            accessToken: 'google-jwt-access',
            refreshToken: 'google-jwt-refresh',
          )).called(1);
      verify(() => mockLocalStorage.saveUser(
            userId: 'google-user-id',
            email: 'google@example.com',
          )).called(1);
    });

    test('should return Left when google sign-in fails with 403', () async {
      // Arrange
      when(() => mockGateway.googleSignIn(any()))
          .thenThrow(createDioException(statusCode: 403));

      final command = AuthenticateWithGoogleCommand(
        idToken: GoogleIdToken('google-token-string'),
      );

      // Act
      final result = await commandService.handleAuthenticateWithGoogle(command);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('Access denied. Please contact support.')),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('AuthenticationCommandServiceImpl - handleSignOut', () {
    test('should call gateway, clear tokens, set AuthSession to false, and return Right(unit) on success', () async {
      // Arrange
      AuthSession().setAuthenticated(true);
      when(() => mockGateway.signOut(any())).thenAnswer((_) async {});
      when(() => mockLocalStorage.clearAll()).thenAnswer((_) async {});

      final command = SignOutCommand(accessToken: AccessToken('valid-token'));

      // Act
      final result = await commandService.handleSignOut(command);

      // Assert
      expect(result.isRight(), isTrue);
      verify(() => mockGateway.signOut('valid-token')).called(1);
      verify(() => mockLocalStorage.clearAll()).called(1);
      expect(AuthSession().isAuthenticated, isFalse);
    });

    test('should clear tokens and set AuthSession to false even when gateway throws exception', () async {
      // Arrange
      AuthSession().setAuthenticated(true);
      when(() => mockGateway.signOut(any()))
          .thenThrow(createDioException(statusCode: 500));
      when(() => mockLocalStorage.clearAll()).thenAnswer((_) async {});

      final command = SignOutCommand(accessToken: AccessToken('valid-token'));

      // Act
      final result = await commandService.handleSignOut(command);

      // Assert
      expect(result.isLeft(), isTrue);
      verify(() => mockLocalStorage.clearAll()).called(1);
      expect(AuthSession().isAuthenticated, isFalse);
      result.fold(
        (failure) => expect(failure.message, equals('Server error. Please try again later.')),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('AuthenticationCommandServiceImpl - handleRefreshToken', () {
    test('should return Right and update stored tokens when refresh succeeds', () async {
      // Arrange
      const refreshedUser = AuthenticatedUserResource(
        id: 'user-id-123',
        email: 'user@example.com',
        token: 'new-access-jwt',
        refreshToken: 'new-refresh-jwt',
      );
      when(() => mockGateway.refreshToken(any())).thenAnswer((_) async => refreshedUser);
      when(() => mockLocalStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});
      when(() => mockLocalStorage.saveUser(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
          )).thenAnswer((_) async {});

      final command = RefreshTokenCommand(refreshToken: RefreshToken('old-refresh-token'));

      // Act
      final result = await commandService.handleRefreshToken(command);

      // Assert
      expect(result.isRight(), isTrue);
      verify(() => mockLocalStorage.saveTokens(
            accessToken: 'new-access-jwt',
            refreshToken: 'new-refresh-jwt',
          )).called(1);
      expect(AuthSession().isAuthenticated, isTrue);
    });

    test('should return Left when refreshToken throws DioException 404', () async {
      // Arrange
      when(() => mockGateway.refreshToken(any()))
          .thenThrow(createDioException(statusCode: 404));

      final command = RefreshTokenCommand(refreshToken: RefreshToken('old-refresh-token'));

      // Act
      final result = await commandService.handleRefreshToken(command);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('User not found.')),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('AuthenticationCommandServiceImpl - error mapping', () {
    final statusCodesToMessages = {
      400: 'Invalid request. Please check your input.',
      401: 'Invalid email or password.',
      403: 'Access denied. Please contact support.',
      404: 'User not found.',
      409: 'User already exists.',
      422: 'Invalid data. Please check your input.',
      500: 'Server error. Please try again later.',
      502: 'Server error. Please try again later.',
      503: 'Server error. Please try again later.',
      999: 'Network error. Please check your connection.',
    };

    for (final entry in statusCodesToMessages.entries) {
      test('should map DioException status ${entry.key} to "${entry.value}"', () async {
        // Arrange
        when(() => mockGateway.signIn(any()))
            .thenThrow(createDioException(statusCode: entry.key));

        final command = SignInCommand(
          email: EmailAddress('user@example.com'),
          password: Password('Pass123!'),
        );

        // Act
        final result = await commandService.handleSignIn(command);

        // Assert
        result.fold(
          (failure) => expect(failure.message, equals(entry.value)),
          (_) => fail('Expected Left'),
        );
      });
    }

    test('should map unexpected non-exception object to default error message', () async {
      // Arrange
      when(() => mockGateway.signIn(any())).thenThrow('some string error');

      final command = SignInCommand(
        email: EmailAddress('user@example.com'),
        password: Password('Pass123!'),
      );

      // Act
      final result = await commandService.handleSignIn(command);

      // Assert
      result.fold(
        (failure) => expect(failure.message, equals('An unexpected error occurred')),
        (_) => fail('Expected Left'),
      );
    });
  });
}
