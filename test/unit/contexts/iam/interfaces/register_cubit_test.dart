import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/initiate_registration.command.dart';
import 'package:mobile/iam/interfaces/pages/register/register_cubit.dart';
import 'package:mobile/iam/interfaces/rest/resources/registration_initiated_resource.resource.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/iam_test_doubles.dart';

void main() {
  late MockAuthenticationCommandService commandService;
  late MockGoogleIdTokenProvider googleIdTokenProvider;
  late RegisterCubit cubit;

  setUpAll(registerIamFallbackValues);

  setUp(() {
    commandService = MockAuthenticationCommandService();
    googleIdTokenProvider = MockGoogleIdTokenProvider();
    cubit = RegisterCubit(commandService, googleIdTokenProvider);
  });

  tearDown(() => cubit.close());

  test('should start idle, without session id, error and success', () {
    // Assert
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.sessionId, isNull);
    expect(cubit.state.isSuccess, isFalse);
  });

  group('RegisterCubit.initiateRegistration', () {
    blocTest<RegisterCubit, RegisterState>(
      'should expose the session id returned by the backend',
      setUp: () {
        when(() => commandService.handleInitiateRegistration(any()))
            .thenAnswer((_) async => Right(IamFixtures.registrationInitiated));
      },
      build: () => cubit,
      act: (cubit) => cubit.initiateRegistration(
        email: IamFixtures.email,
        password: IamFixtures.password,
      ),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.sessionId, 'sessionId', IamFixtures.sessionId)
            .having((s) => s.isSuccess, 'isSuccess', isFalse),
      ],
      verify: (_) {
        final command = verify(
          () => commandService.handleInitiateRegistration(captureAny()),
        ).captured.single as InitiateRegistrationCommand;
        expect(command.email.address, IamFixtures.email);
        expect(command.password.value, IamFixtures.password);
      },
    );

    blocTest<RegisterCubit, RegisterState>(
      'should report the failure message when the email is already registered',
      setUp: () {
        when(() => commandService.handleInitiateRegistration(any()))
            .thenAnswer((_) async => const Left(Failure('User already exists.')));
      },
      build: () => cubit,
      act: (cubit) => cubit.initiateRegistration(
        email: IamFixtures.email,
        password: IamFixtures.password,
      ),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.errorMessage, 'errorMessage', 'User already exists.')
            .having((s) => s.sessionId, 'sessionId', isNull),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'should not reach the command service when the email is malformed',
      build: () => cubit,
      act: (cubit) => cubit.initiateRegistration(
        email: 'ada@',
        password: IamFixtures.password,
      ),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Invalid email address format',
        ),
      ],
      verify: (_) => verifyNever(() => commandService.handleInitiateRegistration(any())),
    );

    blocTest<RegisterCubit, RegisterState>(
      'should not reach the command service when the password has no special character',
      build: () => cubit,
      act: (cubit) => cubit.initiateRegistration(
        email: IamFixtures.email,
        password: 'Str0ngPassw0rd',
      ),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('special character'),
        ),
      ],
      verify: (_) => verifyNever(() => commandService.handleInitiateRegistration(any())),
    );

    blocTest<RegisterCubit, RegisterState>(
      'should clear the previous error when a new submission is started',
      setUp: () {
        var call = 0;
        when(() => commandService.handleInitiateRegistration(any())).thenAnswer((_) async {
          call++;
          if (call == 1) {
            return const Left(Failure('User already exists.'));
          }
          return Right(IamFixtures.registrationInitiated);
        });
      },
      build: () => cubit,
      act: (cubit) async {
        await cubit.initiateRegistration(
          email: IamFixtures.email,
          password: IamFixtures.password,
        );
        await cubit.initiateRegistration(
          email: IamFixtures.email,
          password: IamFixtures.password,
        );
      },
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.errorMessage, 'errorMessage', 'User already exists.'),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<RegisterState>()
            .having((s) => s.errorMessage, 'errorMessage', isNull)
            .having((s) => s.sessionId, 'sessionId', IamFixtures.sessionId),
      ],
    );

    test('should keep loading while the registration request is pending', () async {
      // Arrange
      final completer = Completer<Either<Failure, RegistrationInitiatedResource>>();
      when(() => commandService.handleInitiateRegistration(any()))
          .thenAnswer((_) => completer.future);

      // Act
      final pending = cubit.initiateRegistration(
        email: IamFixtures.email,
        password: IamFixtures.password,
      );
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(cubit.state.isLoading, isTrue);

      // Act
      completer.complete(Right(IamFixtures.registrationInitiated));
      await pending;

      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.sessionId, IamFixtures.sessionId);
    });
  });

  group('RegisterCubit.signUpWithGoogle', () {
    blocTest<RegisterCubit, RegisterState>(
      'should flag success when the backend accepts the id token',
      setUp: () {
        when(() => googleIdTokenProvider.fetchIdToken())
            .thenAnswer((_) async => IamFixtures.googleIdToken);
        when(() => commandService.handleAuthenticateWithGoogle(any()))
            .thenAnswer((_) async => Right(IamFixtures.authenticatedUser));
      },
      build: () => cubit,
      act: (cubit) => cubit.signUpWithGoogle(),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isSuccess, 'isSuccess', isTrue),
      ],
      verify: (_) {
        verify(() => googleIdTokenProvider.fetchIdToken()).called(1);
        verify(() => commandService.handleAuthenticateWithGoogle(any())).called(1);
      },
    );

    blocTest<RegisterCubit, RegisterState>(
      'should prefix the provider error when the user cancels the google flow',
      setUp: () {
        when(() => googleIdTokenProvider.fetchIdToken())
            .thenThrow(Exception('Google sign-in was cancelled'));
      },
      build: () => cubit,
      act: (cubit) => cubit.signUpWithGoogle(),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isSuccess, 'isSuccess', isFalse)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              startsWith('Google Sign-Up failed: '),
            ),
      ],
      verify: (_) =>
          verifyNever(() => commandService.handleAuthenticateWithGoogle(any())),
    );

    blocTest<RegisterCubit, RegisterState>(
      'should report the backend failure without the prefix when the command returns a failure',
      setUp: () {
        when(() => googleIdTokenProvider.fetchIdToken())
            .thenAnswer((_) async => IamFixtures.googleIdToken);
        when(() => commandService.handleAuthenticateWithGoogle(any()))
            .thenAnswer((_) async => const Left(Failure('User already exists.')));
      },
      build: () => cubit,
      act: (cubit) => cubit.signUpWithGoogle(),
      expect: () => [
        isA<RegisterState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<RegisterState>()
            .having((s) => s.errorMessage, 'errorMessage', 'User already exists.'),
      ],
    );
  });
}