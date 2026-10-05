// patrol_test/login_test.dart
//
// Patrol E2E test for the login happy path.
//
// Runs against:
//   - Android emulator OR physical Android device (currently target: 22081212UG)
//   - Real backend at CLAIR_BACKEND_BASE_URL (loaded from .env)
//
// How to run (from project root, inside nix-shell):
//   # Develop mode (hot-restart the test with 'r' while iterating):
//   patrol develop --target patrol_test/login_test.dart
//
//   # Single-shot (CI / final validation):
//   patrol test --target patrol_test/login_test.dart
//
//   # With custom credentials (recommended — never commit real passwords):
//   patrol test --target patrol_test/login_test.dart \
//     --dart-define TEST_EMAIL=user@example.com \
//     --dart-define TEST_PASSWORD='S3cret!'
//
// Reference: https://patrol.leancode.co/documentation/write-your-first-test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import 'test_bootstrap.dart';

void main() {
  // Test credentials. Defaults match what the QA team provided for the first
  // automated run. Override via --dart-define in any non-toy environment.
  const testEmail = String.fromEnvironment(
    'TEST_EMAIL',
    defaultValue: 'fafox59733@findize.com',
  );
  const testPassword = String.fromEnvironment(
    'TEST_PASSWORD',
    defaultValue: 'SecurePass123!',
  );

  setUpAll(() async {
    await initTestApp();
  });

  patrolTest(
    'login: happy path — user authenticates and reaches the analytics screen',
    ($) async {
      // 1. BOOT the app — runs the bootstrap, mounts GoRouter, and routes
      //    to /login since AuthSession = false. LocaleCubit defaults to
      //    Locale('en') (see lib/shared/application/internal/cubits/locale_cubit.dart),
      //    so the UI is rendered in English.
      await $.pumpWidgetAndSettle(const MyApp());

      // 2. WAIT for the login screen to be visible. The localized title
      //    "Login to Clair" is unique in the app, making it a reliable finder.
      await $('Login to Clair').waitUntilVisible();

      // 3. FILL credentials. AuthTextField wraps a TextFormField. The login
      //    screen has exactly 2 TextFormFields: index 0 = email, index 1 = password.
      await $(TextFormField).at(0).enterText(testEmail);
      await $(TextFormField).at(1).enterText(testPassword);

      // 4. TAP the "Login" button. The label comes from AppLocalizations.login_button.
      await $('Login').tap();

      // 5. WAIT for navigation + network response. The login hits the real
      //    backend with a POST. pumpAndSettle (default 10 min timeout) is
      //    more than enough — the screen will re-paint when the response arrives.
      await $.pumpAndSettle();

      // 6. ASSERT outcome: the Analytics bottom-nav tab is visible post-login.
      //    If authentication failed, a SnackBar with the backend error message
      //    would be shown and we would stay on /login, so the Analytics tab
      //    would not appear. If the test fails here, open the emulator/device
      //    and verify that (a) the backend responds, (b) the credentials are
      //    valid, (c) GoRouter navigates correctly to /analytics.
      await $('Analytics').waitUntilVisible();
    },
  );
}