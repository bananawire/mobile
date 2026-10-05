import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/domain/model/valueobjects/metric_delta.valueobject.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';
import 'package:mobile/analytics/interfaces/widgets/metric_card.dart';

import 'helpers/analytics_widget_harness.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    required String title,
    required double? value,
    required String unit,
    required double? delta,
    Color statusColor = kGoodColor,
    bool isSelected = false,
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      localizedAnalyticsApp(
        MetricCard(
          title: title,
          value: value,
          unit: unit,
          delta: delta,
          statusColor: statusColor,
          isSelected: isSelected,
          onTap: onTap ?? () {},
        ),
        width: 220,
      ),
    );
  }

  group('MetricCard', () {
    testWidgets('should render the metric title, formatted value and unit',
        (tester) async {
      // Arrange / Act
      await pumpCard(
        tester,
        title: 'PM2.5',
        value: 8.4,
        unit: 'µg/m³',
        delta: null,
      );

      // Assert
      expect(find.text('PM2.5'), findsOneWidget);
      expect(find.text('8.40'), findsOneWidget);
      expect(find.text('µg/m³'), findsOneWidget);
    });

    testWidgets('should render the unit of each dashboard metric verbatim',
        (tester) async {
      // Arrange / Act
      await pumpCard(tester, title: 'CO₂', value: 612, unit: 'ppm', delta: null);

      // Assert
      expect(find.text('CO₂'), findsOneWidget);
      expect(find.text('612.00'), findsOneWidget);
      expect(find.text('ppm'), findsOneWidget);
    });

    testWidgets('should render a placeholder value when the metric is absent',
        (tester) async {
      // Arrange / Act
      await pumpCard(tester, title: 'HUMIDITY', value: null, unit: '%', delta: null);

      // Assert
      expect(find.text('--'), findsOneWidget);
      expect(find.text('0.00'), findsNothing);
    });

    testWidgets('should render a zero reading instead of a placeholder',
        (tester) async {
      // Arrange / Act
      await pumpCard(tester, title: 'TEMP', value: 0, unit: '°C', delta: null);

      // Assert
      expect(find.text('0.00'), findsOneWidget);
      expect(find.text('--'), findsNothing);
    });

    testWidgets('should render a rising delta with an up arrow', (tester) async {
      // Arrange / Act
      await pumpCard(
        tester,
        title: 'CO₂',
        value: 612,
        unit: 'ppm',
        delta: 3.5,
      );

      // Assert
      expect(find.text('3.5%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsNothing);
    });

    testWidgets('should render a flat delta with an up arrow because zero is '
        'not a fall', (tester) async {
      // Arrange / Act
      await pumpCard(tester, title: 'HUMIDITY', value: 48, unit: '%', delta: 0);

      // Assert
      expect(find.text('0.0%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('should render a falling delta with a down arrow',
        (tester) async {
      // Arrange / Act
      await pumpCard(
        tester,
        title: 'PM2.5',
        value: 8.4,
        unit: 'µg/m³',
        delta: -12.25,
      );

      // Assert
      expect(find.text('12.3%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsNothing);
    });

    testWidgets('should render not-available when the metric has no '
        'comparison period', (tester) async {
      // Arrange / Act
      await pumpCard(tester, title: 'TEMP', value: 21.6, unit: '°C', delta: null);

      // Assert
      expect(find.text('N/A'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsNothing);
      expect(find.byIcon(Icons.trending_down), findsNothing);
    });

    testWidgets('should render the value and delta of a metric delta value '
        'object as stored', (tester) async {
      // Arrange
      final metric = MetricDelta(8.4, -12.25);

      // Act
      await pumpCard(
        tester,
        title: 'PM2.5',
        value: metric.value,
        unit: 'µg/m³',
        delta: metric.deltaPercentage,
      );

      // Assert
      expect(find.text('8.40'), findsOneWidget);
      expect(find.text('12.3%'), findsOneWidget);
    });

    testWidgets('should paint the status dot with the given status colour',
        (tester) async {
      // Arrange / Act
      await pumpCard(
        tester,
        title: 'PM2.5',
        value: 70,
        unit: 'µg/m³',
        delta: null,
        statusColor: kUnhealthyColor,
      );

      // Assert
      final dot = tester.widget<Container>(statusDot());
      expect((dot.decoration! as BoxDecoration).color, kUnhealthyColor);
    });

    testWidgets('should notify its tap handler when the card is tapped',
        (tester) async {
      // Arrange
      var taps = 0;
      await pumpCard(
        tester,
        title: 'CO₂',
        value: 612,
        unit: 'ppm',
        delta: null,
        onTap: () => taps++,
      );

      // Act
      await tester.tap(find.byType(MetricCard));
      await tester.pump();

      // Assert
      expect(taps, 1);
    });

    testWidgets('should render a selected card without changing its labels',
        (tester) async {
      // Arrange / Act
      await pumpCard(
        tester,
        title: 'TEMP',
        value: 21.6,
        unit: '°C',
        delta: 1.5,
        isSelected: true,
      );

      // Assert
      expect(find.text('TEMP'), findsOneWidget);
      expect(find.text('21.60'), findsOneWidget);
      expect(find.text('1.5%'), findsOneWidget);
    });
  });
}