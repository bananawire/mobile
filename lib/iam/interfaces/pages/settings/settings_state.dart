part of 'settings_cubit.dart';

class SettingsState {
  final bool isLoading;
  final bool isAuthenticated;

  const SettingsState({
    this.isLoading = false,
    this.isAuthenticated = true,
  });

  SettingsState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
