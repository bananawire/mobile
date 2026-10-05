// patrol_test/alert_flow/organization_steps.dart
//
// Bounded context: devices/organization.
//
// Creates a new organization via the UI and discovers its id by re-listing
// the user's organizations. The new organization id is written to
// [createdOrganizationId] in cleanup_state.dart so the cleanup layer can
// delete it on tearDown.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/devices/domain/model/queries/get_user_organizations.query.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/services/organizations.query-service.dart';

import 'cleanup_state.dart';
import 'poll_until.dart';

const String kTestOrganizationName = 'E2E Alert Test Organization';

/// Navigates from the analytics screen to the Organizations list and creates
/// a new organization whose name is [kTestOrganizationName]. Returns the
/// created [OrganizationReadModel] (so callers can read its id) and writes
/// the id into [createdOrganizationId] for cleanup.
Future<OrganizationReadModel> createOrganization($) async {
  // Bottom nav: Analytics → Spaces (which IS the Organizations screen).
  await $('Spaces').tap();
  await $('Organizations').waitUntilVisible();

  // The "Add Organization" button has visible text (its label is
  // `org_btn_add` = "Add Organization"); it is NOT a tooltip.
  await $('Add Organization').tap();
  final orgNameField = $(TextFormField).at(0);
  await orgNameField.waitUntilVisible();
  await orgNameField.enterText(kTestOrganizationName);
  await $('Create').tap();
  await $('Organizations').waitUntilVisible();

  // The UI shows the org name on the card but not its id. Discover the id
  // by re-querying the user's organizations through the service locator.
  late OrganizationReadModel created;
  final found = await pollUntil(
    () async {
      final r = await getIt<OrganizationsQueryService>()
          .handleGetUserOrganizations(const GetUserOrganizationsQuery());
      return r.fold((_) => false, (orgs) {
        final match = orgs.where((o) => o.name == kTestOrganizationName);
        if (match.isEmpty) return false;
        created = match.first;
        return true;
      });
    },
    timeout: const Duration(seconds: 15),
    description: 'new organization in list',
  );
  if (!found) {
    throw StateError('Newly created organization did not appear in the list');
  }
  createdOrganizationId = created.id;
  return created;
}

/// Opens the organization detail (i.e. the list of spaces inside it).
///
/// OrganizationCard has an InkWell that wraps the whole card, but the
/// Text widget that displays the name can be ambiguous (it matches the
/// same text we used in the form). To be safe, tap the trailing
/// `Icons.chevron_right` button (the "Open" action) which has a direct
/// onPressed = onTap and is unambiguous on the OrganizationsScreen.
Future<void> openOrganization($) async {
  await $(Icons.chevron_right).tap();
}