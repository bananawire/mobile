// demo/complete_user_journey_test.dart
//
// End-to-end DEMO flow. Unlike the per-US tests in iam/, devices/ and
// notifications/ (which isolate one user story each), this test walks the
// full happy path of the app in a single run:
//
//   sign_in → create_org → rename_org → open_org → create_space
//   → rename_space → open_space → pair_device → claim_device
//   → open_device → rename_device → set_thresholds → reset_thresholds
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
const String _kOrgRenamed = 'Demo Flow Organization (Renamed)';
const String _kSpaceName = 'Demo Flow Space';
const String _kSpaceRenamed = 'Demo Flow Space (Renamed)';
const String _kDeviceRenamed = 'Demo Device';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'DEMO: complete user journey — provision an org+space+device, rename each, configure then reset thresholds',
    ($) async {
      cleanupState.reset();
      await snapshotOriginalOrganizations();

      // 1. Sign in.
      await $.pumpWidgetAndSettle(const MyApp());
      await login($);

      // 2. Create organization.
      await navigateToOrganizations($);
      final org = await createOrganization($, _kOrgName);

      // 3. Rename the organization (trailing edit icon on the card).
      await renameFromTrailingEditIcon($, _kOrgRenamed);

      // 4. Open organization (chevron on the card).
      await navigateToOrganization($);

      // 5. Create space.
      final space = await createSpace($, org, _kSpaceName);

      // 6. Rename the space (trailing edit icon on the space card).
      await renameFromTrailingEditIcon($, _kSpaceRenamed);

      // 7. Open space (chevron on the space card).
      await navigateToSpace($);

      // 8. Pair + claim device.
      await pairAndClaimDevice($, space.id);

      // 9. Open device detail.
      await openDevice($);

      // 10. Rename the device (popup menu → Edit → Save).
      await editDeviceName($, _kDeviceRenamed);

      // 11. Configure thresholds to UI minimum.
      await setThresholdsToMinimum($);

      // 12. Reopen the thresholds editor and RESET to defaults (this is
      //     a different operation — it removes the threshold configuration
      //     instead of changing it to a new value).
      await resetThresholdsToDefaults($);

      // End of demo. The app is now in a fully provisioned state
      // (authenticated user with one org, one space, one paired+claimed+
      // renamed+thresholded+reset device). tearDown will clean up after.
    },
  );
}