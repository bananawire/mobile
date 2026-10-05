import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/shared/application/internal/cubits/locale_cubit.dart';

import 'helpers/shared_storage_doubles.dart';

void main() {
  setUpAll(() {
    registerFallbackValue('en');
  });

  group('LocaleCubit initial state', () {
    late MockLanguageLocalStorage storage;
    late LocaleCubit cubit;

    setUp(() {
      // Arrange: a fresh double per test, defaulting to "nothing persisted".
      storage = MockLanguageLocalStorage();
      when(() => storage.getLanguageCode()).thenReturn(null);
      cubit = LocaleCubit(storage);
      addTearDown(cubit.close);
    });

    test('should start in english when no language was persisted', () {
      // Arrange: already done in setUp.

      // Act
      final state = cubit.state;

      // Assert: 'en' is the hard coded initial state of the cubit.
      expect(state, const Locale('en'));
    });

    test('should expose the persisted locale right after construction', () {
      // Arrange: a previous session left Spanish selected.
      final seededStorage = MockLanguageLocalStorage();
      when(() => seededStorage.getLanguageCode()).thenReturn('es');
      final seededCubit = LocaleCubit(seededStorage);
      addTearDown(seededCubit.close);

      // Act
      final state = seededCubit.state;

      // Assert
      expect(state, const Locale('es'));
    });

    test('should read the persisted locale exactly once on construction', () {
      // Arrange
      final verifiedStorage = MockLanguageLocalStorage();
      when(() => verifiedStorage.getLanguageCode()).thenReturn('es');
      final verifiedCubit = LocaleCubit(verifiedStorage);
      addTearDown(verifiedCubit.close);

      // Act: the count is asserted from this same verify result.
      verify(() => verifiedStorage.getLanguageCode()).called(1);
    });

    test(
      'should adopt a stale persisted locale verbatim because it is not validated',
      () {
        // Arrange: the stored code no longer maps to a shipped locale.
        final staleStorage = MockLanguageLocalStorage();
        when(() => staleStorage.getLanguageCode()).thenReturn('zz-ZZ');
        final staleCubit = LocaleCubit(staleStorage);
        addTearDown(staleCubit.close);

        // Act
        final state = staleCubit.state;

        // Assert: the cubit trusts persistence and never inspects the code.
        expect(state, const Locale('zz-ZZ'));
      },
    );

    test(
      'should throw an AssertionError when persistence holds a blank code',
      () {
        // Arrange: the storage accepts a blank code, `Locale('')` does not.
        final blankStorage = MockLanguageLocalStorage();
        when(() => blankStorage.getLanguageCode()).thenReturn('');

        // Act
        // Assert: loading builds `Locale('')`, which trips the debug assertion
        // inside the `Locale` constructor. The cubit has no blank-code guard.
        expect(() => LocaleCubit(blankStorage), throwsA(isA<AssertionError>()));
      },
    );
  });

  group('LocaleCubit.changeLocale', () {
    late MockLanguageLocalStorage storage;
    late LocaleCubit cubit;

    setUp(() {
      // Arrange
      storage = MockLanguageLocalStorage();
      when(() => storage.getLanguageCode()).thenReturn(null);
      when(() => storage.saveLanguageCode(any())).thenAnswer((_) async {});
      cubit = LocaleCubit(storage);
      addTearDown(cubit.close);
    });

    blocTest<LocaleCubit, Locale>(
      'should emit the new locale when switching to a supported language',
      build: () => cubit,
      act: (LocaleCubit cubit) => cubit.changeLocale('es'),
      expect: () => <Locale>[const Locale('es')],
    );

    blocTest<LocaleCubit, Locale>(
      'should persist the selected code before the new locale is emitted',
      build: () => cubit,
      act: (LocaleCubit cubit) => cubit.changeLocale('es'),
      expect: () => <Locale>[const Locale('es')],
      verify: (_) {
        // Assert: the write completed before the state change was published.
        final captured = verify(
          () => storage.saveLanguageCode(captureAny()),
        ).captured.cast<String>();
        expect(captured, <String>['es']);
        expect(cubit.state, const Locale('es'));
      },
    );

    blocTest<LocaleCubit, Locale>(
      'should emit an unsupported locale verbatim because it is not rejected',
      build: () => cubit,
      act: (LocaleCubit cubit) => cubit.changeLocale('zz-ZZ'),
      expect: () => <Locale>[const Locale('zz-ZZ')],
    );

    test(
      'should throw an AssertionError and publish nothing when switching to a blank code',
      () async {
        // Arrange
        final published = <Locale>[];
        final subscription = cubit.stream.listen(published.add);
        addTearDown(subscription.cancel);

        // Act
        await expectLater(
          cubit.changeLocale(''),
          throwsA(isA<AssertionError>()),
        );
        await Future<void>.delayed(Duration.zero);

        // Assert: the blank code reaches storage first, then the emit blows up
        // on `Locale('')`, so no locale is ever published.
        verify(() => storage.saveLanguageCode('')).called(1);
        expect(published, isEmpty);
        expect(cubit.state, const Locale('en'));
      },
    );

    test(
      'should end on the newly selected locale after the switch completes',
      () async {
        // Arrange
        when(() => storage.getLanguageCode()).thenReturn('en');
        final switchingCubit = LocaleCubit(storage);
        addTearDown(switchingCubit.close);

        // Act
        await switchingCubit.changeLocale('fr');

        // Assert
        expect(switchingCubit.state, const Locale('fr'));
      },
    );

    test('should persist each of two consecutive switches', () async {
      // Arrange
      final recordingStorage = MockLanguageLocalStorage();
      when(() => recordingStorage.getLanguageCode()).thenReturn('en');
      final recordedCodes = <String>[];
      when(() => recordingStorage.saveLanguageCode(any())).thenAnswer(
        (invocation) async =>
            recordedCodes.add(invocation.positionalArguments.first as String),
      );
      final switchingCubit = LocaleCubit(recordingStorage);
      addTearDown(switchingCubit.close);

      // Act
      await switchingCubit.changeLocale('es');
      await switchingCubit.changeLocale('fr');

      // Assert
      expect(recordedCodes, <String>['es', 'fr']);
      expect(switchingCubit.state, const Locale('fr'));
    });

    test(
      'should throw a StateError when switching after the cubit was closed',
      () async {
        // Arrange
        final closingCubit = LocaleCubit(storage);
        await closingCubit.close();

        // Act
        // Assert: the write still reaches storage, only the emit is rejected.
        await expectLater(
          closingCubit.changeLocale('es'),
          throwsA(isA<StateError>()),
        );
        verify(() => storage.saveLanguageCode('es')).called(1);
      },
    );
  });

  group('LocaleCubit.changeLocale persistence failure', () {
    late FailingLanguageLocalStorage storage;
    late LocaleCubit cubit;

    setUp(() {
      // Arrange: reads work, every write fails the way a full prefs file does.
      storage = FailingLanguageLocalStorage(storedCode: 'es');
      cubit = LocaleCubit(storage);
      addTearDown(cubit.close);
    });

    test('should propagate the storage failure to the caller', () async {
      // Act
      await expectLater(
        cubit.changeLocale('fr'),
        throwsA(isA<SharedStorageFailure>()),
      );

      // Assert
      expect(storage.saveCalls, 1);
    });

    test(
      'should keep the previously loaded locale when the write fails',
      () async {
        // Arrange
        final startingLocale = cubit.state;

        // Act
        await expectLater(
          cubit.changeLocale('fr'),
          throwsA(isA<SharedStorageFailure>()),
        );

        // Assert: there is no error state, so the last good locale stays current.
        expect(cubit.state, startingLocale);
        expect(cubit.state, const Locale('es'));
      },
    );

    test('should publish no new locale when the write fails', () async {
      // Arrange: observe the stream so a silent success would be visible.
      final published = <Locale>[];
      final subscription = cubit.stream.listen(published.add);
      addTearDown(subscription.cancel);

      // Act
      await expectLater(
        cubit.changeLocale('fr'),
        throwsA(isA<SharedStorageFailure>()),
      );
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(published, isEmpty);
    });

    test(
      'should recover and apply the locale once storage works again',
      () async {
        // Arrange
        final recoveringStorage = MockLanguageLocalStorage();
        when(() => recoveringStorage.getLanguageCode()).thenReturn('es');
        when(
          () => recoveringStorage.saveLanguageCode(any()),
        ).thenAnswer((_) async {});
        final recoveringCubit = LocaleCubit(recoveringStorage);
        addTearDown(recoveringCubit.close);

        // Act
        await recoveringCubit.changeLocale('fr');

        // Assert
        expect(recoveringCubit.state, const Locale('fr'));
      },
    );
  });
}
