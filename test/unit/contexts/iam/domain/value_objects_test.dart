import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/domain/model/valueobjects/access_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/email_address.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/google_id_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/password.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/refresh_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/session_id.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/user_id.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/verification_code.valueobject.dart';

void main() {
  group('EmailAddress', () {
    test('should create EmailAddress when format is valid', () {
      // Arrange
      const validEmail = 'user@example.com';

      // Act
      final email = EmailAddress(validEmail);

      // Assert
      expect(email.address, equals(validEmail));
      expect(email.toString(), equals(validEmail));
    });

    test('should create EmailAddress with subdomains and dots', () {
      // Arrange
      const validEmail = 'john.doe@sub.company.org';

      // Act
      final email = EmailAddress(validEmail);

      // Assert
      expect(email.address, equals(validEmail));
    });

    test('should throw ArgumentError when email is empty', () {
      // Arrange & Act & Assert
      expect(
        () => EmailAddress(''),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Email address cannot be empty'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when email format is invalid', () {
      // Arrange
      const invalidEmails = [
        'plainaddress',
        '@missingusername.com',
        'username@.com',
        'username@domain',
        'username@domain..com',
        'user space@domain.com',
      ];

      // Act & Assert
      for (final invalid in invalidEmails) {
        expect(
          () => EmailAddress(invalid),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Invalid email address format'),
            ),
          ),
          reason: 'Failed for invalid email: $invalid',
        );
      }
    });
  });

  group('Password', () {
    test('should create Password when complexity requirements are met', () {
      // Arrange
      const validPassword = 'SecurePassword123!';

      // Act
      final password = Password(validPassword);

      // Assert
      expect(password.value, equals(validPassword));
      expect(password.toString(), equals(validPassword));
    });

    test('should throw ArgumentError when password is empty', () {
      // Arrange & Act & Assert
      expect(
        () => Password(''),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Password cannot be empty'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when password is shorter than 8 characters', () {
      // Arrange
      const shortPassword = 'Aa1!';

      // Act & Assert
      expect(
        () => Password(shortPassword),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Password must be between 8 and 128 characters'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when password is longer than 128 characters', () {
      // Arrange
      final longPassword = 'A' * 126 + 'a1!'; // 129 chars

      // Act & Assert
      expect(
        () => Password(longPassword),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Password must be between 8 and 128 characters'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when password lacks uppercase letter', () {
      // Arrange
      const noUpper = 'securepassword123!';

      // Act & Assert
      expect(
        () => Password(noUpper),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('uppercase letter'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when password lacks lowercase letter', () {
      // Arrange
      const noLower = 'SECUREPASSWORD123!';

      // Act & Assert
      expect(
        () => Password(noLower),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('lowercase letter'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when password lacks number', () {
      // Arrange
      const noNumber = 'SecurePassword!!!!';

      // Act & Assert
      expect(
        () => Password(noNumber),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('one number'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when password lacks special character', () {
      // Arrange
      const noSpecial = 'SecurePassword123';

      // Act & Assert
      expect(
        () => Password(noSpecial),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('special character'),
          ),
        ),
      );
    });
  });

  group('VerificationCode', () {
    test('should create VerificationCode when format is valid XXXX-XXXX', () {
      // Arrange
      const validCode = 'A1B2-C3D4';

      // Act
      final code = VerificationCode(validCode);

      // Assert
      expect(code.code, equals(validCode));
      expect(code.toString(), equals(validCode));
    });

    test('should throw ArgumentError when verification code is empty', () {
      // Arrange & Act & Assert
      expect(
        () => VerificationCode(''),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Verification code cannot be empty'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when verification code format is invalid', () {
      // Arrange
      const invalidCodes = [
        'a1b2-c3d4', // lowercase
        'A1B2C3D4', // missing hyphen
        'A1B-C3D4', // first group too short
        'A1B2-C3D', // second group too short
        'A1B2-C3D45', // second group too long
        'A1B@-C3D4', // special character
      ];

      // Act & Assert
      for (final invalid in invalidCodes) {
        expect(
          () => VerificationCode(invalid),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Verification code must be in format XXXX-XXXX'),
            ),
          ),
          reason: 'Failed for invalid code: $invalid',
        );
      }
    });
  });

  group('AccessToken', () {
    test('should create AccessToken when token string is non-empty', () {
      // Arrange
      const rawToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

      // Act
      final token = AccessToken(rawToken);

      // Assert
      expect(token.token, equals(rawToken));
      expect(token.toString(), equals(rawToken));
    });

    test('should throw ArgumentError when token is empty', () {
      // Arrange & Act & Assert
      expect(
        () => AccessToken(''),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Access token cannot be empty'),
          ),
        ),
      );
    });
  });

  group('RefreshToken', () {
    test('should create RefreshToken when token string is non-empty', () {
      // Arrange
      const rawToken = 'refresh-token-xyz-123';

      // Act
      final token = RefreshToken(rawToken);

      // Assert
      expect(token.token, equals(rawToken));
      expect(token.toString(), equals(rawToken));
    });

    test('should throw ArgumentError when token is empty', () {
      // Arrange & Act & Assert
      expect(
        () => RefreshToken(''),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Refresh token cannot be empty'),
          ),
        ),
      );
    });
  });

  group('UserId', () {
    test('should create UserId when id is a valid UUID', () {
      // Arrange
      const validUuid = '123e4567-e89b-12d3-a456-426614174000';

      // Act
      final userId = UserId(validUuid);

      // Assert
      expect(userId.id, equals(validUuid));
      expect(userId.toString(), equals(validUuid));
    });

    test('should throw ArgumentError when user id is empty', () {
      // Arrange & Act & Assert
      expect(
        () => UserId(''),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('User ID cannot be empty'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when user id is not a valid UUID', () {
      // Arrange
      const nonUuid = 'user-not-a-uuid-1234';

      // Act & Assert
      expect(
        () => UserId(nonUuid),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('User ID must be a valid UUID'),
          ),
        ),
      );
    });
  });

  group('SessionId', () {
    test('should create SessionId when id is a valid UUID', () {
      // Arrange
      const validUuid = '987fcdeb-51a2-43f7-9abc-123456789abc';

      // Act
      final sessionId = SessionId(validUuid);

      // Assert
      expect(sessionId.id, equals(validUuid));
      expect(sessionId.toString(), equals(validUuid));
    });

    test('should throw ArgumentError when session id is empty', () {
      // Arrange & Act & Assert
      expect(
        () => SessionId(''),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Session ID cannot be empty'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when session id is not a valid UUID', () {
      // Arrange
      const nonUuid = 'not-a-valid-session-uuid';

      // Act & Assert
      expect(
        () => SessionId(nonUuid),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Session ID must be a valid UUID'),
          ),
        ),
      );
    });
  });

  group('GoogleIdToken', () {
    test('should create GoogleIdToken when token is valid and non-empty', () {
      // Arrange
      const validToken = 'valid.google.id.token';

      // Act
      final googleToken = GoogleIdToken(validToken);

      // Assert
      expect(googleToken.token, equals(validToken));
    });

    test('should throw ArgumentError when token is empty', () {
      // Arrange & Act & Assert
      expect(
        () => GoogleIdToken(''),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Google ID token is required'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when token contains only whitespace', () {
      // Arrange & Act & Assert
      expect(
        () => GoogleIdToken('   '),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Google ID token is required'),
          ),
        ),
      );
    });
  });
}
