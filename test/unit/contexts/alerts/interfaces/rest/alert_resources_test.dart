import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_page.resource.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_response.resource.dart';
import 'package:mobile/alerts/interfaces/rest/resources/daily_alert_summary.resource.dart';

void main() {
  group('AlertResponseResource', () {
    test('should deserialize from json when all fields are present', () {
      // Arrange
      final json = {
        'id': 'alert-001',
        'deviceId': 'device-001',
        'spaceId': 'space-001',
        'spaceName': 'Office',
        'deviceName': 'Monitor 1',
        'metric': 'PM25',
        'metricLabel': 'PM2.5',
        'metricUnit': 'µg/m³',
        'thresholdValue': 25.5,
        'actualValue': 38.2,
        'message': 'PM2.5 alert triggered',
        'status': 'ACTIVE',
        'severity': 'CRITICAL',
        'occurredAt': '2026-10-02T10:00:00Z',
        'resolvedAt': '2026-10-02T10:30:00Z',
        'createdAt': '2026-10-02T10:01:00Z',
      };

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.id, equals('alert-001'));
      expect(resource.deviceId, equals('device-001'));
      expect(resource.spaceId, equals('space-001'));
      expect(resource.spaceName, equals('Office'));
      expect(resource.deviceName, equals('Monitor 1'));
      expect(resource.metric, equals('PM25'));
      expect(resource.metricLabel, equals('PM2.5'));
      expect(resource.metricUnit, equals('µg/m³'));
      expect(resource.thresholdValue, equals(25.5));
      expect(resource.actualValue, equals(38.2));
      expect(resource.message, equals('PM2.5 alert triggered'));
      expect(resource.status, equals('ACTIVE'));
      expect(resource.severity, equals('CRITICAL'));
      expect(resource.occurredAt, equals('2026-10-02T10:00:00Z'));
      expect(resource.resolvedAt, equals('2026-10-02T10:30:00Z'));
      expect(resource.createdAt, equals('2026-10-02T10:01:00Z'));
    });

    test(
      'should parse thresholdValue and actualValue when they are string numbers',
      () {
        // Arrange
        final json = {
          'id': 'alert-002',
          'deviceId': 'device-002',
          'metric': 'CO2',
          'metricLabel': 'CO2',
          'metricUnit': 'ppm',
          'thresholdValue': '1000.5',
          'actualValue': '1250',
          'message': 'CO2 high',
          'status': 'WARNING',
          'severity': 'WARNING',
          'occurredAt': '2026-10-02T11:00:00Z',
          'createdAt': '2026-10-02T11:00:00Z',
        };

        // Act
        final resource = AlertResponseResource.fromJson(json);

        // Assert
        expect(resource.thresholdValue, equals(1000.5));
        expect(resource.actualValue, equals(1250));
      },
    );

    test('should handle null optional fields in json', () {
      // Arrange
      final json = {
        'id': 'alert-003',
        'deviceId': 'device-003',
        'spaceId': null,
        'spaceName': null,
        'deviceName': null,
        'metric': 'TEMPERATURE',
        'metricLabel': 'Temperature',
        'metricUnit': '°C',
        'thresholdValue': 30,
        'actualValue': 35,
        'message': 'Temperature exceeded',
        'status': 'RESOLVED',
        'severity': 'LOW',
        'occurredAt': '2026-10-02T09:00:00Z',
        'resolvedAt': null,
        'createdAt': '2026-10-02T09:00:00Z',
      };

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.spaceId, isNull);
      expect(resource.spaceName, isNull);
      expect(resource.deviceName, isNull);
      expect(resource.resolvedAt, isNull);
    });

    test('should serialize to json correctly', () {
      // Arrange
      final resource = AlertResponseResource(
        id: 'alert-004',
        deviceId: 'device-004',
        spaceId: 'space-004',
        spaceName: 'Room A',
        deviceName: 'Device A',
        metric: 'HUMIDITY',
        metricLabel: 'Humidity',
        metricUnit: '%',
        thresholdValue: 70,
        actualValue: 85,
        message: 'High humidity',
        status: 'ACTIVE',
        severity: 'LOW',
        occurredAt: '2026-10-02T12:00:00Z',
        resolvedAt: '2026-10-02T12:30:00Z',
        createdAt: '2026-10-02T12:00:00Z',
      );

      // Act
      final json = resource.toJson();

      // Assert
      expect(json['id'], equals('alert-004'));
      expect(json['deviceId'], equals('device-004'));
      expect(json['spaceId'], equals('space-004'));
      expect(json['spaceName'], equals('Room A'));
      expect(json['deviceName'], equals('Device A'));
      expect(json['metric'], equals('HUMIDITY'));
      expect(json['metricLabel'], equals('Humidity'));
      expect(json['metricUnit'], equals('%'));
      expect(json['thresholdValue'], equals(70));
      expect(json['actualValue'], equals(85));
      expect(json['message'], equals('High humidity'));
      expect(json['status'], equals('ACTIVE'));
      expect(json['severity'], equals('LOW'));
      expect(json['occurredAt'], equals('2026-10-02T12:00:00Z'));
      expect(json['resolvedAt'], equals('2026-10-02T12:30:00Z'));
      expect(json['createdAt'], equals('2026-10-02T12:00:00Z'));
    });
  });

  group('DailyAlertSummaryResource', () {
    test('should deserialize from json when count is numeric', () {
      // Arrange
      final json = {'date': '2026-10-02', 'count': 12};

      // Act
      final resource = DailyAlertSummaryResource.fromJson(json);

      // Assert
      expect(resource.date, equals('2026-10-02'));
      expect(resource.count, equals(12));
    });

    test('should deserialize from json when count is string', () {
      // Arrange
      final json = {'date': '2026-10-01', 'count': '25'};

      // Act
      final resource = DailyAlertSummaryResource.fromJson(json);

      // Assert
      expect(resource.date, equals('2026-10-01'));
      expect(resource.count, equals(25));
    });

    test('should fallback to 0 count and empty date when json is empty', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final resource = DailyAlertSummaryResource.fromJson(json);

      // Assert
      expect(resource.date, equals(''));
      expect(resource.count, equals(0));
    });

    test('should serialize to json correctly', () {
      // Arrange
      const resource = DailyAlertSummaryResource(date: '2026-10-02', count: 7);

      // Act
      final json = resource.toJson();

      // Assert
      expect(json['date'], equals('2026-10-02'));
      expect(json['count'], equals(7));
    });
  });

  group('AlertPageResource', () {
    test(
      'should deserialize from json with content list and pagination fields',
      () {
        // Arrange
        final json = {
          'content': [
            {
              'id': 'alert-p1',
              'deviceId': 'device-p1',
              'metric': 'PM25',
              'metricLabel': 'PM2.5',
              'metricUnit': 'µg/m³',
              'thresholdValue': 25,
              'actualValue': 40,
              'message': 'Alert P1',
              'status': 'ACTIVE',
              'severity': 'CRITICAL',
              'occurredAt': '2026-10-02T01:00:00Z',
              'createdAt': '2026-10-02T01:00:00Z',
            },
          ],
          'totalElements': 45,
          'totalPages': 5,
          'size': 10,
          'number': 0,
        };

        // Act
        final resource = AlertPageResource.fromJson(json);

        // Assert
        expect(resource.content.length, equals(1));
        expect(resource.content.first.id, equals('alert-p1'));
        expect(resource.totalElements, equals(45));
        expect(resource.totalPages, equals(5));
        expect(resource.size, equals(10));
        expect(resource.number, equals(0));
      },
    );

    test('should handle missing or empty content array in json gracefully', () {
      // Arrange
      final json = {
        'totalElements': 0,
        'totalPages': 0,
        'size': 20,
        'number': 0,
      };

      // Act
      final resource = AlertPageResource.fromJson(json);

      // Assert
      expect(resource.content, isEmpty);
      expect(resource.totalElements, equals(0));
      expect(resource.totalPages, equals(0));
      expect(resource.size, equals(20));
      expect(resource.number, equals(0));
    });

    test('should serialize to json correctly', () {
      // Arrange
      final item = AlertResponseResource(
        id: 'alert-item',
        deviceId: 'device-item',
        metric: 'CO2',
        metricLabel: 'CO2',
        metricUnit: 'ppm',
        thresholdValue: 1000,
        actualValue: 1200,
        message: 'High CO2',
        status: 'ACTIVE',
        severity: 'WARNING',
        occurredAt: '2026-10-02T05:00:00Z',
        createdAt: '2026-10-02T05:00:00Z',
      );
      final resource = AlertPageResource(
        content: [item],
        totalElements: 1,
        totalPages: 1,
        size: 20,
        number: 0,
      );

      // Act
      final json = resource.toJson();

      // Assert
      expect(json['totalElements'], equals(1));
      expect(json['totalPages'], equals(1));
      expect(json['size'], equals(20));
      expect(json['number'], equals(0));
      expect((json['content'] as List).length, equals(1));
      expect((json['content'] as List).first['id'], equals('alert-item'));
    });
  });
}
