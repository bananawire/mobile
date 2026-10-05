// patrol_test/devices/ma_us_12_pair_device_test.dart
//
// Covers: MA-US-12 — Vincular Dispositivo
//
// Happy path: in a new space, taps "Pair device" (Icons.wifi_tethering),
// fills the hardwareId, taps Pair, and the backend responds with a
// non-empty claim token in the "Pairing started" dialog.
//
// The token is read from the dialog (NEVER hard-coded). The test does
// NOT claim the device — that is MA-US-13.
//
// Cleanup deletes the device (if it was incidentally created), the space,
// and the organization. Pairing itself does not persist a device, so the
// device id is normally null after this test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:mobile/main.dart';

import '../shared/auth_consts.dart';
import '../shared/auth_steps.dart';
import '../shared/cleanup_state.dart';
import '../test_bootstrap.dart';
import '_helpers.dart';

const String _kOrgName = 'E2E MA-US-12 Org';
const String _kSpaceName = 'E2E MA-US-12 Space';

void main() {
  setUpAll(() async {
    await initTestApp();
  });

  tearDown(() async {
    await safeCleanup();
  });

  patrolTest(
    'MA-US-12: happy path — pair device and receive a non-empty claim token',
    ($) async {
      cleanupState.reset();
      await snapshotOriginalOrganizations();

      await $.pumpWidgetAndSettle(const MyApp());
      await login($);
      await navigateToOrganizations($);

      final org = await createOrganization($, _kOrgName);
      await navigateToOrganization($);
      await createSpace($, org, _kSpaceName);
      await navigateToSpace($);

      // Pair only — no claim.
      await $(Icons.wifi_tethering_outlined).tap();
      final hardwareIdField = $(TextFormField).at(0);
      await hardwareIdField.waitUntilVisible();
      await hardwareIdField.enterText(kTestHardwareId);
      await $('Pair').tap();

      await $('Pairing started').waitUntilVisible();
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // The dialog must contain a non-empty token.
      final tokenElement =
          find.textContaining('Claim token: ').evaluate().first;
      final tokenText = (tokenElement.widget as Text).data ?? '';
      final claimToken = tokenText.substring('Claim token: '.length).trim();
      expect(claimToken.length, greaterThanOrEqualTo(6),
          reason: 'Backend must return a non-trivial claim token, got: '
              '"$claimToken"');

      // The dialog is dismissed by the test bootstrap on tearDown; no
      // device was created, so cleanupState.createdDeviceId stays null.
    },
  );
}