import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/iam/domain/model/commands/authenticate_with_google.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_in.command.dart';
import 'package:mobile/iam/domain/model/valueobjects/google_id_token.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/email_address.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/password.valueobject.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/infrastructure/oauth/google/google_id_token_provider.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthenticationCommandService _commandService;
  final GoogleIdTokenProvider _googleIdTokenProvider;

  LoginCubit(
    this._commandService,
    this._googleIdTokenProvider,
  ) : super(const LoginState());

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final emailVo = EmailAddress(email);
      final passwordVo = Password(password);
      final command = SignInCommand(email: emailVo, password: passwordVo);

      final result = await _commandService.handleSignIn(command);

      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (_) => emit(state.copyWith(isLoading: false, isSuccess: true)),
      );
    } on ArgumentError catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message as String?));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final idToken = await _googleIdTokenProvider.fetchIdToken();
      final command = AuthenticateWithGoogleCommand(idToken: GoogleIdToken(idToken));
      final result = await _commandService.handleAuthenticateWithGoogle(command);

      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (_) => emit(state.copyWith(isLoading: false, isSuccess: true)),
      );
    } on ArgumentError catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message as String?));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
