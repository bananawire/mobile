import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/confirm_registration.command.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/infrastructure/persistence/local/registration_session_local_storage.dart';
import 'package:mobile/iam/interfaces/pages/confirm_registration/confirm_registration_cubit.dart';
import 'package:mobile/iam/interfaces/rest/resources/user_resource.resource.dart';

class MockAuthenticationCommandService extends Mock implements AuthenticationCommandService {}
class MockRegistrationSessionLocalStorage extends Mock implements RegistrationSessionLocalStorage {}
class FakeConfirmRegistrationCommand extends Fake implements ConfirmRegistrationCommand {}

void main() {
  late MockAuthenticationCommandService mockCommandService;
  late MockRegistrationSessionLocalStorage mockRegistrationStorage;

  const validSessionUuid = '123e4567-e89b-12d3-a456-426614174000';
  const sampleUserResource = UserResource(
    id: validSessionUuid,
    email: 'user@example.com',
  );

  setUpAll(() {
    registerFallbackValue(FakeConfirmRegistrationCommand());
  });

  setUp(() {
    mockCommandService = MockAuthenticationCommandService();
    mockRegistrationStorage = MockRegistrationSessionLocalStorage();
  });

  group('ConfirmRegistrationCubit', () {
    test('should have initial state with default values', () {
      final cubit = ConfirmRegistrationCubit(mockCommandService, mockRegistrationStorage);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.isSuccess, isFalse);
    });

    blocTest<ConfirmRegistrationCubit, ConfirmRegistrationState>(
      'should emit error when sessionId is null in storage',
      build: () {
        when(() => mockRegistrationStorage.getSessionId()).thenAnswer((_) async => null);
        return ConfirmRegistrationCubit(mockCommandService, mockRegistrationStorage);
      },
      act: (cubit) => cubit.confirmRegistration(verificationCode: 'ABCD-1234'),
      expect: () => [
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', 'Registration session not found. Please sign up again.'),
      ],
    );

    blocTest<ConfirmRegistrationCubit, ConfirmRegistrationState>(
      'should emit error when sessionId is whitespace in storage',
      build: () {
        when(() => mockRegistrationStorage.getSessionId()).thenAnswer((_) async => '   ');
        return ConfirmRegistrationCubit(mockCommandService, mockRegistrationStorage);
      },
      act: (cubit) => cubit.confirmRegistration(verificationCode: 'ABCD-1234'),
      expect: () => [
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', 'Registration session not found. Please sign up again.'),
      ],
    );

    blocTest<ConfirmRegistrationCubit, ConfirmRegistrationState>(
      'should emit error when verification code has invalid format (ArgumentError)',
      build: () {
        when(() => mockRegistrationStorage.getSessionId()).thenAnswer((_) async => validSessionUuid);
        return ConfirmRegistrationCubit(mockCommandService, mockRegistrationStorage);
      },
      act: (cubit) => cubit.confirmRegistration(verificationCode: 'invalid_code'),
      expect: () => [
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', contains('Verification code must be in format XXXX-XXXX')),
      ],
    );

    blocTest<ConfirmRegistrationCubit, ConfirmRegistrationState>(
      'should emit [loading, success] when handleConfirmRegistration succeeds',
      build: () {
        when(() => mockRegistrationStorage.getSessionId()).thenAnswer((_) async => validSessionUuid);
        when(() => mockCommandService.handleConfirmRegistration(any()))
            .thenAnswer((_) async => const Right(sampleUserResource));
        return ConfirmRegistrationCubit(mockCommandService, mockRegistrationStorage);
      },
      act: (cubit) => cubit.confirmRegistration(verificationCode: 'ABCD-1234'),
      expect: () => [
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isSuccess, 'isSuccess', isTrue),
      ],
      verify: (_) {
        verify(() => mockCommandService.handleConfirmRegistration(any())).called(1);
      },
    );

    blocTest<ConfirmRegistrationCubit, ConfirmRegistrationState>(
      'should emit [loading, failure] when handleConfirmRegistration returns Failure',
      build: () {
        when(() => mockRegistrationStorage.getSessionId()).thenAnswer((_) async => validSessionUuid);
        when(() => mockCommandService.handleConfirmRegistration(any()))
            .thenAnswer((_) async => const Left(Failure('Invalid verification code.')));
        return ConfirmRegistrationCubit(mockCommandService, mockRegistrationStorage);
      },
      act: (cubit) => cubit.confirmRegistration(verificationCode: 'ABCD-1234'),
      expect: () => [
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', 'Invalid verification code.'),
      ],
    );

    blocTest<ConfirmRegistrationCubit, ConfirmRegistrationState>(
      'should emit [loading, error] when unexpected exception occurs',
      build: () {
        when(() => mockRegistrationStorage.getSessionId())
            .thenThrow(Exception('Storage error'));
        return ConfirmRegistrationCubit(mockCommandService, mockRegistrationStorage);
      },
      act: (cubit) => cubit.confirmRegistration(verificationCode: 'ABCD-1234'),
      expect: () => [
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ConfirmRegistrationState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', contains('Storage error')),
      ],
    );
  });
}
