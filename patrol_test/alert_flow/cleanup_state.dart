// patrol_test/alert_flow/cleanup_state.dart
//
// Cross-cutting layer: cleanup.
//
// Owns the mutable state captured by every step in the alert-flow E2E test
// and provides a single `safeCleanup()` function that the test's `tearDown`
// invokes. Cleanup is idempotent and tolerates partial state (e.g. if a step
// failed before it could capture an id, the corresponding field is null).
//
// IMPORTANT — safety guarantees:
//   * `protectedOrganizationIds` is captured BEFORE the test creates anything.
//     `safeCleanup()` will REFUSE to delete an organization whose id is in
//     this set, even if it somehow ended up in `createdOrganizationId`.
//   * Deletion order is reverse-dependency (device → space → organization)
//     to satisfy foreign-key style constraints.
//   * Each deletion is wrapped in try/catch so a failure in one step does
//     not block the rest.
//
// This file deliberately uses direct getIt services (not UI navigation) so
// cleanup is fast, deterministic, and independent of screen state.

import 'package:flutter/foundation.dart';

import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/devices/domain/model/commands/delete_device.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_space.command.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';
import 'package:mobile/devices/domain/services/devices.command-service.dart';
import 'package:mobile/devices/domain/services/organizations.command-service.dart';
import 'package:mobile/devices/domain/services/spaces.command-service.dart';

class CleanupState {
  String? createdOrganizationId;
  String? createdSpaceId;
  String? createdDeviceId;

  /// IDs of organizations that existed BEFORE the test began. Cleanup
  /// refuses to delete any organization whose id is in this set.
  Set<String> protectedOrganizationIds = <String>{};

  void reset() {
    createdOrganizationId = null;
    createdSpaceId = null;
    createdDeviceId = null;
    protectedOrganizationIds = <String>{};
  }
}

final CleanupState cleanupState = CleanupState();

Future<void> safeCleanup() async {
  // 1. Device
  if (createdDeviceId != null && createdDeviceId!.isNotEmpty) {
    try {
      final result = await getIt<DevicesCommandService>().handleDeleteDevice(
        DeleteDeviceCommand(deviceId: DeviceId(createdDeviceId!)),
      );
      result.fold(
        (f) => debugPrint('[cleanup] delete device failed: ${f.message}'),
        (_) => debugPrint('[cleanup] device $createdDeviceId deleted'),
      );
    } catch (e) {
      debugPrint('[cleanup] delete device exception: $e');
    }
  }

  // 2. Space
  if (createdSpaceId != null && createdSpaceId!.isNotEmpty) {
    try {
      final result = await getIt<SpacesCommandService>().handleDeleteSpace(
        DeleteSpaceCommand(spaceId: SpaceId(createdSpaceId!)),
      );
      result.fold(
        (f) => debugPrint('[cleanup] delete space failed: ${f.message}'),
        (_) => debugPrint('[cleanup] space $createdSpaceId deleted'),
      );
    } catch (e) {
      debugPrint('[cleanup] delete space exception: $e');
    }
  }

  // 3. Organization — only if it is NOT one of the pre-existing orgs.
  if (createdOrganizationId != null &&
      createdOrganizationId!.isNotEmpty &&
      !protectedOrganizationIds.contains(createdOrganizationId)) {
    try {
      final result =
          await getIt<OrganizationsCommandService>().handleDeleteOrganization(
        DeleteOrganizationCommand(
          organizationId: OrganizationId(createdOrganizationId!),
        ),
      );
      result.fold(
        (f) => debugPrint('[cleanup] delete organization failed: ${f.message}'),
        (_) => debugPrint('[cleanup] organization $createdOrganizationId deleted'),
      );
    } catch (e) {
      debugPrint('[cleanup] delete organization exception: $e');
    }
  } else if (protectedOrganizationIds.contains(createdOrganizationId)) {
    debugPrint(
      '[cleanup] REFUSED to delete protected organization $createdOrganizationId',
    );
  }
}

// Convenience getters so step files can use them without `cleanupState.` prefix
// — they are top-level mutable aliases that point at the same fields.
String? get createdOrganizationId => cleanupState.createdOrganizationId;
set createdOrganizationId(String? v) => cleanupState.createdOrganizationId = v;

String? get createdSpaceId => cleanupState.createdSpaceId;
set createdSpaceId(String? v) => cleanupState.createdSpaceId = v;

String? get createdDeviceId => cleanupState.createdDeviceId;
set createdDeviceId(String? v) => cleanupState.createdDeviceId = v;

Set<String> get protectedOrganizationIds =>
    cleanupState.protectedOrganizationIds;
set protectedOrganizationIds(Set<String> v) =>
    cleanupState.protectedOrganizationIds = v;