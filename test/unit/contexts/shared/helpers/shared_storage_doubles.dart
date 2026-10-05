import 'package:mocktail/mocktail.dart';
import 'package:mobile/shared/infrastructure/persistence/local/language_local_storage.dart';

/// Mirrors the private `_languageCodeKey` of [LanguageLocalStorage].
///
/// [SharedPreferences.setMockInitialValues] seeds the in-memory store by raw
/// key, and the storage keeps its key private, so the tests have to spell the
/// key out themselves. It is the only place in the suite that hardcodes it.
const String sharedLanguageCodeKey = 'selected_language_code';

/// A mock of the language persistence seam. [LanguageLocalStorage] is a
/// concrete class, so it is mocked by interface rather than subclassed, which
/// keeps the cubit tests independent of `shared_preferences`.
class MockLanguageLocalStorage extends Mock implements LanguageLocalStorage {}

/// The exception [FailingLanguageLocalStorage] throws, so a test can assert on
/// the exact type that reaches the caller instead of on a string message.
class SharedStorageFailure implements Exception {
  const SharedStorageFailure([
    this.message = 'the platform store rejected the write',
  ]);

  final String message;

  @override
  String toString() => 'SharedStorageFailure: $message';
}

/// A storage double whose reads are answered from memory and whose writes fail
/// the way a full or read-only preferences file would fail.
class FailingLanguageLocalStorage implements LanguageLocalStorage {
  FailingLanguageLocalStorage({
    this.storedCode,
    this.failure = const SharedStorageFailure(),
  });

  /// What [getLanguageCode] reports before any failed write.
  final String? storedCode;

  /// The failure every write raises. Defaults to [SharedStorageFailure].
  final Object failure;

  /// Number of [saveLanguageCode] calls that reached the failing store.
  int saveCalls = 0;

  /// Number of [clearLanguage] calls that reached the failing store.
  int clearCalls = 0;

  @override
  String? getLanguageCode() => storedCode;

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    saveCalls++;
    throw failure;
  }

  @override
  Future<void> clearLanguage() async {
    clearCalls++;
    throw failure;
  }
}
