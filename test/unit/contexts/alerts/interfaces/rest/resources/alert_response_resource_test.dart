import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_response.resource.dart';

import '../../../alerts_fixtures.dart';

void main() {
  group('AlertResponseResource.fromJson', () {
    test('should map every field of a well formed payload', () {
      // Arrange
      final json = resolvedAlertJson();

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.id, 'alert-2');
      expect(resource.deviceId, 'device-2');
      expect(resource.spaceId, 'space-2');
      expect(resource.spaceName, 'Bedroom');
      expect(resource.deviceName, 'Sensor B');
      expect(resource.metric, 'TEMPERATURE');
      expect(resource.metricLabel, 'Temperature');
      expect(resource.metricUnit, '°C');
      expect(resource.thresholdValue, 30);
      expect(resource.actualValue, 33);
      expect(resource.message, 'Temperature above threshold');
      expect(resource.status, 'RESOLVED');
      expect(resource.severity, 'WARNING');
      expect(resource.occurredAt, '2024-05-02T08:00:00Z');
      expect(resource.resolvedAt, '2024-05-02T09:15:00Z');
      expect(resource.createdAt, '2024-05-02T08:01:00Z');
    });

    test('should keep integer numeric thresholds as numbers', () {
      // Arrange
      final json = alertJson(thresholdValue: 35, actualValue: 52);

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.thresholdValue, 35);
      expect(resource.actualValue, 52);
    });

    test('should parse double numeric thresholds without precision loss', () {
      // Arrange
      final json = alertJson(thresholdValue: 35.5, actualValue: 52.75);

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.thresholdValue, 35.5);
      expect(resource.actualValue, 52.75);
    });

    test('should parse numeric thresholds delivered as strings', () {
      // Arrange
      final json = alertJson(thresholdValue: '35.5', actualValue: '52');

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.thresholdValue, 35.5);
      expect(resource.actualValue, 52);
    });

    test('should fall back to zero when a threshold is not parseable', () {
      // Arrange
      final json = alertJson(thresholdValue: 'n/a', actualValue: null);

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.thresholdValue, 0);
      expect(resource.actualValue, 0);
    });

    test('should expose null for the optional space and device details when '
        'they are missing from the payload', () {
      // Arrange
      final json = alertJson(spaceId: null, spaceName: null, deviceName: null);

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.spaceId, isNull);
      expect(resource.spaceName, isNull);
      expect(resource.deviceName, isNull);
    });

    test('should expose null for the optional resolvedAt when the payload sends '
        'an explicit null', () {
      // Arrange
      final json = <String, dynamic>{
        ...alertJson(),
        'resolvedAt': null,
      };

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.resolvedAt, isNull);
    });

    test('should stringify optional numeric values instead of failing', () {
      // Arrange
      final json = alertJson(spaceId: 42, deviceName: 7);

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.spaceId, '42');
      expect(resource.deviceName, '7');
    });

    test('should fall back to empty strings for every missing required text '
        'field', () {
      // Arrange
      const json = <String, dynamic>{};

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.id, isEmpty);
      expect(resource.deviceId, isEmpty);
      expect(resource.metric, isEmpty);
      expect(resource.metricLabel, isEmpty);
      expect(resource.metricUnit, isEmpty);
      expect(resource.message, isEmpty);
      expect(resource.status, isEmpty);
      expect(resource.severity, isEmpty);
      expect(resource.occurredAt, isEmpty);
      expect(resource.createdAt, isEmpty);
      expect(resource.thresholdValue, 0);
      expect(resource.actualValue, 0);
    });

    test('should fall back to empty strings when required text fields are '
        'explicitly null', () {
      // Arrange
      final json = alertJson(
        id: null,
        deviceId: null,
        metric: null,
        message: null,
        status: null,
        severity: null,
        occurredAt: null,
        createdAt: null,
      );

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.id, isEmpty);
      expect(resource.deviceId, isEmpty);
      expect(resource.metric, isEmpty);
      expect(resource.status, isEmpty);
      expect(resource.severity, isEmpty);
    });

    test('should preserve the timestamp strings verbatim instead of parsing '
        'them', () {
      // Arrange
      final json = alertJson(occurredAt: '2024-05-01T10:30:00.123Z');

      // Act
      final resource = AlertResponseResource.fromJson(json);

      // Assert
      expect(resource.occurredAt, '2024-05-01T10:30:00.123Z');
      expect(DateTime.parse(resource.occurredAt).millisecond, 123);
    });
  });
}