import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:mobile/iam/interfaces/pages/settings/settings_cubit.dart';

class MockAuthenticationCommandService extends Mock
    implements AuthenticationCommandService {}

class MockTokenLocalStorage extends Mock implements TokenLocalStorage {}

class FakeSignOutCommand extends Fake implements SignOutCommand {}

void main() {
  late MockAuthenticationCommandService mockCommandService;
  late MockTokenLocalStorage mockLocalStorage;

  setUpAll(() {
    registerFallbackValue(FakeSignOutCommand());
  });

  setUp(() {
    mockCommandService = MockAuthenticationCommandService();
    mockLocalStorage = MockTokenLocalStorage();
  });

  group('SettingsCubit', () {
    test(
      'should have initial state with isLoading false and isAuthenticated true',
      () {
        final cubit = SettingsCubit(mockCommandService, mockLocalStorage);
        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.isAuthenticated, isTrue);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'should call handleSignOut and clearAll when token is present',
      build: () {
        when(
          () => mockLocalStorage.getAccessToken(),
        ).thenAnswer((_) async => 'stored-access-token');
        when(
          () => mockCommandService.handleSignOut(any()),
        ).thenAnswer((_) async => const Right(unit));
        when(() => mockLocalStorage.clearAll()).thenAnswer((_) async {});
        return SettingsCubit(mockCommandService, mockLocalStorage);
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isTrue),
        isA<SettingsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
      verify: (_) {
        verify(() => mockLocalStorage.getAccessToken()).called(1);
        verify(() => mockCommandService.handleSignOut(any())).called(1);
        verify(() => mockLocalStorage.clearAll()).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'should skip handleSignOut and clearAll when token is null',
      build: () {
        when(
          () => mockLocalStorage.getAccessToken(),
        ).thenAnswer((_) async => null);
        when(() => mockLocalStorage.clearAll()).thenAnswer((_) async {});
        return SettingsCubit(mockCommandService, mockLocalStorage);
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [
        isA<SettingsState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<SettingsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
      verify: (_) {
        verify(() => mockLocalStorage.getAccessToken()).called(1);
        verifyNever(() => mockCommandService.handleSignOut(any()));
        verify(() => mockLocalStorage.clearAll()).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'should skip handleSignOut and clearAll when token is empty',
      build: () {
        when(
          () => mockLocalStorage.getAccessToken(),
        ).thenAnswer((_) async => '');
        when(() => mockLocalStorage.clearAll()).thenAnswer((_) async {});
        return SettingsCubit(mockCommandService, mockLocalStorage);
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [
        isA<SettingsState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<SettingsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
      verify: (_) {
        verify(() => mockLocalStorage.getAccessToken()).called(1);
        verifyNever(() => mockCommandService.handleSignOut(any()));
        verify(() => mockLocalStorage.clearAll()).called(1);
      },
    );
  });
}
