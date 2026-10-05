// patrol_test/iam/ma_us_03_sign_in_test.dart
//
// Covers: MA-US-03 — Iniciar Sesión con Correo y Contraseña
//
// Migrated from the legacy `login_test.dart`. Each test in this folder
// is a single happy-path E2E flow with its own setup, assertions, and
// cleanup.
//
// Runs against:
//   - Android emulator OR physical Android device
//   - Real backend at CLAIR_BACKEND_BASE_URL (loaded from .env)
//
// How to run (from project root, inside nix-shell):
//   # Develop mode (hot-restart the test with 'r' while iterating):
//   patrol develop --target patrol_test/iam/ma_us_03_sign_in_test.dart
//
//   # Single-shot (CI / final validation):
//   patrol test --target patrol_test/iam/ma_us_03_sign_in_test.dart
//
//   # With custom credentials (recommended — never commit real passwords):
//   patrol test --target patrol_test/iam/ma_us_03_sign_in_test.dart \
//     --dart-define TEST_EMAIL=user@example.com \
//     --dart-define TEST_PASSWORD='S3cret!'
//
// Reference: https://patrol.leancode.co/documentation/write-your-first-test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_consts.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  patrolTest(
    'MA-US-03: happy path — sign-in with email and password reaches Analytics',
    ($) async {
      // 1. BOOT the app — runs the bootstrap, mounts GoRouter, and routes
      //    to /login since AuthSession = false. LocaleCubit defaults to
      //    Locale('en'), so the UI is rendered in English.
      await $.pumpWidgetAndSettle(const MyApp());

      // 2. WAIT for the login screen to be visible. The localized title
      //    "Login to Clair" is unique in the app, making it a reliable finder.
      await $('Login to Clair').waitUntilVisible();

      // 3. FILL credentials. The login screen has exactly 2 TextFormFields:
      //    index 0 = email, index 1 = password.
      await $(TextFormField).at(0).enterText(kTestEmail);
      await $(TextFormField).at(1).enterText(kTestPassword);

      // 4. TAP the "Login" button.
      await $('Login').tap();

      // 5. WAIT for navigation + network response. pumpAndSettle gives the
      //    network call (POST /auth/sign-in) up to its default timeout.
      await $.pumpAndSettle();

      // 6. ASSERT outcome: the Analytics bottom-nav tab is visible
      //    post-login. If authentication failed, the user stays on /login
      //    and the Analytics tab never appears.
      await $('Analytics').waitUntilVisible();

      // Sanity: no resources were created in this test, so cleanup is a no-op.
      _assertNoResourcesCreated();
    },
  );
}

void _assertNoResourcesCreated() {
  assert(
    cleanupState.createdOrganizationId == null &&
        cleanupState.createdSpaceId == null &&
        cleanupState.createdDeviceId == null,
    'Sign-in test must not create any resources',
  );
}