import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/interfaces/rest/resources/authenticated_user_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/registration_initiated_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/token_verification_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/user_resource.resource.dart';

import '../helpers/iam_test_doubles.dart';

void main() {
  group('AuthenticatedUserResource.fromJson', () {
    test('should map every field of a well formed payload', () {
      // Arrange
      const json = <String, dynamic>{
        'id': '3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        'email': 'ada.lovelace@example.com',
        'token': 'access-token-value',
        'refreshToken': 'refresh-token-value',
      };

      // Act
      final resource = AuthenticatedUserResource.fromJson(json);

      // Assert
      expect(resource.id, json['id']);
      expect(resource.email, json['email']);
      expect(resource.token, json['token']);
      expect(resource.refreshToken, json['refreshToken']);
    });

    test('should ignore unknown extra fields', () {
      // Arrange
      const json = <String, dynamic>{
        'id': '3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        'email': 'ada.lovelace@example.com',
        'token': 'access-token-value',
        'refreshToken': 'refresh-token-value',
        'role': 'admin',
      };

      // Act
      final resource = AuthenticatedUserResource.fromJson(json);

      // Assert
      expect(resource.toJson().keys, ['id', 'email', 'token', 'refreshToken']);
    });

    test('should throw a type error when a required field is missing', () {
      // Arrange
      const missing = <String, dynamic>{
        'email': 'ada.lovelace@example.com',
        'token': 'access-token-value',
        'refreshToken': 'refresh-token-value',
      };

      // Act
      AuthenticatedUserResource create() => AuthenticatedUserResource.fromJson(missing);

      // Assert
      expect(create, throwsA(isA<TypeError>()));
    });

    test('should throw a type error when a required field has the wrong type', () {
      // Arrange
      const wrongType = <String, dynamic>{
        'id': 42,
        'email': 'ada.lovelace@example.com',
        'token': 'access-token-value',
        'refreshToken': 'refresh-token-value',
      };

      // Act
      AuthenticatedUserResource create() => AuthenticatedUserResource.fromJson(wrongType);

      // Assert
      expect(create, throwsA(isA<TypeError>()));
    });
  });

  group('UserResource.fromJson', () {
    test('should map every field of a well formed payload', () {
      // Arrange
      const json = <String, dynamic>{
        'id': '3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        'email': 'ada.lovelace@example.com',
      };

      // Act
      final resource = UserResource.fromJson(json);

      // Assert
      expect(resource.id, json['id']);
      expect(resource.email, json['email']);
    });

    test('should throw a type error when the id is missing', () {
      // Arrange
      const missing = <String, dynamic>{'email': 'ada.lovelace@example.com'};

      // Act
      UserResource create() => UserResource.fromJson(missing);

      // Assert
      expect(create, throwsA(isA<TypeError>()));
    });

    test('should throw a type error when the email has the wrong type', () {
      // Arrange
      const wrongType = <String, dynamic>{
        'id': '3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        'email': 123,
      };

      // Act
      UserResource create() => UserResource.fromJson(wrongType);

      // Assert
      expect(create, throwsA(isA<TypeError>()));
    });
  });

  group('RegistrationInitiatedResource.fromJson', () {
    test('should map every field of a well formed payload', () {
      // Arrange
      const json = <String, dynamic>{
        'sessionId': '9f8c1b2a-3d4e-4f50-8a6b-7c8d9e0f1a2b',
        'message': 'A verification code was sent to your email.',
      };

      // Act
      final resource = RegistrationInitiatedResource.fromJson(json);

      // Assert
      expect(resource.sessionId, json['sessionId']);
      expect(resource.message, json['message']);
    });

    test('should throw a type error when the message is missing', () {
      // Arrange
      const missing = <String, dynamic>{
        'sessionId': '9f8c1b2a-3d4e-4f50-8a6b-7c8d9e0f1a2b',
      };

      // Act
      RegistrationInitiatedResource create() => RegistrationInitiatedResource.fromJson(missing);

      // Assert
      expect(create, throwsA(isA<TypeError>()));
    });
  });

  group('TokenVerificationResource.fromJson', () {
    test('should map every field of a well formed payload', () {
      // Arrange
      const json = <String, dynamic>{
        'valid': true,
        'userId': '3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        'expiresAt': '2026-01-01T00:00:00Z',
      };

      // Act
      final resource = TokenVerificationResource.fromJson(json);

      // Assert
      expect(resource.valid, isTrue);
      expect(resource.userId, json['userId']);
      expect(resource.expiresAt, json['expiresAt']);
    });

    test('should leave the optional fields null when they are absent', () {
      // Arrange
      const json = <String, dynamic>{'valid': false};

      // Act
      final resource = TokenVerificationResource.fromJson(json);

      // Assert
      expect(resource.valid, isFalse);
      expect(resource.userId, isNull);
      expect(resource.expiresAt, isNull);
    });

    test('should leave the optional fields null when they are explicitly null', () {
      // Arrange
      const json = <String, dynamic>{
        'valid': false,
        'userId': null,
        'expiresAt': null,
      };

      // Act
      final resource = TokenVerificationResource.fromJson(json);

      // Assert
      expect(resource.userId, isNull);
      expect(resource.expiresAt, isNull);
    });

    test('should throw a type error when the valid flag is missing', () {
      // Arrange
      const missing = <String, dynamic>{'userId': 'id'};

      // Act
      TokenVerificationResource create() => TokenVerificationResource.fromJson(missing);

      // Assert
      expect(create, throwsA(isA<TypeError>()));
    });

    test('should throw a type error when the valid flag is a string', () {
      // Arrange
      const wrongType = <String, dynamic>{'valid': 'true'};

      // Act
      TokenVerificationResource create() => TokenVerificationResource.fromJson(wrongType);

      // Assert
      expect(create, throwsA(isA<TypeError>()));
    });

    test('should keep the expiresAt value as the raw string without parsing', () {
      // Arrange
      const json = <String, dynamic>{
        'valid': true,
        'expiresAt': 'not-a-timestamp',
      };

      // Act
      final resource = TokenVerificationResource.fromJson(json);

      // Assert
      expect(resource.expiresAt, 'not-a-timestamp');
    });

    test('should expose the optional fields as null in toJson', () {
      // Arrange
      const resource = TokenVerificationResource(valid: false);

      // Act
      final json = resource.toJson();

      // Assert
      expect(json, <String, dynamic>{
        'valid': false,
        'userId': null,
        'expiresAt': null,
      });
    });
  });

  group('AuthenticatedUserResource.toJson', () {
    test('should emit exactly the documented response keys', () {
      // Act
      final json = IamFixtures.authenticatedUser.toJson();

      // Assert
      expect(json, <String, dynamic>{
        'id': IamFixtures.userId,
        'email': IamFixtures.email,
        'token': IamFixtures.accessToken,
        'refreshToken': IamFixtures.refreshToken,
      });
    });
  });
}