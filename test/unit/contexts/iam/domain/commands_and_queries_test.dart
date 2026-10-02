import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/domain/model/commands/authenticate_with_google.command.dart';
import 'package:mobile/iam/domain/model/commands/confirm_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/initiate_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/refresh_token.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_in.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/domain/model/events/user_signed_in.event.dart';
import 'package:mobile/iam/domain/model/events/user_signed_out.event.dart';
import 'package:mobile/iam/domain/model/queries/verify_token.query.dart';
import 'package:mobile/iam/domain/model/valueobjects/access_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/email_address.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/google_id_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/password.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/refresh_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/session_id.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/user_id.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/verification_code.valueobject.dart';

void main() {
  group('SignInCommand', () {
    test('should hold valid email and password when instantiated', () {
      // Arrange
      final email = EmailAddress('user@example.com');
      final password = Password('Password123!');

      // Act
      final command = SignInCommand(email: email, password: password);

      // Assert
      expect(command.email, equals(email));
      expect(command.password, equals(password));
    });
  });

  group('InitiateRegistrationCommand', () {
    test('should hold valid email and password when instantiated', () {
      // Arrange
      final email = EmailAddress('newuser@example.com');
      final password = Password('Password123!');

      // Act
      final command = InitiateRegistrationCommand(email: email, password: password);

      // Assert
      expect(command.email, equals(email));
      expect(command.password, equals(password));
    });
  });

  group('ConfirmRegistrationCommand', () {
    test('should hold valid sessionId and verificationCode when instantiated', () {
      // Arrange
      final sessionId = SessionId('123e4567-e89b-12d3-a456-426614174000');
      final code = VerificationCode('A1B2-C3D4');

      // Act
      final command = ConfirmRegistrationCommand(sessionId: sessionId, verificationCode: code);

      // Assert
      expect(command.sessionId, equals(sessionId));
      expect(command.verificationCode, equals(code));
    });
  });

  group('AuthenticateWithGoogleCommand', () {
    test('should hold valid google idToken when instantiated', () {
      // Arrange
      final idToken = GoogleIdToken('google-mock-id-token');

      // Act
      final command = AuthenticateWithGoogleCommand(idToken: idToken);

      // Assert
      expect(command.idToken, equals(idToken));
    });
  });

  group('RefreshTokenCommand', () {
    test('should hold valid refreshToken when instantiated', () {
      // Arrange
      final refreshToken = RefreshToken('sample-refresh-token');

      // Act
      final command = RefreshTokenCommand(refreshToken: refreshToken);

      // Assert
      expect(command.refreshToken, equals(refreshToken));
    });
  });

  group('SignOutCommand', () {
    test('should hold valid accessToken when instantiated', () {
      // Arrange
      final accessToken = AccessToken('sample-access-token');

      // Act
      final command = SignOutCommand(accessToken: accessToken);

      // Assert
      expect(command.accessToken, equals(accessToken));
    });
  });

  group('VerifyTokenQuery', () {
    test('should hold valid accessToken when instantiated', () {
      // Arrange
      final accessToken = AccessToken('sample-access-token');

      // Act
      final query = VerifyTokenQuery(accessToken: accessToken);

      // Assert
      expect(query.accessToken, equals(accessToken));
    });
  });

  group('UserSignedInEvent', () {
    test('should contain userId, email, and occurredOn when instantiated', () {
      // Arrange
      final userId = UserId('123e4567-e89b-12d3-a456-426614174000');
      const email = 'user@example.com';
      final occurredOn = DateTime(2026, 1, 1, 12, 0, 0);

      // Act
      final event = UserSignedInEvent(
        userId: userId,
        email: email,
        occurredOn: occurredOn,
      );

      // Assert
      expect(event.userId, equals(userId));
      expect(event.email, equals(email));
      expect(event.occurredOn, equals(occurredOn));
    });
  });

  group('UserSignedOutEvent', () {
    test('should contain userId and occurredOn when instantiated', () {
      // Arrange
      final userId = UserId('123e4567-e89b-12d3-a456-426614174000');
      final occurredOn = DateTime(2026, 1, 1, 13, 0, 0);

      // Act
      final event = UserSignedOutEvent(
        userId: userId,
        occurredOn: occurredOn,
      );

      // Assert
      expect(event.userId, equals(userId));
      expect(event.occurredOn, equals(occurredOn));
    });
  });
}
