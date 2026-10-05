import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/interfaces/rest/transform/authentication_transform.dart';

import '../helpers/iam_test_doubles.dart';

void main() {
  group('toInitiateRegistrationResource', () {
    test('should serialize the command into the sign-up request body', () {
      // Arrange
      final command = IamFixtures.initiateRegistrationCommand();

      // Act
      final resource = toInitiateRegistrationResource(command);

      // Assert
      expect(resource.toJson(), <String, dynamic>{
        'email': IamFixtures.email,
        'password': IamFixtures.password,
      });
    });
  });

  group('toConfirmRegistrationResource', () {
    test('should serialize the command into the confirm request body', () {
      // Arrange
      final command = IamFixtures.confirmRegistrationCommand();

      // Act
      final resource = toConfirmRegistrationResource(command);

      // Assert
      expect(resource.toJson(), <String, dynamic>{
        'sessionId': IamFixtures.sessionId,
        'verificationCode': IamFixtures.verificationCode,
      });
    });
  });

  group('toSignInResource', () {
    test('should serialize the command into the sign-in request body', () {
      // Arrange
      final command = IamFixtures.signInCommand();

      // Act
      final resource = toSignInResource(command);

      // Assert
      expect(resource.toJson(), <String, dynamic>{
        'email': IamFixtures.email,
        'password': IamFixtures.password,
      });
    });
  });

  group('toRefreshTokenResource', () {
    test('should serialize the command into the refresh request body', () {
      // Arrange
      final command = IamFixtures.refreshTokenCommand();

      // Act
      final resource = toRefreshTokenResource(command);

      // Assert
      expect(resource.toJson(), <String, dynamic>{
        'refreshToken': IamFixtures.refreshToken,
      });
    });
  });

  group('toGoogleSignInResource', () {
    test('should serialize the command into the google sign-in request body', () {
      // Arrange
      final command = IamFixtures.googleCommand();

      // Act
      final resource = toGoogleSignInResource(command);

      // Assert
      expect(resource.toJson(), <String, dynamic>{
        'idToken': IamFixtures.googleIdToken,
      });
    });
  });

  group('request resource serialization against explicit fixtures', () {
    test('should produce exactly the wire field names the backend expects', () {
      // Arrange
      final signInJson = toSignInResource(IamFixtures.signInCommand()).toJson();
      final signUpJson =
          toInitiateRegistrationResource(IamFixtures.initiateRegistrationCommand()).toJson();
      final confirmJson =
          toConfirmRegistrationResource(IamFixtures.confirmRegistrationCommand()).toJson();
      final refreshJson =
          toRefreshTokenResource(IamFixtures.refreshTokenCommand()).toJson();
      final googleJson = toGoogleSignInResource(IamFixtures.googleCommand()).toJson();

      // Act
      final keys = <String, List<String>>{
        'signIn': signInJson.keys.toList(),
        'initiateRegistration': signUpJson.keys.toList(),
        'confirmRegistration': confirmJson.keys.toList(),
        'refreshToken': refreshJson.keys.toList(),
        'googleSignIn': googleJson.keys.toList(),
      };

      // Assert
      expect(keys, <String, List<String>>{
        'signIn': ['email', 'password'],
        'initiateRegistration': ['email', 'password'],
        'confirmRegistration': ['sessionId', 'verificationCode'],
        'refreshToken': ['refreshToken'],
        'googleSignIn': ['idToken'],
      });
    });
  });
}