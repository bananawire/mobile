import 'package:mobile/iam/domain/model/commands/confirm_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/authenticate_with_google.command.dart';
import 'package:mobile/iam/domain/model/commands/initiate_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/refresh_token.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_in.command.dart';
import 'package:mobile/iam/interfaces/rest/resources/confirm_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/google_sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/initiate_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/refresh_token_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/sign_in_request.resource.dart';

InitiateRegistrationRequestResource toInitiateRegistrationResource(
  InitiateRegistrationCommand command,
) {
  return InitiateRegistrationRequestResource(
    email: command.email.address,
    password: command.password.value,
  );
}

ConfirmRegistrationRequestResource toConfirmRegistrationResource(
  ConfirmRegistrationCommand command,
) {
  return ConfirmRegistrationRequestResource(
    sessionId: command.sessionId.id,
    verificationCode: command.verificationCode.code,
  );
}

SignInRequestResource toSignInResource(SignInCommand command) {
  return SignInRequestResource(
    email: command.email.address,
    password: command.password.value,
  );
}

RefreshTokenRequestResource toRefreshTokenResource(RefreshTokenCommand command) {
  return RefreshTokenRequestResource(
    refreshToken: command.refreshToken.token,
  );
}

GoogleSignInRequestResource toGoogleSignInResource(AuthenticateWithGoogleCommand command) {
  return GoogleSignInRequestResource(idToken: command.idToken.token);
}
