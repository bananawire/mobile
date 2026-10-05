import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/interfaces/widgets/calendar_selector.dart';

import 'helpers/analytics_widget_harness.dart';

void main() {
  Future<void> pumpSelector(
    WidgetTester tester, {
    required String selectedPeriod,
    DateTime? startDate,
    DateTime? endDate,
    ValueChanged<String>? onSelectPreset,
    void Function(DateTime start, DateTime end)? onSelectCustom,
  }) async {
    await tester.pumpWidget(
      localizedAnalyticsApp(
        CalendarSelector(
          selectedPeriod: selectedPeriod,
          startDate: startDate,
          endDate: endDate,
          onSelectPreset: onSelectPreset ?? (_) {},
          onSelectCustom: onSelectCustom ?? (_, _) {},
        ),
      ),
    );
  }

  group('CalendarSelector label', () {
    testWidgets('should read as history while live data is selected',
        (tester) async {
      // Arrange / Act
      await pumpSelector(tester, selectedPeriod: 'LIVE');

      // Assert
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('should read as the selected preset', (tester) async {
      // Arrange / Act
      await pumpSelector(tester, selectedPeriod: 'Day');

      // Assert
      expect(find.text('Day'), findsOneWidget);
    });

    testWidgets('should read as the selected week preset', (tester) async {
      // Arrange / Act
      await pumpSelector(tester, selectedPeriod: 'Week');

      // Assert
      expect(find.text('Week'), findsOneWidget);
    });

    testWidgets('should read as the selected month preset', (tester) async {
      // Arrange / Act
      await pumpSelector(tester, selectedPeriod: 'Month');

      // Assert
      expect(find.text('Month'), findsOneWidget);
    });

    testWidgets('should read as the zero padded custom range when both dates '
        'are known', (tester) async {
      // Arrange / Act
      await pumpSelector(
        tester,
        selectedPeriod: 'CUSTOM',
        startDate: DateTime(2024, 5, 1),
        endDate: DateTime(2024, 5, 8),
      );

      // Assert
      expect(find.text('05/01 – 05/08'), findsOneWidget);
    });

    testWidgets('should read as a plain custom label when the range is not '
        'set yet', (tester) async {
      // Arrange / Act
      await pumpSelector(tester, selectedPeriod: 'CUSTOM');

      // Assert
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('should read as history for an unrecognised period',
        (tester) async {
      // Arrange / Act
      await pumpSelector(tester, selectedPeriod: 'SOMETHING_ELSE');

      // Assert
      expect(find.text('History'), findsOneWidget);
    });
  });

  group('CalendarSelector range selection', () {
    testWidgets('should open the preset menu with every available range',
        (tester) async {
      // Arrange
      await pumpSelector(tester, selectedPeriod: 'LIVE');

      // Act
      await tester.tap(find.byType(CalendarSelector));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Custom range…'), findsOneWidget);
    });

    testWidgets('should report the day preset when it is picked', (tester) async {
      // Arrange
      final selected = <String>[];
      await pumpSelector(
        tester,
        selectedPeriod: 'LIVE',
        onSelectPreset: selected.add,
      );

      // Act
      await tester.tap(find.byType(CalendarSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();

      // Assert
      expect(selected, <String>['Day']);
    });

    testWidgets('should report the week preset when it is picked',
        (tester) async {
      // Arrange
      final selected = <String>[];
      await pumpSelector(
        tester,
        selectedPeriod: 'LIVE',
        onSelectPreset: selected.add,
      );

      // Act
      await tester.tap(find.byType(CalendarSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();

      // Assert
      expect(selected, <String>['Week']);
    });

    testWidgets('should report the month preset when it is picked',
        (tester) async {
      // Arrange
      final selected = <String>[];
      await pumpSelector(
        tester,
        selectedPeriod: 'LIVE',
        onSelectPreset: selected.add,
      );

      // Act
      await tester.tap(find.byType(CalendarSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();

      // Assert
      expect(selected, <String>['Month']);
    });

    testWidgets('should report the confirmed custom range to the range '
        'callback', (tester) async {
      // Arrange
      final ranges = <DateTimeRange>[];
      final start = DateTime.now().subtract(const Duration(days: 20));
      final end = DateTime.now().subtract(const Duration(days: 10));
      await pumpSelector(
        tester,
        selectedPeriod: 'LIVE',
        startDate: start,
        endDate: end,
        onSelectCustom: (from, to) => ranges.add(DateTimeRange(start: from, end: to)),
      );

      // Act — open the menu, choose the custom entry, confirm the prefilled
      // range in the material date range picker.
      await tester.tap(find.byType(CalendarSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom range…'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert — the material picker reports date-only boundaries.
      expect(ranges, hasLength(1));
      expect(ranges.single.start, DateTime(start.year, start.month, start.day));
      expect(ranges.single.end, DateTime(end.year, end.month, end.day));
      expect(find.text('Custom range…'), findsNothing);
    });

    testWidgets('should not report any range when the picker is cancelled',
        (tester) async {
      // Arrange
      final ranges = <DateTimeRange>[];
      await pumpSelector(
        tester,
        selectedPeriod: 'LIVE',
        onSelectCustom: (from, to) => ranges.add(DateTimeRange(start: from, end: to)),
      );

      // Act
      await tester.tap(find.byType(CalendarSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom range…'));
      await tester.pumpAndSettle();
      expect(find.text('Save'), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();

      // Assert
      expect(ranges, isEmpty);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('should not report a preset when the custom entry is picked',
        (tester) async {
      // Arrange
      final selected = <String>[];
      await pumpSelector(
        tester,
        selectedPeriod: 'LIVE',
        onSelectPreset: selected.add,
      );

      // Act
      await tester.tap(find.byType(CalendarSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom range…'));
      await tester.pumpAndSettle();

      // Assert
      expect(selected, isEmpty);
    });
  });
}