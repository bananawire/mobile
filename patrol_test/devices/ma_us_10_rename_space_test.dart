// patrol_test/devices/ma_us_10_rename_space_test.dart
//
// Covers: MA-US-10 — Actualizar Nombre de Espacio
//
// Happy path: create an org + space, tap the trailing edit IconButton
// on the space card, change the name, Save, and the updated name
// shows in the list.
//
// Cleanup deletes the space and organization (space → organization).

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '_helpers.dart';

const String _kOrgName = 'E2E MA-US-10 Org';
const String _kSpaceName = 'E2E MA-US-10 Space';
const String _kSpaceNameRenamed = 'E2E MA-US-10 Space Renamed';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'MA-US-10: happy path — rename a space via the edit icon',
    ($) async {
      cleanupState.reset();
      await snapshotOriginalOrganizations();

      await $.pumpWidgetAndSettle(const MyApp());
      await login($);
      await navigateToOrganizations($);

      final org = await createOrganization($, _kOrgName);
      await navigateToOrganization($);
      await createSpace($, org, _kSpaceName);

      await $(_kSpaceName).waitUntilVisible();
      await renameFromTrailingEditIcon($, _kSpaceNameRenamed);
      await $(_kSpaceNameRenamed).waitUntilVisible();

      expect($(_kSpaceName).exists, isFalse,
          reason: 'Old space name should no longer be in the list');
    },
  );
}