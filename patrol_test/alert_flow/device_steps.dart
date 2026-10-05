// patrol_test/alert_flow/device_steps.dart
//
// Bounded context: devices/device.
//
// Three sub-flows live here:
//   1. Pair + claim — the device is introduced to the backend via the "Pair
//      device" action (returns a one-time claim token shown in an
//      AlertDialog), then claimed into the space via "Add device".
//   2. Edit name    — open the popup menu (Icons.more_vert) → tap "Edit",
//      change the name in the pre-filled TextFormField, tap "Save".
//
// IMPORTANT:
//   - The claim token is read OUT OF THE DIALOG by extracting the text
//     after the "Claim token: " prefix. It is NEVER hard-coded.
//   - The new device id is discovered by listing the space's devices via
//     the DevicesGateway and matching on the serialNumber / hardwareId.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/devices/infrastructure/api/gateways/devices.gateway.dart';

import 'cleanup_state.dart';
import 'poll_until.dart';

const String kHardwareId = 'CLAIR-0003';
const String kSerialNumber = 'SN-0003';
const String kInitialDeviceName = 'Sensor 0003';
const String kNewDeviceName = 'Sensor 0003 Edited';

/// Performs the Pair + Claim sub-flow against the SpaceDevicesScreen for
/// the given [spaceId]. Writes the discovered device id into
/// [createdDeviceId]. Returns the claim token that was issued by the
/// backend (so callers can assert its shape).
Future<String> pairAndClaimDevice($, String spaceId) async {
  // The SpaceDevicesScreen has two IconButtons on its app bar:
  //   * Icons.add → tooltip "Add device"  → opens ClaimDeviceForm
  //   * Icons.wifi_tethering_outlined → tooltip "Pair device" → opens PairDeviceForm
  // We pair first (to get the claim token), then claim using that token.
  await $(Icons.wifi_tethering_outlined).tap();

  // PairDeviceForm sheet.
  final hardwareIdField = $(TextFormField).at(0);
  await hardwareIdField.waitUntilVisible();
  await hardwareIdField.enterText(kHardwareId);
  await $('Pair').tap();

  // AlertDialog "Pairing started" with text "Claim token: <token>".
  // Wait for the dialog AND for the dialog to be the topmost — the user reported
  // that on flaky runs the sheet stays around, so we give the navigator a beat
  // to dismiss the bottom sheet before we try to read the token.
  await $('Pairing started').waitUntilVisible();
  await Future<void>.delayed(const Duration(milliseconds: 500));

  // If the dialog says "No claim token returned.", the backend refused to
  // mint a token (e.g. unknown hardwareId). Surface that as an explicit
  // failure rather than trying to extract a bogus token.
  final noTokenLabel = $('No claim token returned.');
  if (noTokenLabel.exists) {
    throw StateError(
      'Pairing succeeded but the backend did not return a claim token. '
      'The dialog shows: "No claim token returned."',
    );
  }

  // Read the token out of the dialog text.
  final tokenElement = find.textContaining('Claim token: ').evaluate().first;
  final tokenText = (tokenElement.widget as Text).data ?? '';
  final claimToken = tokenText.substring('Claim token: '.length).trim();

  debugPrint(
    '[device] claim token raw: "$tokenText" → length=${claimToken.length}',
  );

  if (claimToken.isEmpty) {
    throw StateError(
      'Pairing returned an empty claim token (raw text="$tokenText")',
    );
  }
  // The token format is backend-defined — keep the sanity floor permissive
  // so we do not over-fit to a single deployment.
  if (claimToken.length < 6) {
    throw StateError(
      'Pairing returned a suspiciously short claim token (length='
      '${claimToken.length}, raw="$tokenText")',
    );
  }

  // Close the dialog and proceed to claim.
  await $('Close').tap();
  await $(Icons.add).waitUntilVisible();

  // ClaimDeviceForm (the green + button).
  await $(Icons.add).tap();
  final tokenInputField = $(TextFormField).at(0);
  await tokenInputField.waitUntilVisible();
  await tokenInputField.enterText(claimToken);
  await $('Add').tap();

  // Wait for the device to appear in the list (serial chip).
  await $('SN-0003').waitUntilVisible();

  // Discover the device id via the gateway; cleanup needs it.
  late String deviceId;
  final found = await pollUntil(
    () async {
      final raw = await getIt<DevicesGateway>().getDevicesBySpaceRaw(
        spaceId: spaceId,
      );
      final content = (raw['content'] as List?) ?? const [];
      for (final item in content) {
        if (item is Map &&
            (item['serialNumber'] == kSerialNumber ||
                item['hardwareId'] == kHardwareId)) {
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
      'Newly claimed device $kSerialNumber not found in space $spaceId',
    );
  }
  createdDeviceId = deviceId;
  return claimToken;
}

/// Opens the device detail screen by tapping the device tile (by serial).
Future<void> openDevice($) async {
  await $('SN-0003').tap();
  await $('Sensor 0003').waitUntilVisible();
}

/// Edits the device name via the popup menu → Edit → Save flow.
Future<void> editDeviceName($) async {
  // The 3-dot popup menu is the only Icons.more_vert on the screen.
  await $(Icons.more_vert).tap();
  await $('Edit').tap();

  // EditDeviceNameForm: pre-filled TextFormField. Clear and re-type.
  final editNameField = $(TextFormField).at(0);
  await editNameField.waitUntilVisible();
  await editNameField.enterText('');
  await editNameField.enterText(kNewDeviceName);
  await $('Save').tap();

  // Wait for the new name in the device detail header.
  await $(kNewDeviceName).waitUntilVisible();
}