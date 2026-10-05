import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/confirm_registration.command.dart';
import 'package:mobile/iam/interfaces/pages/confirm_registration/confirm_registration_cubit.dart';
import 'package:mobile/iam/interfaces/rest/resources/user_resource.resource.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/iam_test_doubles.dart';

void main() {
  late MockAuthenticationCommandService commandService;
  late MockRegistrationSessionLocalStorage registrationStorage;
  late ConfirmRegistrationCubit cubit;

  const missingSessionMessage = 'Registration session not found. Please sign up again.';

  setUpAll(registerIamFallbackValues);

  setUp(() {
    commandService = MockAuthenticationCommandService();
    registrationStorage = MockRegistrationSessionLocalStorage();
    cubit = ConfirmRegistrationCubit(commandService, registrationStorage);
  });

  tearDown(() => cubit.close());

  test('should start idle, without error and without success', () {
    // Assert
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.isSuccess, isFalse);
  });

  group('ConfirmRegistrationCubit.confirmRegistration', () {
    blocTest<ConfirmRegistrationCubit, ConfirmRegistrationState>(
      'should flag loading and then success when the code is accepted',
      setUp: () {
        when(() => registrationStorage.getSessionId())
            .thenAnswer((_) async => IamFixtures.sessionId);
        when(() => commandService.handleConfirmRegistration(any()))
            .thenAnswer((_) async => Right(IamFixtures.user));
      },
      build: () => cubit,
      act: (cubit) => cubit.confirmRegistration(
        verificationCode: IamFixtures.verificationCode,
      ),
      expect: () => [
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isSuccess, 'isSuccess', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
      verify: (_) {
        final command = verify(
          () => commandService.handleConfirmRegistration(captureAny()),
        ).captured.single as ConfirmRegistrationCommand;
        expect(command.sessionId.id, IamFixtures.sessionId);
        expect(command.verificationCode.code, IamFixtures.verificationCode);
      },
    );

    blocTest<ConfirmRegistrationCubit, ConfirmRegistrationState>(
      'should report a missing registration session and skip the command service',
      setUp: () {
        when(() => registrationStorage.getSessionId()).thenAnswer((_) async => null);
      },
      build: () => cubit,
      act: (cubit) => cubit.confirmRegistration(
        verificationCode: IamFixtures.verificationCode,
      ),
      expect: () => [
        isA<ConfirmRegistrationState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', missingSessionMessage)
            .having((s) => s.isSuccess, 'isSuccess', isFalse),
      ],
      verify: (_) => verifyNever(() => commandService.handleConfirmRegistration(any())),
    );

    blocTest<ConfirmRegistrationCubit, ConfirmRegistrationState>(
      'should report a missing registration session when the stored id is blank',
      setUp: () {
        when(() => registrationStorage.getSessionId()).thenAnswer((_) async => '   ');
      },
      build: () => cubit,
      act: (cubit) => cubit.confirmRegistration(
        verificationCode: IamFixtures.verificationCode,
      ),
      expect: () => [
        isA<ConfirmRegistrationState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ConfirmRegistrationState>()
            .having((s) => s.errorMessage, 'errorMessage', missingSessionMessage),
      ],
      verify: (_) => verifyNever(() => commandService.handleConfirmRegistration(any())),
    );

    blocTest<ConfirmRegistrationCubit, ConfirmRegistrationState>(
      'should not reach the command service when the stored session id is not a UUID',
      setUp: () {
        when(() => registrationStorage.getSessionId()).thenAnswer((_) async => 'session-1');
      },
      build: () => cubit,
      act: (cubit) => cubit.confirmRegistration(
        verificationCode: IamFixtures.verificationCode,
      ),
      expect: () => [
        isA<ConfirmRegistrationState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ConfirmRegistrationState>()
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Session ID must be a valid UUID',
            ),
      ],
      verify: (_) => verifyNever(() => commandService.handleConfirmRegistration(any())),
    );

    blocTest<ConfirmRegistrationCubit, ConfirmRegistrationState>(
      'should not reach the command service when the verification code is malformed',
      setUp: () {
        when(() => registrationStorage.getSessionId())
            .thenAnswer((_) async => IamFixtures.sessionId);
      },
      build: () => cubit,
      act: (cubit) => cubit.confirmRegistration(verificationCode: '1234'),
      expect: () => [
        isA<ConfirmRegistrationState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ConfirmRegistrationState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Verification code must be in format XXXX-XXXX (uppercase alphanumeric)',
        ),
      ],
      verify: (_) => verifyNever(() => commandService.handleConfirmRegistration(any())),
    );

    blocTest<ConfirmRegistrationCubit, ConfirmRegistrationState>(
      'should report the failure message when the backend rejects the code',
      setUp: () {
        when(() => registrationStorage.getSessionId())
            .thenAnswer((_) async => IamFixtures.sessionId);
        when(() => commandService.handleConfirmRegistration(any()))
            .thenAnswer((_) async => const Left(Failure('Invalid data. Please check your input.')));
      },
      build: () => cubit,
      act: (cubit) => cubit.confirmRegistration(
        verificationCode: IamFixtures.verificationCode,
      ),
      expect: () => [
        isA<ConfirmRegistrationState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ConfirmRegistrationState>()
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Invalid data. Please check your input.',
            )
            .having((s) => s.isSuccess, 'isSuccess', isFalse),
      ],
    );

    test('should keep loading while the confirmation request is pending', () async {
      // Arrange
      when(() => registrationStorage.getSessionId())
          .thenAnswer((_) async => IamFixtures.sessionId);
      final completer = Completer<Either<Failure, UserResource>>();
      when(() => commandService.handleConfirmRegistration(any()))
          .thenAnswer((_) => completer.future);

      // Act
      final pending =
          cubit.confirmRegistration(verificationCode: IamFixtures.verificationCode);
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(cubit.state.isLoading, isTrue);

      // Act
      completer.complete(Right(IamFixtures.user));
      await pending;

      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isSuccess, isTrue);
    });

    test(
      'should surface the raw message when the storage throws unexpectedly',
      () async {
        // Arrange
        when(() => registrationStorage.getSessionId())
            .thenThrow(StateError('storage unavailable'));

        // Act
        await cubit.confirmRegistration(
          verificationCode: IamFixtures.verificationCode,
        );

        // Assert
        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.errorMessage, contains('storage unavailable'));
      },
    );
  });
}