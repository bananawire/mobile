import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/confirm_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/authenticate_with_google.command.dart';
import 'package:mobile/iam/domain/model/commands/initiate_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/refresh_token.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_in.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/interfaces/rest/resources/authenticated_user_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/registration_initiated_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/user_resource.resource.dart';

abstract class AuthenticationCommandService {
  Future<Either<Failure, RegistrationInitiatedResource>> handleInitiateRegistration(
    InitiateRegistrationCommand command,
  );

  Future<Either<Failure, UserResource>> handleConfirmRegistration(
    ConfirmRegistrationCommand command,
  );

  Future<Either<Failure, AuthenticatedUserResource>> handleSignIn(
    SignInCommand command,
  );

  Future<Either<Failure, AuthenticatedUserResource>> handleAuthenticateWithGoogle(
    AuthenticateWithGoogleCommand command,
  );

  Future<Either<Failure, Unit>> handleSignOut(
    SignOutCommand command,
  );

  Future<Either<Failure, AuthenticatedUserResource>> handleRefreshToken(
    RefreshTokenCommand command,
  );
}
