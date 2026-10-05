import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/authenticate_with_google.command.dart';
import 'package:mobile/iam/domain/model/commands/confirm_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/initiate_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/refresh_token.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_in.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/domain/model/queries/verify_token.query.dart';
import 'package:mobile/iam/domain/model/valueobjects/access_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/email_address.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/google_id_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/password.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/refresh_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/session_id.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/user_id.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/verification_code.valueobject.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/domain/services/authentication.query-service.dart';
import 'package:mobile/iam/infrastructure/api/gateways/authentication.gateway.dart';
import 'package:mobile/iam/infrastructure/oauth/google/google_id_token_provider.dart';
import 'package:mobile/iam/infrastructure/persistence/local/registration_session_local_storage.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:mobile/iam/interfaces/rest/resources/authenticated_user_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/confirm_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/google_sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/initiate_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/refresh_token_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/registration_initiated_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/token_verification_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/user_resource.resource.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationGateway extends Mock implements AuthenticationGateway {}

class MockAuthenticationCommandService extends Mock
    implements AuthenticationCommandService {}

class MockAuthenticationQueryService extends Mock
    implements AuthenticationQueryService {}

class MockTokenLocalStorage extends Mock implements TokenLocalStorage {}

class MockRegistrationSessionLocalStorage extends Mock
    implements RegistrationSessionLocalStorage {}

class MockGoogleIdTokenProvider extends Mock implements GoogleIdTokenProvider {}

/// Canonical sample data reused across the `iam` unit tests.
class IamFixtures {
  static const userId = '3f2504e0-4f89-41d3-9a0c-0305e82c3301';
  static const email = 'ada.lovelace@example.com';
  static const password = 'Str0ng@Pass';
  static const sessionId = '9f8c1b2a-3d4e-4f50-8a6b-7c8d9e0f1a2b';
  static const verificationCode = 'A1B2-C3D4';
  static const accessToken = 'access-token-value';
  static const refreshToken = 'refresh-token-value';
  static const googleIdToken = 'google-id-token-value';

  static const authenticatedUser = AuthenticatedUserResource(
    id: userId,
    email: email,
    token: accessToken,
    refreshToken: refreshToken,
  );

  static const registrationInitiated = RegistrationInitiatedResource(
    sessionId: sessionId,
    message: 'A verification code was sent to your email.',
  );

  static const user = UserResource(id: userId, email: email);

  static const validTokenVerification = TokenVerificationResource(
    valid: true,
    userId: userId,
    expiresAt: '2026-01-01T00:00:00Z',
  );

  static const invalidTokenVerification = TokenVerificationResource(valid: false);

  static final signInRequest = const SignInRequestResource(
    email: email,
    password: password,
  );

  static final initiateRegistrationRequest =
      const InitiateRegistrationRequestResource(
    email: email,
    password: password,
  );

  static final confirmRegistrationRequest =
      const ConfirmRegistrationRequestResource(
    sessionId: sessionId,
    verificationCode: verificationCode,
  );

  static const refreshTokenRequest = RefreshTokenRequestResource(
    refreshToken: refreshToken,
  );

  static const googleSignInRequest = GoogleSignInRequestResource(
    idToken: googleIdToken,
  );

  static SignInCommand signInCommand() => SignInCommand(
        email: EmailAddress(email),
        password: Password(password),
      );

  static InitiateRegistrationCommand initiateRegistrationCommand() =>
      InitiateRegistrationCommand(
        email: EmailAddress(email),
        password: Password(password),
      );

  static ConfirmRegistrationCommand confirmRegistrationCommand() =>
      ConfirmRegistrationCommand(
        sessionId: SessionId(sessionId),
        verificationCode: VerificationCode(verificationCode),
      );

  static SignOutCommand signOutCommand() => SignOutCommand(
        accessToken: AccessToken(accessToken),
      );

  static RefreshTokenCommand refreshTokenCommand() => RefreshTokenCommand(
        refreshToken: RefreshToken(refreshToken),
      );

  static AuthenticateWithGoogleCommand googleCommand() =>
      AuthenticateWithGoogleCommand(idToken: GoogleIdToken(googleIdToken));

  static VerifyTokenQuery verifyTokenQuery() => VerifyTokenQuery(
        accessToken: AccessToken(accessToken),
      );

  static UserId userIdVo() => UserId(userId);
}

/// Registers the non-nullable fallback values used by `any()` / `captureAny()`.
void registerIamFallbackValues() {
  registerFallbackValue(IamFixtures.signInCommand());
  registerFallbackValue(IamFixtures.signOutCommand());
  registerFallbackValue(IamFixtures.refreshTokenCommand());
  registerFallbackValue(IamFixtures.googleCommand());
  registerFallbackValue(IamFixtures.initiateRegistrationCommand());
  registerFallbackValue(IamFixtures.confirmRegistrationCommand());
  registerFallbackValue(IamFixtures.verifyTokenQuery());
  registerFallbackValue(IamFixtures.signInRequest);
  registerFallbackValue(IamFixtures.initiateRegistrationRequest);
  registerFallbackValue(IamFixtures.confirmRegistrationRequest);
  registerFallbackValue(IamFixtures.refreshTokenRequest);
  registerFallbackValue(IamFixtures.googleSignInRequest);
}
/// Returns the [Failure] of a [Left] and fails loudly when the result is a `Right`.
Failure expectLeftFailure<T>(Either<Failure, T> result) {
  if (result case Left<Failure, T>(value: final failure)) {
    return failure;
  }
  throw TestFailure('expected a Left but got <${result as Right<Failure, T>}>');
}

/// Returns the value of a [Right] and fails loudly when the result is a `Left`.
T expectRightValue<T>(Either<Failure, T> result) {
  if (result case Right<Failure, T>(value: final value)) {
    return value;
  }
  throw TestFailure('expected a Right but got <${expectLeftFailure(result)}>');
}
