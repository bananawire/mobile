// patrol_test/iam/ma_us_05_sign_out_test.dart
//
// Covers: MA-US-05 — Cerrar Sesión
//
// Happy-path: after signing in, the user opens the Settings screen via
// the gear icon in the app bar and taps "Logout". The app must revoke
// the session locally (AuthSession.setAuthenticated(false)) and GoRouter
// must redirect back to /login.
//
// Cleanup at the end is just another sign-in (so the device retains the
// same authenticated state the next test would expect if the suite runs
// sequentially; each test sets up its own state independently though).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_steps.dart';
import '../test_bootstrap.dart';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  patrolTest(
    'MA-US-05: happy path — sign-out from Settings returns the user to the login screen',
    ($) async {
      // 1. BOOT + LOGIN.
      await $.pumpWidgetAndSettle(const MyApp());
      await login($);

      // 2. OPEN Settings via the gear icon in the app bar. There is
      //    exactly one Icons.settings on any non-/settings screen.
      await $(Icons.settings).tap();
      await $('Settings').waitUntilVisible();

      // 3. TAP "Logout". The localized string is `settings_logout` =
      //    "Logout" (see app_localizations_en.dart).
      await $('Logout').tap();

      // 4. ASSERT — GoRouter must redirect back to /login.
      await $('Login to Clair').waitUntilVisible();
    },
  );
}