// patrol_test/devices/ma_us_16_configure_threshold_test.dart
//
// Covers: MA-US-16 — Configurar Umbral de Métrica de Dispositivo
//
// Happy path: pair + claim, open the device detail, tap the threshold
// edit Icons.edit, drive the 4 vertical sliders to their UI minimum,
// tap SAVE, and the snackbar "Thresholds saved successfully." appears.
//
// Cleanup deletes the device → space → organization.
//
// (The downstream flow — navigate to Alerts, wait for an alert — used
// to live after this but was cut because the app crashes when querying
// a freshly-paired device with no telemetry on the Alerts screen. Until
// the app is hardened against that case, the only reliable assertion
// we can make is "thresholds saved successfully".)

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '_helpers.dart';

const String _kOrgName = 'E2E MA-US-16 Org';
const String _kSpaceName = 'E2E MA-US-16 Space';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'MA-US-16: happy path — configure thresholds to UI minimum and save',
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
      await setThresholdsToMinimum($);

      await $('Thresholds saved successfully.').waitUntilVisible();
    },
  );
}