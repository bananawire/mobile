import 'package:mobile/iam/interfaces/rest/resources/authenticated_user_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/confirm_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/google_sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/initiate_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/refresh_token_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/registration_initiated_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/token_verification_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/user_resource.resource.dart';

abstract class AuthenticationGateway {
  Future<RegistrationInitiatedResource> initiateRegistration(
    InitiateRegistrationRequestResource resource,
  );

  Future<UserResource> confirmRegistration(
    ConfirmRegistrationRequestResource resource,
  );

  Future<AuthenticatedUserResource> signIn(SignInRequestResource resource);

  Future<AuthenticatedUserResource> googleSignIn(GoogleSignInRequestResource resource);

  Future<void> signOut(String accessToken);

  Future<AuthenticatedUserResource> refreshToken(
    RefreshTokenRequestResource resource,
  );

  Future<TokenVerificationResource> verifyToken(String accessToken);
}
