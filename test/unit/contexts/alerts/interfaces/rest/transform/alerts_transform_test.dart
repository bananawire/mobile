import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_page.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/daily_alert_count.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_page.resource.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_response.resource.dart';
import 'package:mobile/alerts/interfaces/rest/resources/daily_alert_summary.resource.dart';
import 'package:mobile/alerts/interfaces/rest/transform/alerts_transform.dart';

import '../../../alerts_fixtures.dart';

void main() {
  group('alertResponseResourceToDomain', () {
    test('should map every resource field to the domain alert', () {
      // Arrange
      final resource = AlertResponseResource.fromJson(resolvedAlertJson());

      // Act
      final alert = alertResponseResourceToDomain(resource);

      // Assert
      expect(alert.id.value, 'alert-2');
      expect(alert.deviceId, 'device-2');
      expect(alert.spaceId, 'space-2');
      expect(alert.spaceName, 'Bedroom');
      expect(alert.deviceName, 'Sensor B');
      expect(alert.metric, MetricType.temperature);
      expect(alert.metricLabel, 'Temperature');
      expect(alert.metricUnit, '°C');
      expect(alert.thresholdValue, 30.0);
      expect(alert.actualValue, 33.0);
      expect(alert.message, 'Temperature above threshold');
      expect(alert.status, AlertStatus.resolved);
      expect(alert.severity, AlertSeverity.warning);
      expect(alert.occurredAt, '2024-05-02T08:00:00Z');
      expect(alert.resolvedAt, '2024-05-02T09:15:00Z');
      expect(alert.createdAt, '2024-05-02T08:01:00Z');
    });

    test('should convert integer resource thresholds into doubles', () {
      // Arrange
      final resource = AlertResponseResource.fromJson(
        alertJson(thresholdValue: 35, actualValue: 52),
      );

      // Act
      final alert = alertResponseResourceToDomain(resource);

      // Assert
      expect(alert.thresholdValue, isA<double>());
      expect(alert.actualValue, isA<double>());
      expect(alert.thresholdValue, 35.0);
    });

    test('should decode each known metric wire code', () {
      // Arrange
      const expected = <String, MetricType>{
        'PM25': MetricType.pm25,
        'CO2': MetricType.co2,
        'TEMPERATURE': MetricType.temperature,
        'HUMIDITY': MetricType.humidity,
      };

      // Act / Assert
      expected.forEach((wire, metric) {
        final alert = alertResponseResourceToDomain(
          AlertResponseResource.fromJson(alertJson(metric: wire)),
        );
        expect(alert.metric, metric, reason: 'wire code $wire');
      });
    });

    test('should decode each known status wire code', () {
      // Arrange
      const expected = <String, AlertStatus>{
        'ACTIVE': AlertStatus.active,
        'ACKNOWLEDGED': AlertStatus.acknowledged,
        'RESOLVED': AlertStatus.resolved,
      };

      // Act / Assert
      expected.forEach((wire, status) {
        final alert = alertResponseResourceToDomain(
          AlertResponseResource.fromJson(alertJson(status: wire)),
        );
        expect(alert.status, status, reason: 'wire code $wire');
      });
    });

    test('should decode each known severity wire code', () {
      // Arrange
      const expected = <String, AlertSeverity>{
        'CRITICAL': AlertSeverity.critical,
        'WARNING': AlertSeverity.warning,
        'LOW': AlertSeverity.low,
      };

      // Act / Assert
      expected.forEach((wire, severity) {
        final alert = alertResponseResourceToDomain(
          AlertResponseResource.fromJson(alertJson(severity: wire)),
        );
        expect(alert.severity, severity, reason: 'wire code $wire');
      });
    });

    test('should fall back to pm25 when the metric wire code is unknown', () {
      // Arrange
      final resource = AlertResponseResource.fromJson(
        alertJson(metric: 'RADIATION'),
      );

      // Act
      final alert = alertResponseResourceToDomain(resource);

      // Assert
      expect(alert.metric, MetricType.pm25);
    });

    test('should fall back to active when the status wire code is unknown', () {
      // Arrange
      final resource = AlertResponseResource.fromJson(
        alertJson(status: 'ARCHIVED'),
      );

      // Act
      final alert = alertResponseResourceToDomain(resource);

      // Assert
      expect(alert.status, AlertStatus.active);
    });

    test('should fall back to low when the severity wire code is unknown', () {
      // Arrange
      final resource = AlertResponseResource.fromJson(
        alertJson(severity: 'FATAL'),
      );

      // Act
      final alert = alertResponseResourceToDomain(resource);

      // Assert
      expect(alert.severity, AlertSeverity.low);
    });

    test('should keep the optional space and device fields null when they are '
        'absent from the resource', () {
      // Arrange
      final resource = AlertResponseResource.fromJson(
        alertJson(spaceId: null, spaceName: null, deviceName: null),
      );

      // Act
      final alert = alertResponseResourceToDomain(resource);

      // Assert
      expect(alert.spaceId, isNull);
      expect(alert.spaceName, isNull);
      expect(alert.deviceName, isNull);
    });

    test('should keep an unresolved alert without a resolved timestamp', () {
      // Arrange
      final resource = AlertResponseResource.fromJson(alertJson());

      // Act
      final alert = alertResponseResourceToDomain(resource);

      // Assert
      expect(alert.resolvedAt, isNull);
    });

    test('should copy the timestamp strings verbatim without reformatting them',
        () {
      // Arrange
      final resource = AlertResponseResource.fromJson(
        alertJson(
          occurredAt: '2024-05-01T10:30:00.123Z',
          createdAt: '2024-05-01T10:31:00.456+02:00',
        ),
      );

      // Act
      final alert = alertResponseResourceToDomain(resource);

      // Assert
      expect(alert.occurredAt, '2024-05-01T10:30:00.123Z');
      expect(alert.createdAt, '2024-05-01T10:31:00.456+02:00');
    });

    test('should throw ArgumentError when the resource identifier is blank',
        () {
      // Arrange
      final resource = AlertResponseResource.fromJson(alertJson(id: '   '));

      // Act / Assert
      expect(
        () => alertResponseResourceToDomain(resource),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Alert ID is required',
          ),
        ),
      );
    });

    test('should wrap the identifier in an AlertId value object', () {
      // Arrange
      final resource = AlertResponseResource.fromJson(alertJson(id: 'a-1'));

      // Act
      final alert = alertResponseResourceToDomain(resource);

      // Assert
      expect(alert.id, isA<AlertId>());
      expect(alert.id.value, 'a-1');
    });
  });

  group('alertPageResourceToDomain', () {
    test('should map every item of the page and keep the pagination metadata',
        () {
      // Arrange
      final resource = AlertPageResource.fromJson(
        alertPageJson(
          content: [alertJson(), resolvedAlertJson()],
          totalElements: 41,
          totalPages: 3,
          size: 20,
          number: 1,
        ),
      );

      // Act
      final page = alertPageResourceToDomain(resource);

      // Assert
      expect(page.content, hasLength(2));
      expect(page.content.first.status, AlertStatus.active);
      expect(page.content.last.status, AlertStatus.resolved);
      expect(page.totalElements, 41);
      expect(page.totalPages, 3);
      expect(page.size, 20);
      expect(page.number, 1);
    });

    test('should map an empty page to an empty content list instead of '
        'failing', () {
      // Arrange
      final resource = AlertPageResource.fromJson(emptyAlertPageJson);

      // Act
      final page = alertPageResourceToDomain(resource);

      // Assert
      expect(page, isA<AlertPage>());
      expect(page.content, isEmpty);
      expect(page.totalElements, 0);
    });

    test('should keep the item order of the page', () {
      // Arrange
      final resource = AlertPageResource.fromJson(
        alertPageJson(
          content: [
            alertJson(id: 'alert-1'),
            alertJson(id: 'alert-2'),
            alertJson(id: 'alert-3'),
          ],
        ),
      );

      // Act
      final page = alertPageResourceToDomain(resource);

      // Assert
      expect(
        page.content.map((alert) => alert.id.value),
        ['alert-1', 'alert-2', 'alert-3'],
      );
    });

    test('should apply the unknown enum fallbacks to each item of the page',
        () {
      // Arrange
      final resource = AlertPageResource.fromJson(
        alertPageJson(
          content: [
            alertJson(metric: 'UNKNOWN', status: 'UNKNOWN', severity: 'UNKNOWN'),
          ],
        ),
      );

      // Act
      final page = alertPageResourceToDomain(resource);

      // Assert
      expect(page.content.single.metric, MetricType.pm25);
      expect(page.content.single.status, AlertStatus.active);
      expect(page.content.single.severity, AlertSeverity.low);
    });
  });

  group('dailyAlertSummaryResourceToDomain', () {
    test('should map the date and the count of a day bucket', () {
      // Arrange
      final resource = DailyAlertSummaryResource.fromJson(
        const <String, dynamic>{'date': '2024-05-01', 'count': 7},
      );

      // Act
      final summary = dailyAlertSummaryResourceToDomain(resource);

      // Assert
      expect(summary.date, '2024-05-01');
      expect(summary.count, 7);
    });

    test('should truncate a double count to an integer', () {
      // Arrange
      final resource = DailyAlertSummaryResource.fromJson(
        const <String, dynamic>{'date': '2024-05-01', 'count': 7.9},
      );

      // Act
      final summary = dailyAlertSummaryResourceToDomain(resource);

      // Assert
      expect(summary.count, 7);
      expect(summary.count, isA<int>());
    });

    test('should map a bucket with a zero count', () {
      // Arrange
      final resource = DailyAlertSummaryResource.fromJson(
        const <String, dynamic>{'date': '2024-05-02', 'count': 0},
      );

      // Act
      final summary = dailyAlertSummaryResourceToDomain(resource);

      // Assert
      expect(summary, isA<DailyAlertCount>());
      expect(summary.count, 0);
    });

    test('should aggregate the total of several mapped buckets when the caller '
        'sums them', () {
      // Arrange
      final resources = [
        buildDailySummaryResource(date: '2024-05-01', count: 2),
        buildDailySummaryResource(date: '2024-05-02', count: 3.9),
      ];

      // Act
      final summaries =
          resources.map(dailyAlertSummaryResourceToDomain).toList();

      // Assert
      expect(summaries, hasLength(2));
      expect(
        summaries.fold<int>(0, (sum, day) => sum + day.count),
        5,
        reason: '3.9 is truncated to 3 before aggregation',
      );
    });
  });
}