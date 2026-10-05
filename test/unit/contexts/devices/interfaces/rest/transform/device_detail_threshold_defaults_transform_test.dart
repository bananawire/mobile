import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';
import 'package:mobile/devices/interfaces/rest/transform/device_detail_threshold_defaults_transform.dart';

void main() {
  group('buildDefaultDeviceDetailThresholdResources', () {
    test('should return one default entry per supported metric', () {
      // Arrange / Act
      final defaults = buildDefaultDeviceDetailThresholdResources();

      // Assert
      expect(defaults, hasLength(4));
      expect(
        defaults.map((d) => d.metric),
        [
          MetricThreshold.pm25,
          MetricThreshold.co2,
          MetricThreshold.temperature,
          MetricThreshold.humidity,
        ],
      );
    });

    test('should return the documented default value and unit for each metric', () {
      // Arrange / Act
      final defaults = buildDefaultDeviceDetailThresholdResources();

      // Assert
      expect(
        defaults.map((d) => d.value),
        [60.0, 1000.0, 28.7, 80.0],
      );
      expect(
        defaults.map((d) => d.unit),
        ['µg/m³', 'ppm', '°C', '%'],
      );
    });

    test('should return short upper case display labels for the detail screen', () {
      // Arrange / Act
      final defaults = buildDefaultDeviceDetailThresholdResources();

      // Assert
      expect(defaults.map((d) => d.label), ['PM2.5', 'CO₂', 'TEMP', 'HUMIDITY']);
    });

    test('should enable every default threshold', () {
      // Arrange / Act
      final defaults = buildDefaultDeviceDetailThresholdResources();

      // Assert
      expect(defaults.every((d) => d.enabled), isTrue);
    });

    test('should return an unmodifiable list on every call so callers cannot corrupt the defaults', () {
      // Arrange
      final defaults = buildDefaultDeviceDetailThresholdResources();

      // Act / Assert
      expect(() => defaults.removeAt(0), throwsUnsupportedError);
      expect(buildDefaultDeviceDetailThresholdResources(), hasLength(4));
    });
  });
}