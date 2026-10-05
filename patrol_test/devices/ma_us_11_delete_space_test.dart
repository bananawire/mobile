// patrol_test/devices/ma_us_11_delete_space_test.dart
//
// Covers: MA-US-11 — Eliminar Espacio
//
// Happy path: create an org + space, tap its trailing delete IconButton
// (Icons.delete_outline, tooltip "Delete"), confirm in the AlertDialog,
// and the space card disappears.
//
// Cleanup is a no-op because the UI deletion removes the space. The
// organization created for the test is also deleted via UI to leave the
// environment clean (avoids orphan orgs across runs).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '_helpers.dart';

const String _kOrgName = 'E2E MA-US-11 Org';
const String _kSpaceName = 'E2E MA-US-11 Space';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'MA-US-11: happy path — delete a space via the delete icon',
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
      await $(Icons.delete_outline).tap();
      await confirmDeleteDialog($);

      await $.pumpAndSettle();
      expect($(_kSpaceName).exists, isFalse,
          reason: 'Space card should disappear after delete');
    },
  );
}