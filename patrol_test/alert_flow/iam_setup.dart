// patrol_test/alert_flow/iam_setup.dart
//
// Bounded context: iam (Identity & Access Management).
//
// This file owns the login step. It is reused by the alert-flow E2E test to
// put the app in an authenticated state before exercising the rest of the
// flow. The same default credentials are used as in `login_test.dart`.
//
// It also captures the IDs of organizations that existed BEFORE the test
// ran — those IDs are written to [protectedOrganizationIds] in
// cleanup_state.dart so the cleanup layer refuses to delete them.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/devices/domain/model/queries/get_user_organizations.query.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/services/organizations.query-service.dart';

import 'cleanup_state.dart';

// QA credentials (same defaults as login_test.dart).
const String kTestEmail = 'fafox59733@findize.com';
const String kTestPassword = 'SecurePass123!';

/// Performs the login flow through the UI.
///
/// Assumes the app is currently unauthenticated (the test_bootstrap sets
/// AuthSession = false). After login, GoRouter redirects to /analytics.
Future<void> login($) async {
  await $('Login to Clair').waitUntilVisible();
  await $(TextFormField).at(0).enterText(kTestEmail);
  await $(TextFormField).at(1).enterText(kTestPassword);
  await $('Login').tap();
  await $('Analytics').waitUntilVisible();
}

/// Captures the IDs of organizations that exist BEFORE the test creates
/// anything, and writes them to [protectedOrganizationIds]. The cleanup
/// layer uses this set to refuse to delete any organization that the user
/// already had.
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