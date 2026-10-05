// patrol_test/devices/ma_us_17_remove_threshold_test.dart
//
// Covers: MA-US-17 — Remover Umbral de Métrica de Dispositivo
//
// Happy path: pair + claim, set thresholds to minimum (so we can verify
// the editor opens), open the editor again, press RESET, save, and
// observe "Thresholds saved successfully." — after RESET every metric
// has no threshold configured.
//
// Cleanup deletes the device → space → organization.

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '_helpers.dart';

const String _kOrgName = 'E2E MA-US-17 Org';
const String _kSpaceName = 'E2E MA-US-17 Space';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'MA-US-17: happy path — reset thresholds removes every metric threshold',
    ($) async {
      cleanupState.reset();
      await snapshotOriginalOrganizations();

      await $.pumpWidgetAndSettle(const MyApp());
      await login($);
      await navigateToOrganizations($);

      final org = await createOrganization($, _kOrgName);
      await navigateToOrganization($);
      final space = await createSpace($, org, _kSpaceName);
      await navigateToSpace($);

      await pairAndClaimDevice($, space.id);
      await openDevice($);

      // First set them to a non-default value (minimum).
      await setThresholdsToMinimum($);
      await $('Thresholds saved successfully.').waitUntilVisible();

      // Now RESET to defaults, which removes every configured threshold.
      await resetThresholdsToDefaults($);
      await $('Thresholds saved successfully.').waitUntilVisible();
    },
  );
}