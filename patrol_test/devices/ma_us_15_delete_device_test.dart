// patrol_test/devices/ma_us_15_delete_device_test.dart
//
// Covers: MA-US-15 — Eliminar Dispositivo
//
// Happy path: pair + claim, open the device detail, tap the trash button
// on the device detail header, confirm in the AlertDialog, and the
// app navigates back to the devices list (the tile is gone).
//
// Cleanup is a no-op because the UI deletion removes the device. The
// space + org are still alive and cleaned up in reverse-dependency
// order by safeCleanup().

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '_helpers.dart';

const String _kOrgName = 'E2E MA-US-15 Org';
const String _kSpaceName = 'E2E MA-US-15 Space';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'MA-US-15: happy path — delete a device from the device detail header',
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

      // The device detail header has an Icons.delete_outline button.
      await $(Icons.delete_outline).tap();
      await confirmDeleteDialog($);

      await $.pumpAndSettle();

      // After deletion we are back on the SpaceDevicesScreen, and the
      // device tile (matched by serial chip) is gone.
      expect($('SN-0003').exists, isFalse,
          reason: 'Device tile should be gone after deletion');
    },
  );
}