part of 'dashboard_cubit.dart';

class DashboardState {
  final bool isLoading;
  final String? errorMessage;
  final String? email;
  final bool isAuthenticated;

  const DashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.email,
    this.isAuthenticated = false,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? email,
    bool? isAuthenticated,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      email: email ?? this.email,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
