import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';
import 'package:mobile/alerts/interfaces/widgets/alerts_card.dart';

import 'alerts_widget_harness.dart';

void main() {
  group('AlertCard', () {
    testWidgets('should render the metric label, unit, message and status',
        (WidgetTester tester) async {
      // Arrange
      final alert = buildTestAlert(
        metric: MetricType.co2,
        metricLabel: 'CO2',
        metricUnit: 'ppm',
        message: 'CO2 above threshold',
        status: AlertStatus.active,
      );

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertCard(alert: alert)));

      // Assert
      expect(find.text('CO2'), findsOneWidget);
      expect(find.text('(ppm)'), findsOneWidget);
      expect(find.text('CO2 above threshold'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('should render the threshold and actual values without the '
        'trailing zero', (WidgetTester tester) async {
      // Arrange
      final alert = buildTestAlert(thresholdValue: 35, actualValue: 52.5);

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertCard(alert: alert)));

      // Assert
      expect(find.text('THRESHOLD'), findsOneWidget);
      expect(find.text('ACTUAL'), findsOneWidget);
      expect(find.text('35'), findsOneWidget);
      expect(find.text('52.5'), findsOneWidget);
    });

    testWidgets('should render the formatted occurrence date',
        (WidgetTester tester) async {
      // Arrange
      final alert = buildTestAlert(occurredAt: '2024-05-01T10:30:00');

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertCard(alert: alert)));

      // Assert
      expect(find.text('2024-05-01 10:30'), findsOneWidget);
    });

    testWidgets('should render the raw date when it cannot be parsed',
        (WidgetTester tester) async {
      // Arrange
      final alert = buildTestAlert(occurredAt: 'not-a-date');

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertCard(alert: alert)));

      // Assert
      expect(find.text('not-a-date'), findsOneWidget);
    });

    testWidgets('should not render a resolution date when the alert is still '
        'open', (WidgetTester tester) async {
      // Arrange
      final alert = buildTestAlert(resolvedAt: null);

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertCard(alert: alert)));

      // Assert
      expect(find.textContaining('Resolved'), findsNothing);
    });

    testWidgets('should render the resolution date when the alert was resolved',
        (WidgetTester tester) async {
      // Arrange
      final alert = buildTestAlert(
        status: AlertStatus.resolved,
        occurredAt: '2024-05-01T10:30:00',
        resolvedAt: '2024-05-02T09:15:00',
      );

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertCard(alert: alert)));

      // Assert
      expect(find.text('Resolved 2024-05-02 09:15'), findsOneWidget);
      expect(find.text('RESOLVED'), findsOneWidget);
    });

    testWidgets('should render the metric specific icon',
        (WidgetTester tester) async {
      // Arrange
      final alert = buildTestAlert(metric: MetricType.temperature);

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertCard(alert: alert)));

      // Assert
      expect(find.byIcon(Icons.thermostat), findsOneWidget);
    });

    testWidgets('should render the humidity icon when the metric is humidity',
        (WidgetTester tester) async {
      // Arrange
      final alert = buildTestAlert(metric: MetricType.humidity);

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertCard(alert: alert)));

      // Assert
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
    });
  });
}