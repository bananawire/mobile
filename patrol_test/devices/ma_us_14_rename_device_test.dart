// patrol_test/devices/ma_us_14_rename_device_test.dart
//
// Covers: MA-US-14 — Actualizar Nombre de Dispositivo
//
// Happy path: pair + claim, open the device detail, tap the 3-dot menu
// (Icons.more_vert) → Edit, change the name, Save, and the new name
// shows up in the device detail header.
//
// Cleanup deletes the device → space → organization.

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_consts.dart';
import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '_helpers.dart';

const String _kOrgName = 'E2E MA-US-14 Org';
const String _kSpaceName = 'E2E MA-US-14 Space';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'MA-US-14: happy path — rename a device via popup menu → Edit → Save',
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
      await editDeviceName($, kRenamedDeviceName);

      // Assert: the new name shows up in the device detail header.
      await $(kRenamedDeviceName).waitUntilVisible();
    },
  );
}