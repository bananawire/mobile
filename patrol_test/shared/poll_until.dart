// patrol_test/shared/poll_until.dart
//
// Cross-cutting polling helper.
//
// Several happy-path tests need to wait for the backend to propagate a
// write (create org / space / device) before they can assert state. Polling
// is REAL TIME via Future.delayed because Patrol's `pumpAndSettle` only
// advances the Flutter clock — it does not wait for the backend.

import 'package:flutter/foundation.dart';

/// Polls [action] until it returns true, waiting [interval] between
/// attempts, with a hard [timeout]. Returns true if it succeeded, false
/// otherwise. Exceptions thrown by [action] are caught and logged so a
/// transient backend hiccup does not abort the poll.
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