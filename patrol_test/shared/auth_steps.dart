// patrol_test/shared/auth_steps.dart
//
// IAM helpers reusable across every happy-path test that needs the user
// to be authenticated.
//
// Each test owns its own login step (no global session): this keeps
// tests independent and lets the report show "login failed for test X"
// rather than "test X failed during step 5 after a shared login".

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart' show PatrolIntegrationTester;

import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/devices/domain/model/queries/get_user_organizations.query.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/services/organizations.query-service.dart';

import 'auth_consts.dart';
import 'cleanup_state.dart';

/// Signs the test user in through the UI and waits for the post-login
/// Analytics tab to appear.
///
/// Assumes the app is currently unauthenticated (test_bootstrap sets
/// AuthSession = false). After this returns, GoRouter has routed to
/// /analytics and the bottom nav is visible.
Future<void> login(PatrolIntegrationTester $) async {
  await $('Login to Clair').waitUntilVisible();
  await $(TextFormField).at(0).enterText(kTestEmail);
  await $(TextFormField).at(1).enterText(kTestPassword);
  await $('Login').tap();
  await $('Analytics').waitUntilVisible();
}

/// Captures the IDs of organizations that exist BEFORE a test creates
/// anything, and writes them to [protectedOrganizationIds] in
/// `cleanup_state.dart`. Tests that create organizations use this set as
/// a safety guard so cleanup never deletes a pre-existing org.
///
/// Returns the list of organizations so callers can do additional
/// assertions if needed.
Future<List<OrganizationReadModel>> snapshotOriginalOrganizations() async {
  final result =
      await getIt<OrganizationsQueryService>().handleGetUserOrganizations(
    const GetUserOrganizationsQuery(),
  );
  return result.fold(
    (f) {
      debugPrint('[setup] failed to load initial orgs: ${f.message}');
      return const <OrganizationReadModel>[];
    },
    (List<OrganizationReadModel> orgs) {
      protectedOrganizationIds = orgs.map((o) => o.id).toSet();
      debugPrint('[setup] protected org IDs: $protectedOrganizationIds');
      return orgs;
    },
  );
}