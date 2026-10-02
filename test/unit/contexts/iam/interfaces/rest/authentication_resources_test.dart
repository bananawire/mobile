import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/interfaces/rest/resources/authenticated_user_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/confirm_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/google_sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/initiate_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/refresh_token_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/registration_initiated_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/token_verification_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/user_resource.resource.dart';

void main() {
  group('SignInRequestResource', () {
    test('should serialize correctly to json map when toJson is called', () {
      // Arrange
      const resource = SignInRequestResource(
        email: 'test@example.com',
        password: 'Password123!',
      );

      // Act
      final json = resource.toJson();

      // Assert
      expect(
        json,
        equals({'email': 'test@example.com', 'password': 'Password123!'}),
      );
    });
  });

  group('AuthenticatedUserResource', () {
    test(
      'should deserialize correctly from json map when fromJson is called',
      () {
        // Arrange
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'email': 'user@example.com',
          'token': 'access-token-123',
          'refreshToken': 'refresh-token-456',
        };

        // Act
        final resource = AuthenticatedUserResource.fromJson(json);

        // Assert
        expect(resource.id, equals('123e4567-e89b-12d3-a456-426614174000'));
        expect(resource.email, equals('user@example.com'));
        expect(resource.token, equals('access-token-123'));
        expect(resource.refreshToken, equals('refresh-token-456'));
      },
    );

    test('should serialize correctly to json map when toJson is called', () {
      // Arrange
      const resource = AuthenticatedUserResource(
        id: '123e4567-e89b-12d3-a456-426614174000',
        email: 'user@example.com',
        token: 'access-token-123',
        refreshToken: 'refresh-token-456',
      );

      // Act
      final json = resource.toJson();

      // Assert
      expect(
        json,
        equals({
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'email': 'user@example.com',
          'token': 'access-token-123',
          'refreshToken': 'refresh-token-456',
        }),
      );
    });
  });

  group('InitiateRegistrationRequestResource', () {
    test('should serialize correctly to json map when toJson is called', () {
      // Arrange
      const resource = InitiateRegistrationRequestResource(
        email: 'register@example.com',
        password: 'Password123!',
      );

      // Act
      final json = resource.toJson();

      // Assert
      expect(
        json,
        equals({'email': 'register@example.com', 'password': 'Password123!'}),
      );
    });
  });

  group('ConfirmRegistrationRequestResource', () {
    test('should serialize correctly to json map when toJson is called', () {
      // Arrange
      const resource = ConfirmRegistrationRequestResource(
        sessionId: 'session-id-123',
        verificationCode: 'CODE-1234',
      );

      // Act
      final json = resource.toJson();

      // Assert
      expect(
        json,
        equals({
          'sessionId': 'session-id-123',
          'verificationCode': 'CODE-1234',
        }),
      );
    });
  });

  group('RefreshTokenRequestResource', () {
    test('should serialize correctly to json map when toJson is called', () {
      // Arrange
      const resource = RefreshTokenRequestResource(refreshToken: 'token-xyz');

      // Act
      final json = resource.toJson();

      // Assert
      expect(json, equals({'refreshToken': 'token-xyz'}));
    });
  });

  group('RegistrationInitiatedResource', () {
    test(
      'should deserialize correctly from json map when fromJson is called',
      () {
        // Arrange
        final json = {
          'sessionId': 'session-123',
          'message': 'Registration initiated successfully',
        };

        // Act
        final resource = RegistrationInitiatedResource.fromJson(json);

        // Assert
        expect(resource.sessionId, equals('session-123'));
        expect(resource.message, equals('Registration initiated successfully'));
      },
    );

    test('should serialize correctly to json map when toJson is called', () {
      // Arrange
      const resource = RegistrationInitiatedResource(
        sessionId: 'session-123',
        message: 'Registration initiated successfully',
      );

      // Act
      final json = resource.toJson();

      // Assert
      expect(
        json,
        equals({
          'sessionId': 'session-123',
          'message': 'Registration initiated successfully',
        }),
      );
    });
  });

  group('TokenVerificationResource', () {
    test(
      'should deserialize correctly from json map with all fields present',
      () {
        // Arrange
        final json = {
          'valid': true,
          'userId': 'user-123',
          'expiresAt': '2026-12-31T23:59:59Z',
        };

        // Act
        final resource = TokenVerificationResource.fromJson(json);

        // Assert
        expect(resource.valid, isTrue);
        expect(resource.userId, equals('user-123'));
        expect(resource.expiresAt, equals('2026-12-31T23:59:59Z'));
      },
    );

    test('should deserialize correctly when optional fields are null', () {
      // Arrange
      final json = {'valid': false, 'userId': null, 'expiresAt': null};

      // Act
      final resource = TokenVerificationResource.fromJson(json);

      // Assert
      expect(resource.valid, isFalse);
      expect(resource.userId, isNull);
      expect(resource.expiresAt, isNull);
    });

    test('should serialize correctly to json map when toJson is called', () {
      // Arrange
      const resource = TokenVerificationResource(
        valid: true,
        userId: 'user-123',
        expiresAt: '2026-12-31T23:59:59Z',
      );

      // Act
      final json = resource.toJson();

      // Assert
      expect(
        json,
        equals({
          'valid': true,
          'userId': 'user-123',
          'expiresAt': '2026-12-31T23:59:59Z',
        }),
      );
    });
  });

  group('UserResource', () {
    test(
      'should deserialize correctly from json map when fromJson is called',
      () {
        // Arrange
        final json = {'id': 'user-uuid-123', 'email': 'user@example.com'};

        // Act
        final resource = UserResource.fromJson(json);

        // Assert
        expect(resource.id, equals('user-uuid-123'));
        expect(resource.email, equals('user@example.com'));
      },
    );

    test('should serialize correctly to json map when toJson is called', () {
      // Arrange
      const resource = UserResource(
        id: 'user-uuid-123',
        email: 'user@example.com',
      );

      // Act
      final json = resource.toJson();

      // Assert
      expect(
        json,
        equals({'id': 'user-uuid-123', 'email': 'user@example.com'}),
      );
    });
  });

  group('GoogleSignInRequestResource', () {
    test('should serialize correctly to json map when toJson is called', () {
      // Arrange
      const resource = GoogleSignInRequestResource(idToken: 'google-token-xyz');

      // Act
      final json = resource.toJson();

      // Assert
      expect(json, equals({'idToken': 'google-token-xyz'}));
    });
  });
}
