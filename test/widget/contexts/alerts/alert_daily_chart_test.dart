import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/daily_alert_count.valueobject.dart';
import 'package:mobile/alerts/interfaces/widgets/alert_daily_chart.dart';

import 'alerts_widget_harness.dart';

void main() {
  const chartWindow = 30;

  /// `yyyy-MM-dd` for [daysAgo] days before today, matching the key format the
  /// chart builds internally.
  String dayKey(int daysAgo) {
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Every bar container of the chart, in left to right order.
  Finder barFinder() => find.descendant(
        of: find.byType(Align),
        matching: find.byType(Container),
      );

  Color barColorAt(WidgetTester tester, int index) {
    final container = tester.widget<Container>(barFinder().at(index));
    return (container.decoration! as BoxDecoration).color!;
  }

  double barHeightAt(WidgetTester tester, int index) {
    return tester.getSize(barFinder().at(index)).height;
  }

  group('AlertDailyChart', () {
    testWidgets('should render the last thirty days title',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(child: const AlertDailyChart(data: <DailyAlertCount>[])),
      );

      // Assert
      expect(find.text('Last 30 days'), findsOneWidget);
    });

    testWidgets('should render one bar per day of the thirty day window when '
        'the series is empty', (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(child: const AlertDailyChart(data: <DailyAlertCount>[])),
      );

      // Assert
      expect(barFinder(), findsNWidgets(chartWindow));
    });

    testWidgets('should render without data when the series is null',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(alertsTestApp(child: const AlertDailyChart()));

      // Assert
      expect(find.text('Last 30 days'), findsOneWidget);
      expect(barFinder(), findsNWidgets(chartWindow));
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render only a minimal bar for days without alerts',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(child: const AlertDailyChart(data: <DailyAlertCount>[])),
      );

      // Assert
      expect(barHeightAt(tester, 0), lessThan(5));
      expect(
        barColorAt(tester, 0),
        const Color(0xFF10B981).withValues(alpha: 0.3),
      );
    });

    testWidgets('should render a full height bar for the busiest day of the '
        'window', (WidgetTester tester) async {
      // Arrange
      final data = <DailyAlertCount>[
        DailyAlertCount(date: dayKey(3), count: 9),
      ];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertDailyChart(data: data)));

      // Assert
      expect(
        barHeightAt(tester, 3),
        greaterThan(120),
        reason: 'The bucket three days ago is the fourth bar from the left',
      );
      expect(
        barHeightAt(tester, 0),
        lessThan(5),
        reason: 'Days without alerts stay minimal',
      );
    });

    testWidgets('should paint the busiest bar red when the count is above '
        'seven', (WidgetTester tester) async {
      // Arrange
      final data = <DailyAlertCount>[
        DailyAlertCount(date: dayKey(0), count: 12),
      ];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertDailyChart(data: data)));

      // Assert
      expect(barHeightAt(tester, 0), greaterThan(120));
      expect(barColorAt(tester, 0), const Color(0xFFEF4444));
    });

    testWidgets('should paint an amber bar when the count is between four and '
        'seven', (WidgetTester tester) async {
      // Arrange
      final data = <DailyAlertCount>[
        DailyAlertCount(date: dayKey(0), count: 5),
      ];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertDailyChart(data: data)));

      // Assert
      expect(barColorAt(tester, 0), const Color(0xFFF59E0B));
    });

    testWidgets('should paint a green bar when the count is at most three',
        (WidgetTester tester) async {
      // Arrange
      final data = <DailyAlertCount>[
        DailyAlertCount(date: dayKey(0), count: 2),
      ];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertDailyChart(data: data)));

      // Assert
      expect(barColorAt(tester, 0), const Color(0xFF10B981));
    });

    testWidgets('should ignore day buckets that fall outside the thirty day '
        'window', (WidgetTester tester) async {
      // Arrange
      final data = <DailyAlertCount>[
        const DailyAlertCount(date: '1999-01-01', count: 99),
      ];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertDailyChart(data: data)));

      // Assert
      expect(barFinder(), findsNWidgets(chartWindow));
      for (var index = 0; index < chartWindow; index++) {
        expect(
          barHeightAt(tester, index),
          lessThan(5),
          reason: 'A bucket from 1999 must not create a tall bar',
        );
      }
    });

    testWidgets('should not add a bar for each bucket so the window size stays '
        'fixed', (WidgetTester tester) async {
      // Arrange
      final data = List<DailyAlertCount>.generate(
        5,
        (index) => DailyAlertCount(date: dayKey(index), count: index),
      );

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertDailyChart(data: data)));

      // Assert
      expect(barFinder(), findsNWidgets(chartWindow));
    });
  });
}
