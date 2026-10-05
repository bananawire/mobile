// patrol_test/alert_flow/space_steps.dart
//
// Bounded context: devices/space.
//
// Creates a new space inside the given organization via the UI, verifies the
// space belongs to that organization, and discovers its id.
//
// Note on finders:
//   - "Create space" is the tooltip of an IconButton whose icon is
//     `Icons.add`. The tooltip text is NOT a visible widget, so we find by
//     icon. We assert exactly one Icons.add is present to disambiguate
//     from the device "+ Add" button on the next screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/devices/domain/model/queries/get_spaces_by_organization.query.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/space.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/services/spaces.query-service.dart';

import 'cleanup_state.dart';
import 'poll_until.dart';

const String kTestSpaceName = 'E2E Alert Test Space';

/// Creates a new space inside the given organization via the UI. Returns
/// the created [SpaceReadModel] and writes its id into [createdSpaceId].
Future<SpaceReadModel> createSpace(
  $,
  OrganizationReadModel org,
) async {
  // The "Create space" button is an IconButton with `Icons.add`. There is
  // exactly one such button on the SpacesScreen (the only other Icons.add
  // in the app is on the SpaceDevicesScreen, which we have not entered).
  final createSpaceIcon = find.byIcon(Icons.add);
  expect(createSpaceIcon, findsOneWidget,
      reason:
          'SpacesScreen must expose exactly one Icons.add for "Create space"');
  await $.tester.tap(createSpaceIcon);

  // Wait for the bottom sheet to appear (the form's first TextFormField).
  final spaceNameField = $(TextFormField).at(0);
  await spaceNameField.waitUntilVisible();
  await spaceNameField.enterText(kTestSpaceName);
  await $('Create').tap();

  // The sheet pops. The SpacesScreen rebuilds and (after the new space is
  // added to the cubit state) shows the space card with our name. We poll
  // for the space name to confirm the UI has settled.
  await $(kTestSpaceName).waitUntilVisible();

  late SpaceReadModel created;
  final found = await pollUntil(
    () async {
      final r =
          await getIt<SpacesQueryService>().handleGetSpacesByOrganization(
        GetSpacesByOrganizationQuery(
          organizationId: OrganizationId(org.id),
        ),
      );
      return r.fold((_) => false, (spaces) {
        final match = spaces.where((s) => s.name == kTestSpaceName);
        if (match.isEmpty) return false;
        final s = match.first;
        if (s.organizationId != org.id) return false;
        created = s;
        return true;
      });
    },
    timeout: const Duration(seconds: 15),
    description: 'new space inside new org',
  );
  if (!found) {
    throw StateError(
      'Newly created space "$kTestSpaceName" not found under org ${org.id}',
    );
  }
  if (created.organizationId != org.id) {
    throw StateError(
      'Created space ${created.id} belongs to ${created.organizationId}, '
      'expected ${org.id}',
    );
  }
  createdSpaceId = created.id;
  return created;
}

/// Opens the space detail (i.e. the list of devices inside it). SpaceCard
/// does NOT wrap its content in an InkWell — the only way to open the
/// space is via the trailing `Icons.chevron_right` IconButton.
Future<void> openSpace($) async {
  await $(Icons.chevron_right).tap();
}