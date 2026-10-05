// patrol_test/devices/ma_us_08_delete_organization_test.dart
//
// Covers: MA-US-08 — Eliminar Organización
//
// Happy path: create an org, tap its trailing delete IconButton
// (Icons.delete_outline, tooltip "Delete"), confirm in the AlertDialog,
// and the card disappears from the list.
//
// Cleanup is a no-op because the UI deletion removes the resource.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '_helpers.dart';

const String _kOrgName = 'E2E MA-US-08 Org';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'MA-US-08: happy path — delete an organization via the delete icon',
    ($) async {
      cleanupState.reset();
      await snapshotOriginalOrganizations();

      await $.pumpWidgetAndSettle(const MyApp());
      await login($);
      await navigateToOrganizations($);

      await createOrganization($, _kOrgName);
      await $(_kOrgName).waitUntilVisible();

      // Delete via the trailing Icons.delete_outline on the org card.
      await $(Icons.delete_outline).tap();
      await confirmDeleteDialog($);

      // The card must be gone.
      await $.pumpAndSettle();
      expect($(_kOrgName).exists, isFalse,
          reason: 'Organization card should disappear after delete');
    },
  );
}