import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/iam/infrastructure/api/gateways/authentication.gateway.dart';
import 'package:mobile/iam/interfaces/rest/resources/authenticated_user_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/confirm_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/google_sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/initiate_registration_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/refresh_token_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/registration_initiated_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/sign_in_request.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/token_verification_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/user_resource.resource.dart';

class AuthenticationHttpGateway implements AuthenticationGateway {
  final Dio _dio;

  AuthenticationHttpGateway(this._dio);

  @override
  Future<RegistrationInitiatedResource> initiateRegistration(
    InitiateRegistrationRequestResource resource,
  ) async {
    final response = await _dio.post(
      '${ApiConstants.authBase}/sign-up',
      data: resource.toJson(),
    );
    return RegistrationInitiatedResource.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserResource> confirmRegistration(
    ConfirmRegistrationRequestResource resource,
  ) async {
    final response = await _dio.post(
      '${ApiConstants.authBase}/confirm',
      data: resource.toJson(),
    );
    return UserResource.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthenticatedUserResource> signIn(SignInRequestResource resource) async {
    final response = await _dio.post(
      '${ApiConstants.authBase}/sign-in',
      data: resource.toJson(),
    );
    return AuthenticatedUserResource.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthenticatedUserResource> googleSignIn(GoogleSignInRequestResource resource) async {
    final response = await _dio.post(
      '${ApiConstants.authBase}/google/sign-in',
      data: resource.toJson(),
    );
    return AuthenticatedUserResource.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> signOut(String accessToken) async {
    await _dio.delete(
      '${ApiConstants.authBase}/sign-out',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
  }

  @override
  Future<AuthenticatedUserResource> refreshToken(
    RefreshTokenRequestResource resource,
  ) async {
    final response = await _dio.post(
      '${ApiConstants.authBase}/refresh',
      data: resource.toJson(),
    );
    return AuthenticatedUserResource.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TokenVerificationResource> verifyToken(String accessToken) async {
    final response = await _dio.get(
      '${ApiConstants.authBase}/verify',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
    return TokenVerificationResource.fromJson(response.data as Map<String, dynamic>);
  }
}
