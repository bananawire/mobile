part of 'register_cubit.dart';

class RegisterState {
  final bool isLoading;
  final String? errorMessage;
  final String? sessionId;
  final bool isSuccess;

  const RegisterState({
    this.isLoading = false,
    this.errorMessage,
    this.sessionId,
    this.isSuccess = false,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? sessionId,
    bool? isSuccess,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      sessionId: sessionId ?? this.sessionId,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
