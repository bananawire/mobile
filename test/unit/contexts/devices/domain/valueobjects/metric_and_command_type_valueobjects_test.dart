import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_command_type.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';

void main() {
  group('MetricThreshold', () {
    test('should expose exactly the four supported telemetry metrics', () {
      // Arrange / Act
      final metrics = MetricThreshold.values;

      // Assert
      expect(
        metrics,
        [
          MetricThreshold.pm25,
          MetricThreshold.co2,
          MetricThreshold.temperature,
          MetricThreshold.humidity,
        ],
      );
    });

    test('should expose the display label of every metric', () {
      // Arrange / Act / Assert
      expect(MetricThreshold.pm25.label, 'PM2.5');
      expect(MetricThreshold.co2.label, 'CO2');
      expect(MetricThreshold.temperature.label, 'Temperature');
      expect(MetricThreshold.humidity.label, 'Humidity');
    });

    test('should expose the measurement unit of every metric', () {
      // Arrange / Act / Assert
      expect(MetricThreshold.pm25.unit, 'µg/m³');
      expect(MetricThreshold.co2.unit, 'ppm');
      expect(MetricThreshold.temperature.unit, '°C');
      expect(MetricThreshold.humidity.unit, '%');
    });

    test('should derive the api name as the upper cased enum name', () {
      // Arrange / Act / Assert
      expect(MetricThreshold.pm25.apiName, 'PM25');
      expect(MetricThreshold.co2.apiName, 'CO2');
      expect(MetricThreshold.temperature.apiName, 'TEMPERATURE');
      expect(MetricThreshold.humidity.apiName, 'HUMIDITY');
    });

    test('should resolve a metric from a case insensitive api name', () {
      // Arrange
      const candidates = {
        'pm25': MetricThreshold.pm25,
        'PM25': MetricThreshold.pm25,
        'co2': MetricThreshold.co2,
        'Co2': MetricThreshold.co2,
        'temperature': MetricThreshold.temperature,
        'TEMPERATURE': MetricThreshold.temperature,
        'humidity': MetricThreshold.humidity,
        'Humidity': MetricThreshold.humidity,
      };

      // Act / Assert
      candidates.forEach((raw, expected) {
        expect(MetricThreshold.fromString(raw), expected, reason: 'input "$raw"');
      });
    });

    test('should resolve a metric from an exact label match', () {
      // Arrange
      const candidates = {
        'PM2.5': MetricThreshold.pm25,
        'CO2': MetricThreshold.co2,
        'Temperature': MetricThreshold.temperature,
        'Humidity': MetricThreshold.humidity,
      };

      // Act / Assert
      candidates.forEach((raw, expected) {
        expect(MetricThreshold.fromString(raw), expected, reason: 'input "$raw"');
      });
    });

    test('should return null when the label match is not exact in casing', () {
      // Arrange
      const raw = 'pm2.5';

      // Act
      final metric = MetricThreshold.fromString(raw);

      // Assert
      expect(metric, isNull);
    });

    test('should return null when the metric is unknown', () {
      // Arrange
      const raw = 'radiation';

      // Act
      final metric = MetricThreshold.fromString(raw);

      // Assert
      expect(metric, isNull);
    });

    test('should return null when the metric name is empty', () {
      // Arrange
      const raw = '';

      // Act
      final metric = MetricThreshold.fromString(raw);

      // Assert
      expect(metric, isNull);
    });
  });

  group('DeviceCommandType', () {
    test('should expose exactly the three supported device commands', () {
      // Arrange / Act
      final types = DeviceCommandType.values;

      // Assert
      expect(
        types,
        [DeviceCommandType.standby, DeviceCommandType.wake, DeviceCommandType.restart],
      );
    });

    test('should encode every command as its upper cased api value', () {
      // Arrange / Act / Assert
      expect(DeviceCommandType.standby.apiValue, 'STANDBY');
      expect(DeviceCommandType.wake.apiValue, 'WAKE');
      expect(DeviceCommandType.restart.apiValue, 'RESTART');
    });
  });
}