import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/infrastructure/persistence/local/language_local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/shared_storage_doubles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late LanguageLocalStorage storage;

  /// Replaces the whole in-memory preference store with [initialValues] and
  /// hands the freshly built storage back to the test. Reseeding per test is
  /// what keeps one test's language from leaking into the next one.
  Future<void> seedStore(Map<String, Object> initialValues) async {
    SharedPreferences.setMockInitialValues(initialValues);
    prefs = await SharedPreferences.getInstance();
    storage = LanguageLocalStorage(prefs);
  }

  group('LanguageLocalStorage.getLanguageCode', () {
    test(
      'should return the persisted language code when a selection exists',
      () async {
        // Arrange
        await seedStore(<String, Object>{sharedLanguageCodeKey: 'es'});

        // Act
        final code = storage.getLanguageCode();

        // Assert
        expect(code, 'es');
      },
    );

    test('should return null when no language was ever persisted', () async {
      // Arrange: a store that has never seen a language selection.
      await seedStore(<String, Object>{});

      // Act
      final code = storage.getLanguageCode();

      // Assert: the storage has no default language, absence is reported as
      // null and it is the caller that decides what to fall back to.
      expect(code, isNull);
    });

    test(
      'should return a stale unsupported code verbatim because it performs no validation',
      () async {
        // Arrange: a code left over from a build that supported more languages.
        await seedStore(<String, Object>{sharedLanguageCodeKey: 'zz-ZZ'});

        // Act
        final code = storage.getLanguageCode();

        // Assert: the storage is a pure persistence seam, it does not know which
        // locales the app ships and therefore filters nothing out.
        expect(code, 'zz-ZZ');
      },
    );

    test(
      'should return an empty code verbatim because blank input is not rejected',
      () async {
        // Arrange
        await seedStore(<String, Object>{sharedLanguageCodeKey: ''});

        // Act
        final code = storage.getLanguageCode();

        // Assert: there is no validation layer, so an empty string survives.
        expect(code, '');
      },
    );

    test(
      'should throw a TypeError when the persisted value is not a string',
      () async {
        // Arrange: another feature wrote a number under the same key.
        await seedStore(<String, Object>{sharedLanguageCodeKey: 42});

        // Act
        // Assert: the failure comes from the `as String?` cast in shared_preferences.
        expect(() => storage.getLanguageCode(), throwsA(isA<TypeError>()));
      },
    );
  });

  group('LanguageLocalStorage.saveLanguageCode', () {
    test(
      'should make a saved language readable again through getLanguageCode',
      () async {
        // Arrange
        await seedStore(<String, Object>{});

        // Act
        await storage.saveLanguageCode('es');

        // Assert
        expect(storage.getLanguageCode(), 'es');
      },
    );

    test(
      'should store the selection under the documented preference key',
      () async {
        // Arrange
        await seedStore(<String, Object>{});

        // Act
        await storage.saveLanguageCode('en');

        // Assert
        expect(prefs.containsKey(sharedLanguageCodeKey), isTrue);
        expect(prefs.getString(sharedLanguageCodeKey), 'en');
      },
    );

    test('should overwrite a previously persisted language', () async {
      // Arrange
      await seedStore(<String, Object>{sharedLanguageCodeKey: 'es'});

      // Act
      await storage.saveLanguageCode('fr');

      // Assert
      expect(storage.getLanguageCode(), 'fr');
    });

    test(
      'should persist a blank code verbatim because input is not validated',
      () async {
        // Arrange
        await seedStore(<String, Object>{sharedLanguageCodeKey: 'es'});

        // Act
        await storage.saveLanguageCode('');

        // Assert: no ArgumentError and no rejection, the blank value is stored.
        expect(storage.getLanguageCode(), '');
      },
    );

    test(
      'should persist an unsupported code verbatim because input is not validated',
      () async {
        // Arrange
        await seedStore(<String, Object>{});

        // Act
        await storage.saveLanguageCode('not-a-locale');

        // Assert
        expect(storage.getLanguageCode(), 'not-a-locale');
      },
    );

    test(
      'should complete without error when the language is written on top of itself',
      () async {
        // Arrange
        await seedStore(<String, Object>{sharedLanguageCodeKey: 'en'});

        // Act
        await expectLater(storage.saveLanguageCode('en'), completes);

        // Assert
        expect(storage.getLanguageCode(), 'en');
      },
    );
  });

  group('LanguageLocalStorage.clearLanguage', () {
    test(
      'should return null again after a persisted language was cleared',
      () async {
        // Arrange
        await seedStore(<String, Object>{sharedLanguageCodeKey: 'es'});

        // Act
        await storage.clearLanguage();

        // Assert
        expect(storage.getLanguageCode(), isNull);
      },
    );

    test(
      'should leave a later selection readable after a previous one was cleared',
      () async {
        // Arrange
        await seedStore(<String, Object>{sharedLanguageCodeKey: 'es'});
        await storage.clearLanguage();

        // Act
        await storage.saveLanguageCode('fr');

        // Assert
        expect(storage.getLanguageCode(), 'fr');
      },
    );

    test(
      'should complete without error when nothing was persisted to clear',
      () async {
        // Arrange
        await seedStore(<String, Object>{});

        // Act
        await expectLater(storage.clearLanguage(), completes);

        // Assert
        expect(storage.getLanguageCode(), isNull);
      },
    );

    test(
      'should only remove the language entry and keep unrelated preferences',
      () async {
        // Arrange
        await seedStore(<String, Object>{
          sharedLanguageCodeKey: 'es',
          'unrelated_setting': 'keep me',
        });

        // Act
        await storage.clearLanguage();

        // Assert
        expect(storage.getLanguageCode(), isNull);
        expect(prefs.getString('unrelated_setting'), 'keep me');
      },
    );
  });
}
