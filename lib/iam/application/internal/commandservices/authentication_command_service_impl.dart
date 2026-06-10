import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/confirm_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/authenticate_with_google.command.dart';
import 'package:mobile/iam/domain/model/commands/initiate_registration.command.dart';
import 'package:mobile/iam/domain/model/commands/refresh_token.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_in.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/infrastructure/api/gateways/authentication.gateway.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mobile/iam/infrastructure/persistence/local/registration_session_local_storage.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:mobile/iam/interfaces/rest/resources/authenticated_user_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/registration_initiated_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/user_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/transform/authentication_transform.dart';

class AuthenticationCommandServiceImpl implements AuthenticationCommandService {
  final AuthenticationGateway _gateway;
  final TokenLocalStorage _localStorage;
  final RegistrationSessionLocalStorage _registrationSessionLocalStorage;

  AuthenticationCommandServiceImpl(
    this._gateway,
    this._localStorage,
    this._registrationSessionLocalStorage,
  );

  @override
  Future<Either<Failure, RegistrationInitiatedResource>> handleInitiateRegistration(
    InitiateRegistrationCommand command,
  ) async {
    try {
      final resource = toInitiateRegistrationResource(command);
      final result = await _gateway.initiateRegistration(resource);
      await _registrationSessionLocalStorage.saveSessionId(result.sessionId);
      return Right(result);
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, UserResource>> handleConfirmRegistration(
    ConfirmRegistrationCommand command,
  ) async {
    try {
      final resource = toConfirmRegistrationResource(command);
      final result = await _gateway.confirmRegistration(resource);
      await _registrationSessionLocalStorage.clearSessionId();
      return Right(result);
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, AuthenticatedUserResource>> handleSignIn(
    SignInCommand command,
  ) async {
    try {
      final resource = toSignInResource(command);
      final result = await _gateway.signIn(resource);
      await _localStorage.saveTokens(
        accessToken: result.token,
        refreshToken: result.refreshToken,
      );
      await _localStorage.saveUser(userId: result.id, email: result.email);
      AuthSession().setAuthenticated(true);
      return Right(result);
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, AuthenticatedUserResource>> handleAuthenticateWithGoogle(
    AuthenticateWithGoogleCommand command,
  ) async {
    try {
      final resource = toGoogleSignInResource(command);
      final result = await _gateway.googleSignIn(resource);
      await _localStorage.saveTokens(
        accessToken: result.token,
        refreshToken: result.refreshToken,
      );
      await _localStorage.saveUser(userId: result.id, email: result.email);
      AuthSession().setAuthenticated(true);
      return Right(result);
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> handleSignOut(SignOutCommand command) async {
    try {
      await _gateway.signOut(command.accessToken.token);
      await _localStorage.clearAll();
      AuthSession().setAuthenticated(false);
      return const Right(unit);
    } catch (e) {
      await _localStorage.clearAll();
      AuthSession().setAuthenticated(false);
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, AuthenticatedUserResource>> handleRefreshToken(
    RefreshTokenCommand command,
  ) async {
    try {
      final resource = toRefreshTokenResource(command);
      final result = await _gateway.refreshToken(resource);
      await _localStorage.saveTokens(
        accessToken: result.token,
        refreshToken: result.refreshToken,
      );
      await _localStorage.saveUser(userId: result.id, email: result.email);
      AuthSession().setAuthenticated(true);
      return Right(result);
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  String _mapError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Invalid email or password.';
        case 403:
          return 'Access denied. Please contact support.';
        case 404:
          return 'User not found.';
        case 409:
          return 'User already exists.';
        case 422:
          return 'Invalid data. Please check your input.';
        case 500:
        case 502:
        case 503:
          return 'Server error. Please try again later.';
        default:
          return 'Network error. Please check your connection.';
      }
    }
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
