// patrol_test/test_bootstrap.dart
//
// Bootstrap reusable for any Patrol E2E test that needs to pump MyApp().
//
// Why a dedicated bootstrap (instead of calling lib/main.dart's main()):
//   - Patrol forbids `runApp()` and `WidgetsFlutterBinding.ensureInitialized()`
//     in user code (it does both for us).
//   - main() initializes OneSignal — would require real project configuration
//     and is irrelevant to UI behavior tests.
//   - main() relies on flutter_secure_storage which throws AEADBadTagException
//     on devices whose Keystore state changed (common after lock-screen
//     changes or factory resets). Tests must be resilient to that.
//
// Reference: https://patrol.leancode.co/getting-started

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';

/// Initializes the minimum environment required to pump `MyApp` from a test.
///
/// Idempotent: safe to call once per test or once per suite via `setUpAll`.
Future<void> initTestApp() async {
  // 1. .env — required for CLAIR_BACKEND_BASE_URL consumed by DioClient.
  //    Patrol runs from the project root, so the relative path works.
  await dotenv.load(fileName: '.env');

  // 2. SharedPreferences — use the in-memory mock. Real persistence is
  //    irrelevant to UI tests and would leak state across runs.
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final sharedPrefs = await SharedPreferences.getInstance();

  // 3. Service locator — same wiring as production. The login cubit and
  //    AuthenticationCommandService are created from this registry.
  setupServiceLocator(sharedPrefs);

  // 4. Bypass the flutter_secure_storage AEAD crash that happens on devices
  //    whose Android Keystore state changed (lock-screen change, factory
  //    reset, multiple reinstalls). Wrapped in try/catch because the
  //    storage itself may fail to initialize, in which case there is
  //    nothing to clear anyway.
  try {
    await const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ).deleteAll();
  } catch (_) {
    // Secure storage not initializable — fine, we won't read from it.
  }

  // 5. Reset AuthSession so GoRouter routes us to /login.
  AuthSession().setAuthenticated(false);

  // 6. Make sure TokenLocalStorage also has a clean slate (defensive).
  try {
    await getIt<TokenLocalStorage>().clearAll();
  } catch (_) {
    // Ignore — clearAll() also touches the (possibly broken) secure storage.
  }
}