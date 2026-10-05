// patrol_test/alert_flow/alert_steps.dart
//
// Bounded context: alerts.
//
// Two operations:
//   1. waitForAlert — navigates to the Alerts bottom-nav tab and polls the
//      Active Alerts sub-tab until a row whose device column matches
//      [kNewDeviceName] appears (or times out). On every poll iteration the
//      page is "refreshed" by bouncing through the Spaces tab and back, so
//      AlertsCubit.load() is re-invoked.
//
//   2. waitForAlertGone — symmetric: polls until the device name disappears
//      from the Active tab (the alert was either resolved by the backend or
//      moved to the History tab).

import 'package:flutter_test/flutter_test.dart';

import 'device_steps.dart';
import 'poll_until.dart';

const Duration kAlertPollTimeout = Duration(seconds: 90);
const Duration kAlertPollInterval = Duration(seconds: 5);

/// Polls the Active Alerts tab until a row containing [kNewDeviceName] is
/// visible, refreshing the page by bouncing through the Spaces tab on each
/// iteration. Returns true if the alert appeared within [kAlertPollTimeout].
Future<bool> waitForAlert($) async {
  return pollUntil(
    () async {
      await $('Spaces').tap();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await $('Alerts').tap();
      await $('Active Alerts').waitUntilVisible();
      await $.pumpAndSettle();
      return $(kNewDeviceName).exists;
    },
    timeout: kAlertPollTimeout,
    interval: kAlertPollInterval,
    description: 'alert for "$kNewDeviceName" appears on Active tab',
  );
}

/// Polls the Active Alerts tab until [kNewDeviceName] is no longer present
/// (the alert was resolved or moved to History). Same refresh strategy as
/// [waitForAlert].
Future<bool> waitForAlertGone($) async {
  return pollUntil(
    () async {
      await $('Alerts').tap();
      await $('Active Alerts').waitUntilVisible();
      await $.pumpAndSettle();
      return !$(kNewDeviceName).exists;
    },
    timeout: kAlertPollTimeout,
    interval: kAlertPollInterval,
    description: 'alert for "$kNewDeviceName" leaves Active tab after reset',
  );
}