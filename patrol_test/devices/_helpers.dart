// patrol_test/devices/_helpers.dart
//
// Internal helpers shared by every test in `patrol_test/devices/`.
//
// Public surface (used by the per-US test files):
//   * [navigateToOrganizations]    — from /analytics, tap "Spaces" tab
//   * [createOrganization]         — drives the OrganizationsScreen UI
//   * [createSpace]                — drives the SpacesScreen UI
//   * [pairAndClaimDevice]         — drives the SpaceDevicesScreen UI
//   * [navigateToOrganization]     — tap chevron on an org card
//   * [navigateToSpace]            — tap chevron on a space card
//   * [openDevice]                 — tap the device tile by serial
//   * [editDeviceName]             — popup menu → Edit → Save
//   * [setThresholdsToMinimum]     — drive the 4 sliders to min, save
//
// Each helper writes the IDs it created into the shared [cleanupState]
// (via the top-level setters in `../shared/cleanup_state.dart`) so
// `safeCleanup()` can remove everything the test created.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart' show PatrolIntegrationTester;

import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/devices/domain/model/queries/get_spaces_by_organization.query.dart';
import 'package:mobile/devices/domain/model/queries/get_user_organizations.query.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/space.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/infrastructure/api/gateways/devices.gateway.dart';
import 'package:mobile/devices/domain/services/organizations.query-service.dart';
import 'package:mobile/devices/domain/services/spaces.query-service.dart';

import '../shared/auth_consts.dart';
import '../shared/cleanup_state.dart';
import '../shared/poll_until.dart';

// ============================================================
// Navigation helpers
// ============================================================

/// From the post-login /analytics screen, switches to the "Spaces"
/// (3rd) bottom-nav tab and waits for the Organizations header.
Future<void> navigateToOrganizations(PatrolIntegrationTester $) async {
  await $('Spaces').tap();
  await $('Organizations').waitUntilVisible();
}

// ============================================================
// Organization helpers (MA-US-06 happy path)
// ============================================================

/// Drives the OrganizationsScreen "Add Organization" → form → Create flow.
/// Returns the created [OrganizationReadModel] and writes its id into
/// [createdOrganizationId] so cleanup deletes it.
Future<OrganizationReadModel> createOrganization(
  PatrolIntegrationTester $,
  String name,
) async {
  await $('Add Organization').tap();
  final nameField = $(TextFormField).at(0);
  await nameField.waitUntilVisible();
  await nameField.enterText(name);
  await $('Create').tap();
  await $('Organizations').waitUntilVisible();

  late OrganizationReadModel created;
  final found = await pollUntil(
    () async {
      final r = await getIt<OrganizationsQueryService>()
          .handleGetUserOrganizations(const GetUserOrganizationsQuery());
      return r.fold((_) => false, (orgs) {
        final match = orgs.where((o) => o.name == name);
        if (match.isEmpty) return false;
        created = match.first;
        return true;
      });
    },
    timeout: const Duration(seconds: 15),
    description: 'new organization in list',
  );
  if (!found) {
    throw StateError('Newly created organization "$name" not in list');
  }
  createdOrganizationId = created.id;
  return created;
}

/// Taps the trailing chevron on the organization card to enter its
/// spaces list.
Future<void> navigateToOrganization(PatrolIntegrationTester $) async {
  await $(Icons.chevron_right).tap();
}

// ============================================================
// Space helpers (MA-US-09 happy path)
// ============================================================

/// Drives the SpacesScreen "Create space" (Icons.add) → bottom-sheet
/// → Create flow. Returns the created [SpaceReadModel] and writes its
/// id into [createdSpaceId].
Future<SpaceReadModel> createSpace(
  PatrolIntegrationTester $,
  OrganizationReadModel org,
  String name,
) async {
  // Disambiguate the only Icons.add on the SpacesScreen.
  await $.tester.tap(find.byIcon(Icons.add));
  final nameField = $(TextFormField).at(0);
  await nameField.waitUntilVisible();
  await nameField.enterText(name);
  await $('Create').tap();

  await $(name).waitUntilVisible();

  late SpaceReadModel created;
  final found = await pollUntil(
    () async {
      final r =
          await getIt<SpacesQueryService>().handleGetSpacesByOrganization(
        GetSpacesByOrganizationQuery(organizationId: OrganizationId(org.id)),
      );
      return r.fold((_) => false, (spaces) {
        final match = spaces.where((s) => s.name == name);
        if (match.isEmpty) return false;
        created = match.first;
        if (created.organizationId != org.id) return false;
        return true;
      });
    },
    timeout: const Duration(seconds: 15),
    description: 'new space inside new org',
  );
  if (!found) {
    throw StateError('Newly created space "$name" not found under ${org.id}');
  }
  createdSpaceId = created.id;
  return created;
}

/// Taps the trailing chevron on a space card to enter its devices list.
Future<void> navigateToSpace(PatrolIntegrationTester $) async {
  await $(Icons.chevron_right).tap();
}

// ============================================================
// Device helpers (MA-US-12 to MA-US-17 happy paths)
// ============================================================

