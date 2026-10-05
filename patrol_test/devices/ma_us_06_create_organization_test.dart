// patrol_test/devices/ma_us_06_create_organization_test.dart
//
// Covers: MA-US-06 — Crear Organización
//
// Happy path: from the Organizations list, the user taps "Add Organization",
// fills in a name, taps Create, and the new org card appears in the list.
//
// Cleanup deletes the org via the OrganizationsCommandService (no UI
// navigation — direct getIt lookup).

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '_helpers.dart';

const String _kOrgName = 'E2E MA-US-06 Org';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'MA-US-06: happy path — create organization and see it in the list',
    ($) async {
      cleanupState.reset();
      await snapshotOriginalOrganizations();

      await $.pumpWidgetAndSettle(const MyApp());
      await login($);
      await navigateToOrganizations($);

      final org = await createOrganization($, _kOrgName);

      // Assertion — the new card is visible in the OrganizationsScreen list.
      await $(_kOrgName).waitUntilVisible();
      // And the cleanup state captured the id so tearDown can delete it.
      expect(createdOrganizationId, isNotNull,
          reason: 'createOrganization must record the id for cleanup');
      expect(org.name, _kOrgName);
    },
  );
}