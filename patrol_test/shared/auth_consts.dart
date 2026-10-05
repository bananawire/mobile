// patrol_test/shared/auth_consts.dart
//
// Shared constants for any Patrol E2E test that needs the QA account.
//
// Same defaults as `login_test.dart` / `iam_setup.dart`. Override at
// runtime with --dart-define TEST_EMAIL / TEST_PASSWORD.

/// Default QA email used for sign-in across the suite. Set with
/// `--dart-define TEST_EMAIL=...` to override.
const String kTestEmail = String.fromEnvironment(
  'TEST_EMAIL',
  defaultValue: 'fafox59733@findize.com',
);

/// Default QA password used for sign-in across the suite. Set with
/// `--dart-define TEST_PASSWORD=...` to override.
const String kTestPassword = String.fromEnvironment(
  'TEST_PASSWORD',
  defaultValue: 'SecurePass123!',
);

/// Hardware id of the Clair sensor used by every device happy path.
const String kTestHardwareId = 'CLAIR-0003';

/// Serial number of the Clair sensor used by every device happy path.
const String kTestSerialNumber = 'SN-0003';

/// Original device name as shipped by the firmware (shown on the device
/// tile before any rename).
const String kInitialDeviceName = 'Sensor 0003';

/// Device name used by MA-US-14 to verify rename works.
const String kRenamedDeviceName = 'Sensor 0003 Edited';