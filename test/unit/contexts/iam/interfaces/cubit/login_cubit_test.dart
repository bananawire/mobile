import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/authenticate_with_google.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_in.command.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/infrastructure/oauth/google/google_id_token_provider.dart';
import 'package:mobile/iam/interfaces/pages/login/login_cubit.dart';
import 'package:mobile/iam/interfaces/rest/resources/authenticated_user_resource.resource.dart';

class MockAuthenticationCommandService extends Mock implements AuthenticationCommandService {}
class MockGoogleIdTokenProvider extends Mock implements GoogleIdTokenProvider {}
class FakeSignInCommand extends Fake implements SignInCommand {}
class FakeAuthenticateWithGoogleCommand extends Fake implements AuthenticateWithGoogleCommand {}

void main() {
  late MockAuthenticationCommandService mockCommandService;
  late MockGoogleIdTokenProvider mockGoogleProvider;

  const sampleUser = AuthenticatedUserResource(
    id: 'user-id-123',
    email: 'user@example.com',
    token: 'jwt-access-token',
    refreshToken: 'jwt-refresh-token',
  );

  setUpAll(() {
    registerFallbackValue(FakeSignInCommand());
    registerFallbackValue(FakeAuthenticateWithGoogleCommand());
  });

  setUp(() {
    mockCommandService = MockAuthenticationCommandService();
    mockGoogleProvider = MockGoogleIdTokenProvider();
  });

  group('LoginCubit', () {
    test('should have initial state with default values', () {
      final cubit = LoginCubit(mockCommandService, mockGoogleProvider);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.isSuccess, isFalse);
    });

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, success] when signIn succeeds',
      build: () {
        when(() => mockCommandService.handleSignIn(any()))
            .thenAnswer((_) async => const Right(sampleUser));
        return LoginCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.signIn(email: 'user@example.com', password: 'Password123!'),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isSuccess, 'isSuccess', isTrue),
      ],
      verify: (_) {
        verify(() => mockCommandService.handleSignIn(any())).called(1);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, failure] when handleSignIn returns Failure',
      build: () {
        when(() => mockCommandService.handleSignIn(any()))
            .thenAnswer((_) async => const Left(Failure('Invalid email or password.')));
        return LoginCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.signIn(email: 'user@example.com', password: 'Password123!'),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', 'Invalid email or password.')
            .having((s) => s.isSuccess, 'isSuccess', isFalse),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, error] when email is invalid (ArgumentError)',
      build: () => LoginCubit(mockCommandService, mockGoogleProvider),
      act: (cubit) => cubit.signIn(email: 'invalid-email', password: 'Password123!'),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', contains('Invalid email address format')),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, error] when password is invalid (ArgumentError)',
      build: () => LoginCubit(mockCommandService, mockGoogleProvider),
      act: (cubit) => cubit.signIn(email: 'user@example.com', password: 'short'),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', contains('Password must be between 8 and 128 characters')),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, error] when an unexpected exception is thrown',
      build: () {
        when(() => mockCommandService.handleSignIn(any()))
            .thenThrow(Exception('Network timeout'));
        return LoginCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.signIn(email: 'user@example.com', password: 'Password123!'),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', contains('Network timeout')),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, success] when signInWithGoogle succeeds',
      build: () {
        when(() => mockGoogleProvider.fetchIdToken())
            .thenAnswer((_) async => 'google-token-xyz');
        when(() => mockCommandService.handleAuthenticateWithGoogle(any()))
            .thenAnswer((_) async => const Right(sampleUser));
        return LoginCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isSuccess, 'isSuccess', isTrue),
      ],
      verify: (_) {
        verify(() => mockGoogleProvider.fetchIdToken()).called(1);
        verify(() => mockCommandService.handleAuthenticateWithGoogle(any())).called(1);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, failure] when handleAuthenticateWithGoogle returns Failure',
      build: () {
        when(() => mockGoogleProvider.fetchIdToken())
            .thenAnswer((_) async => 'google-token-xyz');
        when(() => mockCommandService.handleAuthenticateWithGoogle(any()))
            .thenAnswer((_) async => const Left(Failure('Google sign-in rejected')));
        return LoginCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', 'Google sign-in rejected'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, error] when google token is empty (ArgumentError)',
      build: () {
        when(() => mockGoogleProvider.fetchIdToken()).thenAnswer((_) async => '');
        return LoginCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', contains('Google ID token is required')),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, error] when fetchIdToken throws Exception',
      build: () {
        when(() => mockGoogleProvider.fetchIdToken())
            .thenThrow(Exception('User cancelled Google login'));
        return LoginCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', contains('User cancelled Google login')),
      ],
    );
  });
}
