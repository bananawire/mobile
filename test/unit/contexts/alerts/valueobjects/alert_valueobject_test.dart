import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';

import '../alerts_fixtures.dart';

void main() {
  group('Alert', () {
    test('should expose every mapped field when built from a complete payload',
        () {
      // Arrange / Act
      final alert = buildAlert();

      // Assert
      expect(alert.id.value, 'alert-1');
      expect(alert.deviceId, 'device-1');
      expect(alert.spaceId, 'space-1');
      expect(alert.spaceName, 'Living room');
      expect(alert.deviceName, 'Sensor A');
      expect(alert.metric, MetricType.pm25);
      expect(alert.metricLabel, 'PM2.5');
      expect(alert.metricUnit, 'µg/m³');
      expect(alert.thresholdValue, 35.0);
      expect(alert.actualValue, 52.0);
      expect(alert.message, 'PM2.5 above threshold');
      expect(alert.status, AlertStatus.active);
      expect(alert.severity, AlertSeverity.critical);
      expect(alert.occurredAt, '2024-05-01T10:30:00Z');
      expect(alert.resolvedAt, isNull);
      expect(alert.createdAt, '2024-05-01T10:31:00Z');
    });

    test('should keep the resolved timestamp when the alert was resolved', () {
      // Arrange / Act
      final alert = buildAlert(
        status: AlertStatus.resolved,
        resolvedAt: '2024-05-02T09:15:00Z',
      );

      // Assert
      expect(alert.resolvedAt, '2024-05-02T09:15:00Z');
      expect(alert.status, AlertStatus.resolved);
    });

    test('should expose null space and device details when they are absent',
        () {
      // Arrange / Act
      final alert = buildAlert(
        spaceId: null,
        spaceName: null,
        deviceName: null,
      );

      // Assert
      expect(alert.spaceId, isNull);
      expect(alert.spaceName, isNull);
      expect(alert.deviceName, isNull);
    });

    test('should expose the identifiers as an AlertId value object', () {
      // Arrange / Act
      final alert = buildAlert(id: 'alert-xyz');

      // Assert
      expect(alert.id, isA<AlertId>());
      expect(alert.id.value, 'alert-xyz');
    });

    test('should keep a resolved alert status distinct from an active one',
        () {
      // Arrange
      final active = buildAlert();
      final resolved = buildAlert(
        status: AlertStatus.resolved,
        severity: AlertSeverity.low,
      );

      // Act / Assert
      expect(active.status, isNot(resolved.status));
      expect(resolved.status, AlertStatus.resolved);
      expect(resolved.severity, AlertSeverity.low);
    });

    test('should not define value equality so two identical alerts are distinct '
        'instances', () {
      // Arrange
      final first = buildAlert();
      final second = buildAlert();

      // Act
      final areEqual = first == second;

      // Assert
      expect(areEqual, isFalse);
    });
  });
}