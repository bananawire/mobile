import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/domain/model/queries/verify_token.query.dart';
import 'package:mobile/iam/domain/model/valueobjects/access_token.valueobject.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/domain/services/authentication.query-service.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final AuthenticationCommandService _commandService;
  final AuthenticationQueryService _queryService;
  final TokenLocalStorage _localStorage;

  DashboardCubit(
    this._commandService,
    this._queryService,
    this._localStorage,
  ) : super(const DashboardState());

  Future<void> loadSession() async {
    emit(state.copyWith(isLoading: true));

    final token = await _localStorage.getAccessToken();
    final email = await _localStorage.getEmail();

    if (token == null || token.isEmpty) {
      emit(state.copyWith(isLoading: false, isAuthenticated: false));
      return;
    }

    final query = VerifyTokenQuery(accessToken: AccessToken(token));
    final result = await _queryService.handleVerifyToken(query);

    result.fold(
      (failure) {
        AuthSession().setAuthenticated(false);
        emit(state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        AuthSession().setAuthenticated(true);
        emit(state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          email: email,
        ));
      },
    );
  }

  Future<void> signOut() async {
    emit(state.copyWith(isLoading: true));

    final token = await _localStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final command = SignOutCommand(accessToken: AccessToken(token));
      await _commandService.handleSignOut(command);
    }

    emit(state.copyWith(isLoading: false, isAuthenticated: false));
  }
}
