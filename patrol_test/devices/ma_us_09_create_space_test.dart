// patrol_test/devices/ma_us_09_create_space_test.dart
//
// Covers: MA-US-09 — Crear Espacio
//
// Happy path: user creates an organization, opens it, then taps the
// "Create space" Icons.add on the SpacesScreen, fills a name, taps
// Create, and the new space card appears.
//
// Cleanup deletes the space and the organization in reverse-dependency
// order (space → organization).

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '_helpers.dart';

const String _kOrgName = 'E2E MA-US-09 Org';
const String _kSpaceName = 'E2E MA-US-09 Space';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'MA-US-09: happy path — create space inside a new organization',
    ($) async {
      cleanupState.reset();
      await snapshotOriginalOrganizations();

      await $.pumpWidgetAndSettle(const MyApp());
      await login($);
      await navigateToOrganizations($);

      final org = await createOrganization($, _kOrgName);
      await navigateToOrganization($);

      final space = await createSpace($, org, _kSpaceName);

      await $(_kSpaceName).waitUntilVisible();
      expect(createdSpaceId, isNotNull,
          reason: 'createSpace must record the id for cleanup');
      expect(space.organizationId, org.id);
    },
  );
}