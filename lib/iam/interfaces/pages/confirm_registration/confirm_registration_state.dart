part of 'confirm_registration_cubit.dart';

class ConfirmRegistrationState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ConfirmRegistrationState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ConfirmRegistrationState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ConfirmRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
