// patrol_test/devices/ma_us_07_rename_organization_test.dart
//
// Covers: MA-US-07 — Actualizar Nombre de Organización
//
// Happy path: create an org, tap the trailing edit IconButton
// (Icons.edit_outlined with tooltip "Edit"), change the name, Save, and
// the updated name shows in the list.
//
// Cleanup deletes the org via OrganizationsCommandService (no UI
// navigation — direct getIt lookup).

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '_helpers.dart';

const String _kOrgName = 'E2E MA-US-07 Org';
const String _kOrgNameRenamed = 'E2E MA-US-07 Org Renamed';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'MA-US-07: happy path — rename an organization via the edit icon',
    ($) async {
      cleanupState.reset();
      await snapshotOriginalOrganizations();

      await $.pumpWidgetAndSettle(const MyApp());
      await login($);
      await navigateToOrganizations($);

      await createOrganization($, _kOrgName);
      await $(_kOrgName).waitUntilVisible();

      await renameFromTrailingEditIcon($, _kOrgNameRenamed);
      await $(_kOrgNameRenamed).waitUntilVisible();

      // Old name must be gone.
      expect($(_kOrgName).exists, isFalse,
          reason: 'Old org name should no longer be in the list');
    },
  );
}