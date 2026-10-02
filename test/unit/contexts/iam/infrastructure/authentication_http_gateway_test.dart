import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/infrastructure/api/gateways/authentication_http.gateway.dart';
import 'package:mobile/iam/interfaces/rest/resources/confirm_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/google_sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/initiate_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/refresh_token_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/sign_in_request.resource.dart';

import '../../../../support/fake_http_client_adapter.dart';

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  });

  group('AuthenticationHttpGateway', () {
    test('should send POST to /sign-up and return RegistrationInitiatedResource on success', () async {
      // Arrange
      late RequestOptions capturedOptions;
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return FakeHttpClientAdapter.jsonResponse({
          'sessionId': 'session-xyz-123',
          'message': 'Verification code sent',
        });
      });
      final gateway = AuthenticationHttpGateway(dio);
      const resource = InitiateRegistrationRequestResource(
        email: 'user@example.com',
        password: 'Password123!',
      );

      // Act
      final result = await gateway.initiateRegistration(resource);

      // Assert
      expect(capturedOptions.path, equals('/api/v1/auth/sign-up'));
      expect(capturedOptions.method, equals('POST'));
      expect(capturedOptions.data, equals({
        'email': 'user@example.com',
        'password': 'Password123!',
      }));
      expect(result.sessionId, equals('session-xyz-123'));
      expect(result.message, equals('Verification code sent'));
    });

    test('should throw DioException when initiateRegistration fails', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        return FakeHttpClientAdapter.jsonResponse(
          {'error': 'Conflict'},
          statusCode: 409,
        );
      });
      final gateway = AuthenticationHttpGateway(dio);
      const resource = InitiateRegistrationRequestResource(
        email: 'existing@example.com',
        password: 'Password123!',
      );

      // Act & Assert
      expect(
        () => gateway.initiateRegistration(resource),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 409)),
      );
    });

    test('should send POST to /confirm and return UserResource on success', () async {
      // Arrange
      late RequestOptions capturedOptions;
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return FakeHttpClientAdapter.jsonResponse({
          'id': 'user-123',
          'email': 'user@example.com',
        });
      });
      final gateway = AuthenticationHttpGateway(dio);
      const resource = ConfirmRegistrationRequestResource(
        sessionId: 'session-xyz-123',
        verificationCode: 'ABCD-1234',
      );

      // Act
      final result = await gateway.confirmRegistration(resource);

      // Assert
      expect(capturedOptions.path, equals('/api/v1/auth/confirm'));
      expect(capturedOptions.method, equals('POST'));
      expect(capturedOptions.data, equals({
        'sessionId': 'session-xyz-123',
        'verificationCode': 'ABCD-1234',
      }));
      expect(result.id, equals('user-123'));
      expect(result.email, equals('user@example.com'));
    });

    test('should throw DioException when confirmRegistration fails', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        return FakeHttpClientAdapter.jsonResponse(
          {'error': 'Invalid code'},
          statusCode: 400,
        );
      });
      final gateway = AuthenticationHttpGateway(dio);
      const resource = ConfirmRegistrationRequestResource(
        sessionId: 'session-xyz-123',
        verificationCode: 'WRONG',
      );

      // Act & Assert
      expect(
        () => gateway.confirmRegistration(resource),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 400)),
      );
    });

    test('should send POST to /sign-in and return AuthenticatedUserResource on success', () async {
      // Arrange
      late RequestOptions capturedOptions;
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return FakeHttpClientAdapter.jsonResponse({
          'id': 'user-abc-123',
          'email': 'user@example.com',
          'token': 'access-token-jwt',
          'refreshToken': 'refresh-token-xyz',
        });
      });
      final gateway = AuthenticationHttpGateway(dio);
      const resource = SignInRequestResource(
        email: 'user@example.com',
        password: 'Password123!',
      );

      // Act
      final result = await gateway.signIn(resource);

      // Assert
      expect(capturedOptions.path, equals('/api/v1/auth/sign-in'));
      expect(capturedOptions.method, equals('POST'));
      expect(capturedOptions.data, equals({
        'email': 'user@example.com',
        'password': 'Password123!',
      }));
      expect(result.id, equals('user-abc-123'));
      expect(result.email, equals('user@example.com'));
      expect(result.token, equals('access-token-jwt'));
      expect(result.refreshToken, equals('refresh-token-xyz'));
    });

    test('should throw DioException when signIn fails with 401', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        return FakeHttpClientAdapter.jsonResponse(
          {'error': 'Unauthorized'},
          statusCode: 401,
        );
      });
      final gateway = AuthenticationHttpGateway(dio);
      const resource = SignInRequestResource(
        email: 'user@example.com',
        password: 'WrongPassword123!',
      );

      // Act & Assert
      expect(
        () => gateway.signIn(resource),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 401)),
      );
    });

    test('should send POST to /google/sign-in and return AuthenticatedUserResource on success', () async {
      // Arrange
      late RequestOptions capturedOptions;
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return FakeHttpClientAdapter.jsonResponse({
          'id': 'google-user-id',
          'email': 'googleuser@example.com',
          'token': 'jwt-google-access',
          'refreshToken': 'jwt-google-refresh',
        });
      });
      final gateway = AuthenticationHttpGateway(dio);
      const resource = GoogleSignInRequestResource(idToken: 'google-token-val');

      // Act
      final result = await gateway.googleSignIn(resource);

      // Assert
      expect(capturedOptions.path, equals('/api/v1/auth/google/sign-in'));
      expect(capturedOptions.method, equals('POST'));
      expect(capturedOptions.data, equals({'idToken': 'google-token-val'}));
      expect(result.id, equals('google-user-id'));
      expect(result.token, equals('jwt-google-access'));
    });

    test('should throw DioException when googleSignIn fails', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        return FakeHttpClientAdapter.jsonResponse(
          {'error': 'Invalid token'},
          statusCode: 400,
        );
      });
      final gateway = AuthenticationHttpGateway(dio);
      const resource = GoogleSignInRequestResource(idToken: 'bad-token');

      // Act & Assert
      expect(
        () => gateway.googleSignIn(resource),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 400)),
      );
    });

    test('should send DELETE to /sign-out with Authorization header on success', () async {
      // Arrange
      late RequestOptions capturedOptions;
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return FakeHttpClientAdapter.jsonResponse(null, statusCode: 204);
      });
      final gateway = AuthenticationHttpGateway(dio);

      // Act
      await gateway.signOut('access-token-header');

      // Assert
      expect(capturedOptions.path, equals('/api/v1/auth/sign-out'));
      expect(capturedOptions.method, equals('DELETE'));
      expect(capturedOptions.headers['Authorization'], equals('Bearer access-token-header'));
    });

    test('should throw DioException when signOut fails', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        return FakeHttpClientAdapter.jsonResponse(
          {'error': 'Internal server error'},
          statusCode: 500,
        );
      });
      final gateway = AuthenticationHttpGateway(dio);

      // Act & Assert
      expect(
        () => gateway.signOut('access-token-header'),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 500)),
      );
    });

    test('should send POST to /refresh and return AuthenticatedUserResource on success', () async {
      // Arrange
      late RequestOptions capturedOptions;
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return FakeHttpClientAdapter.jsonResponse({
          'id': 'user-123',
          'email': 'user@example.com',
          'token': 'new-access-token',
          'refreshToken': 'new-refresh-token',
        });
      });
      final gateway = AuthenticationHttpGateway(dio);
      const resource = RefreshTokenRequestResource(refreshToken: 'current-refresh-token');

      // Act
      final result = await gateway.refreshToken(resource);

      // Assert
      expect(capturedOptions.path, equals('/api/v1/auth/refresh'));
      expect(capturedOptions.method, equals('POST'));
      expect(capturedOptions.data, equals({'refreshToken': 'current-refresh-token'}));
      expect(result.token, equals('new-access-token'));
      expect(result.refreshToken, equals('new-refresh-token'));
    });

    test('should throw DioException when refreshToken fails', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        return FakeHttpClientAdapter.jsonResponse(
          {'error': 'Expired refresh token'},
          statusCode: 401,
        );
      });
      final gateway = AuthenticationHttpGateway(dio);
      const resource = RefreshTokenRequestResource(refreshToken: 'expired-token');

      // Act & Assert
      expect(
        () => gateway.refreshToken(resource),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 401)),
      );
    });

    test('should send GET to /verify with Authorization header and return TokenVerificationResource', () async {
      // Arrange
      late RequestOptions capturedOptions;
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return FakeHttpClientAdapter.jsonResponse({
          'valid': true,
          'userId': 'verified-user-123',
          'expiresAt': '2026-10-02T18:00:00Z',
        });
      });
      final gateway = AuthenticationHttpGateway(dio);

      // Act
      final result = await gateway.verifyToken('valid-token-jwt');

      // Assert
      expect(capturedOptions.path, equals('/api/v1/auth/verify'));
      expect(capturedOptions.method, equals('GET'));
      expect(capturedOptions.headers['Authorization'], equals('Bearer valid-token-jwt'));
      expect(result.valid, isTrue);
      expect(result.userId, equals('verified-user-123'));
      expect(result.expiresAt, equals('2026-10-02T18:00:00Z'));
    });

    test('should throw DioException when verifyToken fails with 401', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        return FakeHttpClientAdapter.jsonResponse(
          {'error': 'Invalid or expired token'},
          statusCode: 401,
        );
      });
      final gateway = AuthenticationHttpGateway(dio);

      // Act & Assert
      expect(
        () => gateway.verifyToken('invalid-token-jwt'),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 401)),
      );
    });
  });
}
