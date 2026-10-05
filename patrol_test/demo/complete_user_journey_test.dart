// demo/complete_user_journey_test.dart
//
// End-to-end DEMO flow. Unlike the per-US tests in iam/, devices/ and
// notifications/ (which isolate one user story each), this test walks the
// full happy path of the app in a single run:
//
//   sign_in → create_org → create_space → pair_device → claim_device
//   → rename_device → configure_thresholds
//
// Use it for:
//   * Demos / stakeholder walkthroughs.
//   * Smoke-test that the entire happy path still works after a refactor.
//   * One-shot CI validation when individual test isolation is not needed.
//
// For per-US traceability use the individual tests (one per MA-US-XX) in
// iam/, devices/, notifications/.
//
// How to run (from project root, inside nix-shell):
//   patrol test --target patrol_test/demo/complete_user_journey_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '../devices/_helpers.dart';

const String _kOrgName = 'Demo Flow Organization';
const String _kSpaceName = 'Demo Flow Space';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'DEMO: complete user journey — sign in, provision an org+space+device, configure thresholds',
    ($) async {
      cleanupState.reset();
      await snapshotOriginalOrganizations();

      // 1. Sign in
      await $.pumpWidgetAndSettle(const MyApp());
      await login($);

      // 2. Create organization
      await navigateToOrganizations($);
      final org = await createOrganization($, _kOrgName);

      // 3. Open organization + create space
      await navigateToOrganization($);
      final space = await createSpace($, org, _kSpaceName);

      // 4. Open space + pair + claim device
      await navigateToSpace($);
      await pairAndClaimDevice($, space.id);

      // 5. Open device detail + rename
      await openDevice($);
      await editDeviceName($, 'Demo Device');

      // 6. Configure thresholds to minimum
      await setThresholdsToMinimum($);

      // End of demo. The app is now in a fully provisioned state
      // (authenticated user with one org, one space, one paired+claimed+
      // renamed+thresholded device). tearDown will clean up after.
    },
  );
}