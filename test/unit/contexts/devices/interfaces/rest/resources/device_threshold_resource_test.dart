import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_threshold.resource.dart';

import '../../../helpers/device_fixtures.dart';

void main() {
  group('DeviceThresholdResource.fromJson', () {
    test('should parse a well formed payload with explicit label and unit', () {
      // Arrange
      final json = deviceThresholdJson(
        metric: 'PM25',
        value: 60.5,
        enabled: true,
        metricLabel: 'Particulate',
        metricUnit: 'ug/m3',
      );

      // Act
      final resource = DeviceThresholdResource.fromJson(json);

      // Assert
      expect(resource.deviceId, 'dev-1');
      expect(resource.metric, MetricThreshold.pm25);
      expect(resource.value, 60.5);
      expect(resource.enabled, isTrue);
      expect(resource.metricLabel, 'Particulate');
      expect(resource.metricUnit, 'ug/m3');
    });

    test('should fall back to the metric label and unit when they are absent', () {
      // Arrange
      final json = deviceThresholdJson(metric: 'CO2');

      // Act
      final resource = DeviceThresholdResource.fromJson(json);

      // Assert
      expect(resource.metricLabel, 'CO2');
      expect(resource.metricUnit, 'ppm');
    });

    test('should resolve a metric from its case insensitive api name', () {
      // Arrange
      final json = deviceThresholdJson(metric: 'humidity');

      // Act
      final resource = DeviceThresholdResource.fromJson(json);

      // Assert
      expect(resource.metric, MetricThreshold.humidity);
    });

    test('should throw when the metric is unknown', () {
      // Arrange
      final json = deviceThresholdJson(metric: 'RADIATION');

      // Act / Assert
      expect(
        () => DeviceThresholdResource.fromJson(json),
        throwsA(
          isA<Exception>().having((e) => e.toString(), 'message', 'Exception: Unknown metric: RADIATION'),
        ),
      );
    });

    test('should throw when the metric key is missing', () {
      // Arrange
      const json = <String, dynamic>{'deviceId': 'dev-1', 'value': 60};

      // Act / Assert
      expect(
        () => DeviceThresholdResource.fromJson(json),
        throwsA(isA<Exception>()),
      );
    });

    test('should parse an integer encoded value as a double', () {
      // Arrange
      final json = deviceThresholdJson(metric: 'PM25', value: 60);

      // Act
      final resource = DeviceThresholdResource.fromJson(json);

      // Assert
      expect(resource.value, 60.0);
    });

    test('should parse a string encoded value', () {
      // Arrange
      final json = deviceThresholdJson(metric: 'PM25', value: '45.25');

      // Act
      final resource = DeviceThresholdResource.fromJson(json);

      // Assert
      expect(resource.value, 45.25);
    });

    test('should throw when the value is not numeric', () {
      // Arrange
      final json = deviceThresholdJson(metric: 'PM25', value: 'high');

      // Act / Assert
      expect(
        () => DeviceThresholdResource.fromJson(json),
        throwsA(
          isA<Exception>().having((e) => e.toString(), 'message', 'Exception: Invalid threshold value'),
        ),
      );
    });

    test('should throw when the value is missing', () {
      // Arrange
      final json = deviceThresholdJson(metric: 'PM25', value: null);

      // Act / Assert
      expect(
        () => DeviceThresholdResource.fromJson(json),
        throwsA(isA<Exception>()),
      );
    });

    test('should treat a missing enabled flag as disabled', () {
      // Arrange
      final json = deviceThresholdJson(metric: 'PM25', enabled: null);

      // Act
      final resource = DeviceThresholdResource.fromJson(json);

      // Assert
      expect(resource.enabled, isFalse);
    });

    test('should parse a string encoded enabled flag', () {
      // Arrange
      final json = deviceThresholdJson(metric: 'PM25', enabled: 'TRUE');

      // Act
      final resource = DeviceThresholdResource.fromJson(json);

      // Assert
      expect(resource.enabled, isTrue);
    });

    test('should parse a string encoded disabled flag', () {
      // Arrange
      final json = deviceThresholdJson(metric: 'PM25', enabled: 'false');

      // Act
      final resource = DeviceThresholdResource.fromJson(json);

      // Assert
      expect(resource.enabled, isFalse);
    });

    test('should fall back to an empty device id when it is missing', () {
      // Arrange
      const json = <String, dynamic>{'metric': 'PM25', 'value': 60};

      // Act
      final resource = DeviceThresholdResource.fromJson(json);

      // Assert
      expect(resource.deviceId, '');
    });
  });
}