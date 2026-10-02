import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_page.resource.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_response.resource.dart';
import 'package:mobile/alerts/interfaces/rest/resources/daily_alert_summary.resource.dart';
import 'package:mobile/alerts/interfaces/rest/transform/alerts_transform.dart';

void main() {
  group('alerts_transform', () {
    test('should map AlertResponseResource to Alert domain model with all fields intact', () {
      // Arrange
      final resource = AlertResponseResource(
        id: 'alert-123',
        deviceId: 'device-456',
        spaceId: 'space-789',
        spaceName: 'Conference Room',
        deviceName: 'Air Monitor A',
        metric: 'CO2',
        metricLabel: 'CO2',
        metricUnit: 'ppm',
        thresholdValue: 800,
        actualValue: 1050,
        message: 'High CO2 level in Conference Room',
        status: 'ACKNOWLEDGED',
        severity: 'WARNING',
        occurredAt: '2026-10-02T14:00:00Z',
        resolvedAt: '2026-10-02T15:00:00Z',
        createdAt: '2026-10-02T14:01:00Z',
      );

      // Act
      final alert = alertResponseResourceToDomain(resource);

      // Assert
      expect(alert.id.value, equals('alert-123'));
      expect(alert.deviceId, equals('device-456'));
      expect(alert.spaceId, equals('space-789'));
      expect(alert.spaceName, equals('Conference Room'));
      expect(alert.deviceName, equals('Air Monitor A'));
      expect(alert.metric, equals(MetricType.co2));
      expect(alert.metricLabel, equals('CO2'));
      expect(alert.metricUnit, equals('ppm'));
      expect(alert.thresholdValue, equals(800.0));
      expect(alert.actualValue, equals(1050.0));
      expect(alert.message, equals('High CO2 level in Conference Room'));
      expect(alert.status, equals(AlertStatus.acknowledged));
      expect(alert.severity, equals(AlertSeverity.warning));
      expect(alert.occurredAt, equals('2026-10-02T14:00:00Z'));
      expect(alert.resolvedAt, equals('2026-10-02T15:00:00Z'));
      expect(alert.createdAt, equals('2026-10-02T14:01:00Z'));
    });

    test('should fallback to default values when metric, status, or severity are unknown', () {
      // Arrange
      final resource = AlertResponseResource(
        id: 'alert-default',
        deviceId: 'device-default',
        metric: 'UNKNOWN_METRIC',
        metricLabel: 'Unknown',
        metricUnit: 'unit',
        thresholdValue: 10,
        actualValue: 20,
        message: 'Alert with unknown enum values',
        status: 'INVALID_STATUS',
        severity: 'INVALID_SEVERITY',
        occurredAt: '2026-10-02T10:00:00Z',
        createdAt: '2026-10-02T10:00:00Z',
      );

      // Act
      final alert = alertResponseResourceToDomain(resource);

      // Assert
      expect(alert.metric, equals(MetricType.pm25));
      expect(alert.status, equals(AlertStatus.active));
      expect(alert.severity, equals(AlertSeverity.low));
    });

    test('should map AlertPageResource to AlertPage domain model', () {
      // Arrange
      final res1 = AlertResponseResource(
        id: 'alert-page-1',
        deviceId: 'dev-1',
        metric: 'TEMPERATURE',
        metricLabel: 'Temperature',
        metricUnit: '°C',
        thresholdValue: 28,
        actualValue: 31.5,
        message: 'High temp',
        status: 'RESOLVED',
        severity: 'LOW',
        occurredAt: '2026-10-02T08:00:00Z',
        createdAt: '2026-10-02T08:00:00Z',
      );
      final pageResource = AlertPageResource(
        content: [res1],
        totalElements: 15,
        totalPages: 2,
        size: 10,
        number: 1,
      );

      // Act
      final alertPage = alertPageResourceToDomain(pageResource);

      // Assert
      expect(alertPage.content.length, equals(1));
      expect(alertPage.content.first.id.value, equals('alert-page-1'));
      expect(alertPage.content.first.metric, equals(MetricType.temperature));
      expect(alertPage.totalElements, equals(15));
      expect(alertPage.totalPages, equals(2));
      expect(alertPage.size, equals(10));
      expect(alertPage.number, equals(1));
      expect(alertPage.page, equals(1));
    });

    test('should map DailyAlertSummaryResource to DailyAlertCount domain model', () {
      // Arrange
      const summaryResource = DailyAlertSummaryResource(
        date: '2026-10-02',
        count: 14.0,
      );

      // Act
      final count = dailyAlertSummaryResourceToDomain(summaryResource);

      // Assert
      expect(count.date, equals('2026-10-02'));
      expect(count.count, equals(14));
    });
  });
}
