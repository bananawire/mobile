import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';
import 'package:mobile/alerts/interfaces/widgets/alert_table.dart';

import 'alerts_widget_harness.dart';

void main() {
  group('AlertTable empty state', () {
    testWidgets('should show the empty message when no alerts are provided',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(alertsTestApp(child: const AlertTable()));

      // Assert
      expect(find.text('No alerts found'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off), findsOneWidget);
    });

    testWidgets('should show the empty message when the alert list is empty',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(child: const AlertTable(alerts: <Alert>[])),
      );

      // Assert
      expect(find.text('No alerts found'), findsOneWidget);
    });

    testWidgets('should not show the empty message while the table is loading',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(child: const AlertTable(loading: true)),
      );

      // Assert
      expect(find.text('No alerts found'), findsNothing);
    });
  });

  group('AlertTable loading state', () {
    testWidgets('should show the loading message and a progress indicator '
        'while alerts are being fetched', (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(child: const AlertTable(loading: true)),
      );

      // Assert
      expect(find.text('Loading alerts...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should keep showing the alerts while a refresh is running',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertTable(loading: true, alerts: [buildTestAlert()]),
        ),
      );

      // Assert
      expect(find.text('Loading alerts...'), findsNothing);
      expect(find.text('Sensor A'), findsOneWidget);
    });
  });

  group('AlertTable error state', () {
    testWidgets('should show the error message instead of the empty message',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertTable(error: 'Alerts service is down'),
        ),
      );

      // Assert
      expect(find.text('Alerts service is down'), findsOneWidget);
      expect(find.text('No alerts found'), findsNothing);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('should hide the error state once the message is cleared',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertTable(error: 'Alerts service is down'),
        ),
      );

      // Act
      await tester.pumpWidget(
        alertsTestApp(child: const AlertTable(alerts: <Alert>[])),
      );

      // Assert
      expect(find.text('Alerts service is down'), findsNothing);
      expect(find.text('No alerts found'), findsOneWidget);
    });

    testWidgets('should win over the loading state when both are present',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertTable(loading: true, error: 'Space not found'),
        ),
      );

      // Assert
      expect(find.text('Space not found'), findsOneWidget);
      expect(find.text('Loading alerts...'), findsNothing);
    });
  });

  group('AlertTable header', () {
    testWidgets('should render every column header',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertTable(alerts: <Alert>[buildTestAlert()]),
        ),
      );

      // Assert
      expect(find.text('DEVICE'), findsOneWidget);
      expect(find.text('SEVERITY'), findsOneWidget);
      expect(find.text('SPACE'), findsOneWidget);
      expect(find.text('VARIABLE'), findsOneWidget);
      expect(find.text('TIME'), findsOneWidget);
      expect(find.text('STATUS'), findsOneWidget);
    });
  });

  group('AlertTable rows', () {
    testWidgets('should render the device name, space, metric, severity and '
        'status of an alert', (WidgetTester tester) async {
      // Arrange
      final alerts = [
        buildTestAlert(
          deviceName: 'Sensor A',
          spaceName: 'Living room',
          metric: MetricType.co2,
          severity: AlertSeverity.critical,
          status: AlertStatus.active,
        ),
      ];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertTable(alerts: alerts)));

      // Assert
      expect(find.text('Sensor A'), findsOneWidget);
      expect(find.text('Living room'), findsOneWidget);
      expect(find.text('CO2'), findsOneWidget);
      expect(find.text('CRITICAL'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('should render a placeholder for a missing space name',
        (WidgetTester tester) async {
      // Arrange
      final alerts = [buildTestAlert(spaceName: null)];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertTable(alerts: alerts)));

      // Assert
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('should render the last six characters of the identifier when '
        'the device name is missing', (WidgetTester tester) async {
      // Arrange
      final alerts = [buildTestAlert(id: 'abcdef123456', deviceName: null)];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertTable(alerts: alerts)));

      // Assert
      expect(find.text('123456'), findsOneWidget);
    });

    testWidgets('should render the whole identifier when it is not longer than '
        'six characters', (WidgetTester tester) async {
      // Arrange
      final alerts = [buildTestAlert(id: 'a1', deviceName: null)];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertTable(alerts: alerts)));

      // Assert
      expect(find.text('a1'), findsOneWidget);
    });

    testWidgets('should render the occurrence time in the local hour and minute',
        (WidgetTester tester) async {
      // Arrange
      final alerts = [buildTestAlert(occurredAt: '2024-05-01T10:30:00')];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertTable(alerts: alerts)));

      // Assert
      expect(find.text('10:30'), findsOneWidget);
    });

    testWidgets('should render the raw timestamp when it cannot be parsed',
        (WidgetTester tester) async {
      // Arrange
      final alerts = [buildTestAlert(occurredAt: 'yesterday')];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertTable(alerts: alerts)));

      // Assert
      expect(find.text('yesterday'), findsOneWidget);
    });

    testWidgets('should render one row per alert', (WidgetTester tester) async {
      // Arrange
      final alerts = [
        buildTestAlert(id: 'alert-1', deviceName: 'Sensor A'),
        buildTestAlert(id: 'alert-2', deviceName: 'Sensor B'),
        buildTestAlert(id: 'alert-3', deviceName: 'Sensor C'),
      ];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertTable(alerts: alerts)));

      // Assert
      expect(find.text('Sensor A'), findsOneWidget);
      expect(find.text('Sensor B'), findsOneWidget);
      expect(find.text('Sensor C'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('should render the acknowledged status of a handled alert',
        (WidgetTester tester) async {
      // Arrange
      final alerts = [
        buildTestAlert(
          status: AlertStatus.acknowledged,
          severity: AlertSeverity.low,
          metric: MetricType.humidity,
        ),
      ];

      // Act
      await tester.pumpWidget(alertsTestApp(child: AlertTable(alerts: alerts)));

      // Assert
      expect(find.text('ACKNOWLEDGED'), findsOneWidget);
      expect(find.text('LOW'), findsOneWidget);
      expect(find.text('HUMIDITY'), findsOneWidget);
    });
  });
}