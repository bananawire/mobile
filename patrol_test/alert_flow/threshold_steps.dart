// patrol_test/alert_flow/threshold_steps.dart
//
// Bounded context: devices/device (threshold sub-feature).
//
// Opens the threshold editor dialog, drives each of the 4 vertical sliders
// to the minimum allowed value, saves, and (optionally) resets to the
// defaults via the RESET button.
//
// Min/max are defined in `DeviceThresholdsEditorDialog`:
//   PM2.5        : min=1,    step=1
//   CO2          : min=100,  step=10
//   Temperature  : min=5,    step=0.1
//   Humidity     : min=1,    step=1

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the threshold editor dialog and sets every metric to its minimum
/// allowed value, then saves.
Future<void> setThresholdsToMinimum($) async {
  // The thresholds edit IconButton is the only Icons.edit on the device
  // detail screen at this point — the popup menu uses Icons.edit_outlined.
  await $(Icons.edit).tap();
  await $('SAVE').waitUntilVisible();
  await $('RESET').waitUntilVisible();

  // The editor exposes exactly 4 GestureDetectors with onVerticalDragUpdate
  // — one per slider column.
  final sliders = find.byWidgetPredicate(
    (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
  );
  expect(sliders, findsNWidgets(4),
      reason:
          'Threshold editor must expose 4 vertical sliders (one per metric)');

  // Drive each slider to its minimum by tapping near the bottom of its
  // bounds. The slider uses a GestureDetector with `onTapDown` that maps
  // the tap's local Y to a value via `value = max - (max-min)*progress`.
  // Tapping near the bottom sets progress ≈ 1 → value ≈ min.
  for (var i = 0; i < 4; i++) {
    final slider = sliders.at(i);
    final box = slider.evaluate().first.renderObject as RenderBox;
    final local = Offset(box.size.width / 2, box.size.height - 6);
    final global = box.localToGlobal(local);
    await $.tester.tapAt(global);
    await $.pumpAndSettle();
  }

  await $('SAVE').tap();
  await $('Thresholds saved successfully.').waitUntilVisible();
}

/// Opens the threshold editor and presses RESET to restore the defaults,
/// then saves.
Future<void> resetThresholdsToDefaults($) async {
  await $(Icons.edit).tap();
  await $('RESET').waitUntilVisible();
  await $('RESET').tap();
  await $('SAVE').tap();
  await $('Thresholds saved successfully.').waitUntilVisible();
}