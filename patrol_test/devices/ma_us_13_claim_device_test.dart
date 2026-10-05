// patrol_test/devices/ma_us_13_claim_device_test.dart
//
// Covers: MA-US-13 — Reclamar Dispositivo a un Espacio
//
// Happy path: pair first to get a claim token, then claim the device
// into the space using the Icons.add "Add device" button. The token is
// read out of the dialog and immediately consumed by the claim form —
// it is NEVER hard-coded.
//
// Cleanup deletes the device → space → organization.

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '_helpers.dart';

const String _kOrgName = 'E2E MA-US-13 Org';
const String _kSpaceName = 'E2E MA-US-13 Space';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'MA-US-13: happy path — pair then claim the device into the space',
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

      final token = await pairAndClaimDevice($, space.id);

      // Assert: the device tile is now in the list.
      await $('Sensor 0003').waitUntilVisible();
      // Assert: cleanup recorded a real device id.
      expect(createdDeviceId, isNotNull);
      // The claim token is a one-time secret — we don't echo it back, but
      // it must have been non-trivial (the helper enforces length >= 6).
      expect(token.length, greaterThanOrEqualTo(6));
    },
  );
}