import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';

void main() {
  group('Alert ValueObject', () {
    test('should construct Alert with all required and optional properties', () {
      // Arrange & Act
      final alert = Alert(
        id: AlertId('alert-101'),
        deviceId: 'device-202',
        spaceId: 'space-303',
        spaceName: 'Living Room',
        deviceName: 'Sensor 1',
        metric: MetricType.pm25,
        metricLabel: 'PM2.5',
        metricUnit: 'µg/m³',
        thresholdValue: 25.0,
        actualValue: 42.5,
        message: 'PM2.5 exceeded threshold',
        status: AlertStatus.acknowledged,
        severity: AlertSeverity.warning,
        occurredAt: '2026-10-02T08:30:00Z',
        resolvedAt: '2026-10-02T09:00:00Z',
        createdAt: '2026-10-02T08:31:00Z',
      );

      // Assert
      expect(alert.id.value, equals('alert-101'));
      expect(alert.deviceId, equals('device-202'));
      expect(alert.spaceId, equals('space-303'));
      expect(alert.spaceName, equals('Living Room'));
      expect(alert.deviceName, equals('Sensor 1'));
      expect(alert.metric, equals(MetricType.pm25));
      expect(alert.metricLabel, equals('PM2.5'));
      expect(alert.metricUnit, equals('µg/m³'));
      expect(alert.thresholdValue, equals(25.0));
      expect(alert.actualValue, equals(42.5));
      expect(alert.message, equals('PM2.5 exceeded threshold'));
      expect(alert.status, equals(AlertStatus.acknowledged));
      expect(alert.severity, equals(AlertSeverity.warning));
      expect(alert.occurredAt, equals('2026-10-02T08:30:00Z'));
      expect(alert.resolvedAt, equals('2026-10-02T09:00:00Z'));
      expect(alert.createdAt, equals('2026-10-02T08:31:00Z'));
    });

    test('should allow null for optional properties when not provided', () {
      // Arrange & Act
      final alert = Alert(
        id: AlertId('alert-102'),
        deviceId: 'device-202',
        metric: MetricType.temperature,
        metricLabel: 'Temperature',
        metricUnit: '°C',
        thresholdValue: 30.0,
        actualValue: 34.2,
        message: 'Overheating detected',
        status: AlertStatus.active,
        severity: AlertSeverity.critical,
        occurredAt: '2026-10-02T11:00:00Z',
        createdAt: '2026-10-02T11:00:00Z',
      );

      // Assert
      expect(alert.spaceId, isNull);
      expect(alert.spaceName, isNull);
      expect(alert.deviceName, isNull);
      expect(alert.resolvedAt, isNull);
      expect(alert.status, equals(AlertStatus.active));
      expect(alert.severity, equals(AlertSeverity.critical));
    });
  });
}
