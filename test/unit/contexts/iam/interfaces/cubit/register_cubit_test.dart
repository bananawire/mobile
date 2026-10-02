import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/authenticate_with_google.command.dart';
import 'package:mobile/iam/domain/model/commands/initiate_registration.command.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/infrastructure/oauth/google/google_id_token_provider.dart';
import 'package:mobile/iam/interfaces/pages/register/register_cubit.dart';
import 'package:mobile/iam/interfaces/rest/resources/authenticated_user_resource.resource.dart';
import 'package:mobile/iam/interfaces/rest/resources/registration_initiated_resource.resource.dart';

class MockAuthenticationCommandService extends Mock
    implements AuthenticationCommandService {}

class MockGoogleIdTokenProvider extends Mock implements GoogleIdTokenProvider {}

class FakeInitiateRegistrationCommand extends Fake
    implements InitiateRegistrationCommand {}

class FakeAuthenticateWithGoogleCommand extends Fake
    implements AuthenticateWithGoogleCommand {}

void main() {
  late MockAuthenticationCommandService mockCommandService;
  late MockGoogleIdTokenProvider mockGoogleProvider;

  const sampleInitiatedResource = RegistrationInitiatedResource(
    sessionId: 'session-uuid-1234',
    message: 'Verification code sent',
  );

  const sampleAuthUser = AuthenticatedUserResource(
    id: 'google-user-id',
    email: 'google@example.com',
    token: 'jwt-access-google',
    refreshToken: 'jwt-refresh-google',
  );

  setUpAll(() {
    registerFallbackValue(FakeInitiateRegistrationCommand());
    registerFallbackValue(FakeAuthenticateWithGoogleCommand());
  });

  setUp(() {
    mockCommandService = MockAuthenticationCommandService();
    mockGoogleProvider = MockGoogleIdTokenProvider();
  });

  group('RegisterCubit', () {
    test('should have initial state with default values', () {
      final cubit = RegisterCubit(mockCommandService, mockGoogleProvider);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.sessionId, isNull);
      expect(cubit.state.isSuccess, isFalse);
    });

    blocTest<RegisterCubit, RegisterState>(
      'should emit [loading, sessionId set] when initiateRegistration succeeds',
      build: () {
        when(
          () => mockCommandService.handleInitiateRegistration(any()),
        ).thenAnswer((_) async => const Right(sampleInitiatedResource));
        return RegisterCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.initiateRegistration(
        email: 'newuser@example.com',
        password: 'Password123!',
      ),
      expect: () => [
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.sessionId, 'sessionId', 'session-uuid-1234'),
      ],
      verify: (_) {
        verify(
          () => mockCommandService.handleInitiateRegistration(any()),
        ).called(1);
      },
    );

    blocTest<RegisterCubit, RegisterState>(
      'should emit [loading, failure] when handleInitiateRegistration returns Failure',
      build: () {
        when(
          () => mockCommandService.handleInitiateRegistration(any()),
        ).thenAnswer((_) async => const Left(Failure('User already exists.')));
        return RegisterCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.initiateRegistration(
        email: 'existing@example.com',
        password: 'Password123!',
      ),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'User already exists.',
            ),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'should emit [loading, error] when email is invalid (ArgumentError)',
      build: () => RegisterCubit(mockCommandService, mockGoogleProvider),
      act: (cubit) => cubit.initiateRegistration(
        email: 'invalid-email',
        password: 'Password123!',
      ),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Invalid email address format'),
            ),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'should emit [loading, error] when password does not meet requirements (ArgumentError)',
      build: () => RegisterCubit(mockCommandService, mockGoogleProvider),
      act: (cubit) => cubit.initiateRegistration(
        email: 'valid@example.com',
        password: 'no-special-char1',
      ),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('special character'),
            ),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'should emit [loading, error] when initiateRegistration encounters unexpected exception',
      build: () {
        when(
          () => mockCommandService.handleInitiateRegistration(any()),
        ).thenThrow(Exception('Unexpected registration failure'));
        return RegisterCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.initiateRegistration(
        email: 'valid@example.com',
        password: 'Password123!',
      ),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Unexpected registration failure'),
            ),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'should emit [loading, success] when signUpWithGoogle succeeds',
      build: () {
        when(
          () => mockGoogleProvider.fetchIdToken(),
        ).thenAnswer((_) async => 'google-token-xyz');
        when(
          () => mockCommandService.handleAuthenticateWithGoogle(any()),
        ).thenAnswer((_) async => const Right(sampleAuthUser));
        return RegisterCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.signUpWithGoogle(),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isSuccess, 'isSuccess', isTrue),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'should emit [loading, failure] when handleAuthenticateWithGoogle fails during signUpWithGoogle',
      build: () {
        when(
          () => mockGoogleProvider.fetchIdToken(),
        ).thenAnswer((_) async => 'google-token-xyz');
        when(
          () => mockCommandService.handleAuthenticateWithGoogle(any()),
        ).thenAnswer(
          (_) async => const Left(Failure('Google sign-up rejected')),
        );
        return RegisterCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.signUpWithGoogle(),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Google sign-up rejected',
            ),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'should emit [loading, error] when signUpWithGoogle throws exception',
      build: () {
        when(
          () => mockGoogleProvider.fetchIdToken(),
        ).thenThrow(Exception('Provider unavailable'));
        return RegisterCubit(mockCommandService, mockGoogleProvider);
      },
      act: (cubit) => cubit.signUpWithGoogle(),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Google Sign-Up failed:'),
            ),
      ],
    );
  });
}
