import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/domain/model/valueobjects/access_token.valueobject.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final AuthenticationCommandService _commandService;
  final TokenLocalStorage _localStorage;

  SettingsCubit(
    this._commandService,
    this._localStorage,
  ) : super(const SettingsState());

  Future<void> signOut() async {
    emit(state.copyWith(isLoading: true));

    final token = await _localStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final command = SignOutCommand(accessToken: AccessToken(token));
      await _commandService.handleSignOut(command);
    }

    await _localStorage.clearAll();

    emit(state.copyWith(isLoading: false, isAuthenticated: false));
  }
}