/// Pair + Claim sub-flow. Returns the issued claim token (so callers can
/// assert its shape) and writes the device id into [createdDeviceId].
Future<String> pairAndClaimDevice(PatrolIntegrationTester $, String spaceId) async {
  // Pair
  await $(Icons.wifi_tethering_outlined).tap();
  final hardwareIdField = $(TextFormField).at(0);
  await hardwareIdField.waitUntilVisible();
  await hardwareIdField.enterText(kTestHardwareId);
  await $('Pair').tap();

  // Read claim token out of the "Pairing started" dialog.
  await $('Pairing started').waitUntilVisible();
  await Future<void>.delayed(const Duration(milliseconds: 500));
  if ($('No claim token returned.').exists) {
    throw StateError('Backend did not return a claim token');
  }
  final tokenElement =
      find.textContaining('Claim token: ').evaluate().first;
  final tokenText = (tokenElement.widget as Text).data ?? '';
  final claimToken = tokenText.substring('Claim token: '.length).trim();
  if (claimToken.length < 6) {
    throw StateError('Suspiciously short claim token: "$claimToken"');
  }
  await $('Close').tap();
  await $(Icons.add).waitUntilVisible();

  // Claim
  await $(Icons.add).tap();
  final tokenInputField = $(TextFormField).at(0);
  await tokenInputField.waitUntilVisible();
  await tokenInputField.enterText(claimToken);
  await $('Add').tap();
  await $(kTestSerialNumber).waitUntilVisible();

  // Discover device id for cleanup.
  late String deviceId;
  final found = await pollUntil(
    () async {
      final raw = await getIt<DevicesGateway>().getDevicesBySpaceRaw(
        spaceId: spaceId,
      );
      final content = (raw['content'] as List?) ?? const [];
      for (final item in content) {
        if (item is Map &&
            (item['serialNumber'] == kTestSerialNumber ||
                item['hardwareId'] == kTestHardwareId)) {
          deviceId = item['id'].toString();
          return true;
        }
      }
      return false;
    },
    timeout: const Duration(seconds: 30),
    description: 'claimed device in space',
  );
  if (!found) {
    throw StateError(
      'Newly claimed device $kTestSerialNumber not in space $spaceId',
    );
  }
  createdDeviceId = deviceId;
  return claimToken;
}

/// Opens the device detail screen by tapping the device tile (by serial).
Future<void> openDevice(PatrolIntegrationTester $) async {
  await $(kTestSerialNumber).tap();
  await $(kInitialDeviceName).waitUntilVisible();
}

/// Edits the device name via the popup menu → Edit → Save flow.
Future<void> editDeviceName(PatrolIntegrationTester $, String newName) async {
  await $(Icons.more_vert).tap();
  await $('Edit').tap();
  final editNameField = $(TextFormField).at(0);
  await editNameField.waitUntilVisible();
  await editNameField.enterText('');
  await editNameField.enterText(newName);
  await $('Save').tap();
  await $(newName).waitUntilVisible();
}

/// Opens the threshold editor and sets all 4 metrics to their UI minimum.
Future<void> setThresholdsToMinimum(PatrolIntegrationTester $) async {
  await $(Icons.edit).tap();
  await $('SAVE').waitUntilVisible();
  await $('RESET').waitUntilVisible();

  final sliders = find.byWidgetPredicate(
    (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
  );
  expect(sliders, findsNWidgets(4),
      reason: 'Editor must expose 4 vertical sliders');

  for (var i = 0; i < 4; i++) {
    final slider = sliders.at(i);
    final box = slider.evaluate().first.renderObject as RenderBox;
    final local = Offset(box.size.width / 2, box.size.height - 6);
    final global = box.localToGlobal(local);
    await $.tester.tapAt(global);
    await $.pumpAndSettle();
  }

  await $('SAVE').tap();
  await $('Thresholds saved successfully.').waitUntilVisible();
}

/// Opens the threshold editor, presses RESET, and saves.
Future<void> resetThresholdsToDefaults(PatrolIntegrationTester $) async {
  await $(Icons.edit).tap();
  await $('RESET').waitUntilVisible();
  await $('RESET').tap();
  await $('SAVE').tap();
  await $('Thresholds saved successfully.').waitUntilVisible();
}

// ============================================================
// Edit name helpers (MA-US-07, MA-US-10, MA-US-14 share this pattern)
// ============================================================

/// Taps the trailing edit IconButton on the currently-visible card (org
/// or space), enters [newName] in the pre-filled TextFormField, taps
/// Save, and waits for the updated name to appear.
Future<void> renameFromTrailingEditIcon(
  PatrolIntegrationTester $,
  String newName,
) async {
  // OrgCard and SpaceCard both use Icons.edit_outlined with the same
  // tooltip "Edit" (l10n.common_edit = "Edit").
  await $(Icons.edit_outlined).tap();
  final field = $(TextFormField).at(0);
  await field.waitUntilVisible();
  await field.enterText('');
  await field.enterText(newName);
  await $('Save').tap();
  await $(newName).waitUntilVisible();
}

// ============================================================
// Delete helpers (MA-US-08, MA-US-11, MA-US-15 share this pattern)
// ============================================================

/// Confirms a delete by tapping "Delete" in the AlertDialog. Must be
/// called immediately after the action that opened the delete dialog.
Future<void> confirmDeleteDialog(PatrolIntegrationTester $) async {
  await $('Delete').tap();
}