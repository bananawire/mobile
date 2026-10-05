import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/interfaces/pages/settings/settings_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/iam_test_doubles.dart';

void main() {
  late MockAuthenticationCommandService commandService;
  late MockTokenLocalStorage tokenStorage;
  late SettingsCubit cubit;

  setUpAll(registerIamFallbackValues);

  setUp(() {
    commandService = MockAuthenticationCommandService();
    tokenStorage = MockTokenLocalStorage();
    when(() => tokenStorage.clearAll()).thenAnswer((_) async {});
    when(() => commandService.handleSignOut(any()))
        .thenAnswer((_) async => const Right(unit));
    cubit = SettingsCubit(commandService, tokenStorage);
  });

  tearDown(() => cubit.close());

  test('should start authenticated and idle', () {
    // Assert
    expect(cubit.state.isAuthenticated, isTrue);
    expect(cubit.state.isLoading, isFalse);
  });

  group('SettingsCubit.signOut', () {
    blocTest<SettingsCubit, SettingsState>(
      'should flag loading and then unauthenticated when a token is stored',
      setUp: () {
        when(() => tokenStorage.getAccessToken())
            .thenAnswer((_) async => IamFixtures.accessToken);
      },
      build: () => cubit,
      act: (cubit) => cubit.signOut(),
      expect: () => [
        isA<SettingsState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<SettingsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
      verify: (_) {
        final command = verify(() => commandService.handleSignOut(captureAny()))
            .captured
            .single as SignOutCommand;
        expect(command.accessToken.token, IamFixtures.accessToken);
        verify(() => tokenStorage.clearAll()).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'should skip the remote sign out but still clear storage when no token is stored',
      setUp: () {
        when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => null);
      },
      build: () => cubit,
      act: (cubit) => cubit.signOut(),
      expect: () => [
        isA<SettingsState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<SettingsState>()
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
      verify: (_) {
        verifyNever(() => commandService.handleSignOut(any()));
        verify(() => tokenStorage.clearAll()).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'should skip the remote sign out when the stored token is empty',
      setUp: () {
        when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => '');
      },
      build: () => cubit,
      act: (cubit) => cubit.signOut(),
      verify: (_) => verifyNever(() => commandService.handleSignOut(any())),
    );

    blocTest<SettingsCubit, SettingsState>(
      'should still end unauthenticated when the remote sign out fails',
      setUp: () {
        when(() => tokenStorage.getAccessToken())
            .thenAnswer((_) async => IamFixtures.accessToken);
        when(() => commandService.handleSignOut(any()))
            .thenAnswer((_) async => const Left(Failure('Access denied.')));
      },
      build: () => cubit,
      act: (cubit) => cubit.signOut(),
      expect: () => [
        isA<SettingsState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<SettingsState>()
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse)
            .having((s) => s.isLoading, 'isLoading', isFalse),
      ],
    );
  });
}