// patrol_test/alert_flow/poll_until.dart
//
// Cross-cutting layer: polling.
//
// Wraps the "poll an action until it returns true, with a hard timeout"
// pattern that several steps in the alert-flow E2E test rely on (waiting
// for an org to show in the GET /organizations list, waiting for an alert
// to appear on the Alerts tab, etc.).
//
// Polling here means REAL-TIME waits via Future.delayed. Patrol's
// `pumpAndSettle()` only advances the Flutter clock; it does not actually
// wait for the backend to process threshold changes or to receive
// telemetry that may trigger alerts.

import 'package:flutter/foundation.dart';

/// Polls [action] until it returns true, waiting [interval] between
/// attempts, with a hard [timeout]. Returns true if it succeeded, false
/// otherwise. Exceptions thrown by [action] are caught and logged; they do
/// not abort the poll (the backend may be transiently unreachable).
Future<bool> pollUntil(
  Future<bool> Function() action, {
  required Duration timeout,
  Duration interval = const Duration(seconds: 3),
  required String description,
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    try {
      final result = await action();
      if (result) return true;
    } catch (e) {
      debugPrint('[poll:$description] exception: $e');
    }
    await Future<void>.delayed(interval);
  }
  debugPrint('[poll:$description] timed out after ${timeout.inSeconds}s');
  return false;
}