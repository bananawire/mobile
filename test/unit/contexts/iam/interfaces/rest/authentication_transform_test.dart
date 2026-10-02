import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/domain/model/commands/authenticate_with_google.command.dart';
import 'package:mobile/iam/domain/model/commands/confirm_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/initiate_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/refresh_token.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_in.command.dart';
import 'package:mobile/iam/domain/model/valueobjects/email_address.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/google_id_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/password.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/refresh_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/session_id.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/verification_code.valueobject.dart';
import 'package:mobile/iam/interfaces/rest/transform/authentication_transform.dart';

void main() {
  group('AuthenticationTransform', () {
    test(
      'should map InitiateRegistrationCommand to InitiateRegistrationRequestResource',
      () {
        // Arrange
        final command = InitiateRegistrationCommand(
          email: EmailAddress('user@example.com'),
          password: Password('Secret123!'),
        );

        // Act
        final resource = toInitiateRegistrationResource(command);

        // Assert
        expect(resource.email, equals('user@example.com'));
        expect(resource.password, equals('Secret123!'));
      },
    );

    test(
      'should map ConfirmRegistrationCommand to ConfirmRegistrationRequestResource',
      () {
        // Arrange
        final command = ConfirmRegistrationCommand(
          sessionId: SessionId('123e4567-e89b-12d3-a456-426614174000'),
          verificationCode: VerificationCode('1A2B-3C4D'),
        );

        // Act
        final resource = toConfirmRegistrationResource(command);

        // Assert
        expect(
          resource.sessionId,
          equals('123e4567-e89b-12d3-a456-426614174000'),
        );
        expect(resource.verificationCode, equals('1A2B-3C4D'));
      },
    );

    test('should map SignInCommand to SignInRequestResource', () {
      // Arrange
      final command = SignInCommand(
        email: EmailAddress('login@example.com'),
        password: Password('Passwd987!'),
      );

      // Act
      final resource = toSignInResource(command);

      // Assert
      expect(resource.email, equals('login@example.com'));
      expect(resource.password, equals('Passwd987!'));
    });

    test('should map RefreshTokenCommand to RefreshTokenRequestResource', () {
      // Arrange
      final command = RefreshTokenCommand(
        refreshToken: RefreshToken('ref-tok-999'),
      );

      // Act
      final resource = toRefreshTokenResource(command);

      // Assert
      expect(resource.refreshToken, equals('ref-tok-999'));
    });

    test(
      'should map AuthenticateWithGoogleCommand to GoogleSignInRequestResource',
      () {
        // Arrange
        final command = AuthenticateWithGoogleCommand(
          idToken: GoogleIdToken('google-id-token-abc'),
        );

        // Act
        final resource = toGoogleSignInResource(command);

        // Assert
        expect(resource.idToken, equals('google-id-token-abc'));
      },
    );
  });
}
