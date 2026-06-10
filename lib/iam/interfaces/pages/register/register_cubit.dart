import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/iam/domain/model/commands/authenticate_with_google.command.dart';
import 'package:mobile/iam/domain/model/commands/initiate_registration.command.dart';
import 'package:mobile/iam/domain/model/valueobjects/email_address.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/google_id_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/password.valueobject.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/infrastructure/oauth/google/google_id_token_provider.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthenticationCommandService _commandService;
  final GoogleIdTokenProvider _googleIdTokenProvider;

  RegisterCubit(this._commandService, this._googleIdTokenProvider) : super(const RegisterState());

  Future<void> initiateRegistration({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final emailVo = EmailAddress(email);
      final passwordVo = Password(password);
      final command = InitiateRegistrationCommand(email: emailVo, password: passwordVo);

      final result = await _commandService.handleInitiateRegistration(command);

      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (resource) => emit(state.copyWith(isLoading: false, sessionId: resource.sessionId)),
      );
    } on ArgumentError catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message as String?));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> signUpWithGoogle() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final idToken = await _googleIdTokenProvider.fetchIdToken();
      final command = AuthenticateWithGoogleCommand(idToken: GoogleIdToken(idToken));
      
      final result = await _commandService.handleAuthenticateWithGoogle(command);

      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        // Assuming Google sign-in directly authenticates and doesn't need confirmation
        (resource) => emit(state.copyWith(isLoading: false, isSuccess: true)),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Google Sign-Up failed: ${e.toString()}'));
    }
  }
}
