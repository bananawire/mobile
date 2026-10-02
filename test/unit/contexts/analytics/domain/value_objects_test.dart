import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/domain/model/valueobjects/aqi.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/dashboard_metrics.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/live_telemetry.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/metric_delta.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';

void main() {
  group('Aqi ValueObject', () {
    test('should create instance when value is non-negative and category is non-empty', () {
      // Arrange
      const value = 42.0;
      const category = 'Good';

      // Act
      final aqi = Aqi(value, category);

      // Assert
      expect(aqi.value, equals(42.0));
      expect(aqi.category, equals('Good'));
    });

    test('should trim category whitespace when category has surrounding spaces', () {
      // Arrange
      const category = '  Moderate  ';

      // Act
      final aqi = Aqi(65.0, category);

      // Assert
      expect(aqi.category, equals('Moderate'));
    });

    test('should allow zero value when creating instance', () {
      // Arrange & Act
      final aqi = Aqi(0.0, 'Good');

      // Assert
      expect(aqi.value, equals(0.0));
    });

    test('should throw ArgumentError when value is negative', () {
      // Arrange, Act & Assert
      expect(
        () => Aqi(-1.0, 'Good'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('AQI value must be a non-negative finite number'),
        )),
      );
    });

    test('should throw ArgumentError when value is infinite', () {
      // Arrange, Act & Assert
      expect(
        () => Aqi(double.infinity, 'Good'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('AQI value must be a non-negative finite number'),
        )),
      );
    });

    test('should throw ArgumentError when value is NaN', () {
      // Arrange, Act & Assert
      expect(
        () => Aqi(double.nan, 'Good'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('AQI value must be a non-negative finite number'),
        )),
      );
    });

    test('should throw ArgumentError when category is empty', () {
      // Arrange, Act & Assert
      expect(
        () => Aqi(42.0, ''),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('AQI category cannot be empty'),
        )),
      );
    });

    test('should throw ArgumentError when category is whitespace only', () {
      // Arrange, Act & Assert
      expect(
        () => Aqi(42.0, '   '),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('AQI category cannot be empty'),
        )),
      );
    });
  });

  group('MetricDelta ValueObject', () {
    test('should create instance when value and deltaPercentage are valid finite numbers', () {
      // Arrange
      const value = 24.5;
      const delta = 3.2;

      // Act
      final metricDelta = MetricDelta(value, delta);

      // Assert
      expect(metricDelta.value, equals(24.5));
      expect(metricDelta.deltaPercentage, equals(3.2));
    });

    test('should allow null deltaPercentage when creating instance', () {
      // Arrange & Act
      final metricDelta = MetricDelta(550.0, null);

      // Assert
      expect(metricDelta.value, equals(550.0));
      expect(metricDelta.deltaPercentage, isNull);
    });

    test('should allow negative deltaPercentage when creating instance', () {
      // Arrange & Act
      final metricDelta = MetricDelta(550.0, -12.4);

      // Assert
      expect(metricDelta.deltaPercentage, equals(-12.4));
    });

    test('should throw ArgumentError when value is infinite', () {
      // Arrange, Act & Assert
      expect(
        () => MetricDelta(double.infinity, 1.0),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Metric value must be a finite number'),
        )),
      );
    });

    test('should throw ArgumentError when value is NaN', () {
      // Arrange, Act & Assert
      expect(
        () => MetricDelta(double.nan, 1.0),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Metric value must be a finite number'),
        )),
      );
    });

    test('should throw ArgumentError when deltaPercentage is infinite', () {
      // Arrange, Act & Assert
      expect(
        () => MetricDelta(10.0, double.infinity),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Delta percentage must be null or a finite number'),
        )),
      );
    });

    test('should throw ArgumentError when deltaPercentage is NaN', () {
      // Arrange, Act & Assert
      expect(
        () => MetricDelta(10.0, double.nan),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Delta percentage must be null or a finite number'),
        )),
      );
    });
  });

  group('TrendPoint ValueObject', () {
    test('should create instance when all properties are valid', () {
      // Arrange & Act
      final point = TrendPoint(
        timestamp: '2026-10-02T12:00:00Z',
        aqiValue: 55.0,
        co2: 600.0,
        pm2_5: 14.5,
        temperature: 22.0,
        humidity: 45.0,
      );

      // Assert
      expect(point.timestamp, equals('2026-10-02T12:00:00Z'));
      expect(point.aqiValue, equals(55.0));
      expect(point.co2, equals(600.0));
      expect(point.pm2_5, equals(14.5));
      expect(point.temperature, equals(22.0));
      expect(point.humidity, equals(45.0));
    });

    test('should trim timestamp whitespace when creating instance', () {
      // Arrange & Act
      final point = TrendPoint(
        timestamp: '   2026-10-02T12:00:00Z   ',
        aqiValue: 55.0,
        co2: 600.0,
        pm2_5: 14.5,
        temperature: 22.0,
        humidity: 45.0,
      );

      // Assert
      expect(point.timestamp, equals('2026-10-02T12:00:00Z'));
    });

    test('should throw ArgumentError when timestamp is empty', () {
      // Arrange, Act & Assert
      expect(
        () => TrendPoint(
          timestamp: '',
          aqiValue: 55.0,
          co2: 600.0,
          pm2_5: 14.5,
          temperature: 22.0,
          humidity: 45.0,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Timestamp cannot be empty'),
        )),
      );
    });

    test('should throw ArgumentError when timestamp is whitespace only', () {
      // Arrange, Act & Assert
      expect(
        () => TrendPoint(
          timestamp: '   ',
          aqiValue: 55.0,
          co2: 600.0,
          pm2_5: 14.5,
          temperature: 22.0,
          humidity: 45.0,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Timestamp cannot be empty'),
        )),
      );
    });

    test('should throw ArgumentError when aqiValue is infinite or NaN', () {
      expect(
        () => TrendPoint(
          timestamp: '2026-10-02T12:00:00Z',
          aqiValue: double.infinity,
          co2: 600.0,
          pm2_5: 14.5,
          temperature: 22.0,
          humidity: 45.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => TrendPoint(
          timestamp: '2026-10-02T12:00:00Z',
          aqiValue: double.nan,
          co2: 600.0,
          pm2_5: 14.5,
          temperature: 22.0,
          humidity: 45.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError when co2 is non-finite', () {
      expect(
        () => TrendPoint(
          timestamp: '2026-10-02T12:00:00Z',
          aqiValue: 50.0,
          co2: double.infinity,
          pm2_5: 14.5,
          temperature: 22.0,
          humidity: 45.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError when pm2_5 is non-finite', () {
      expect(
        () => TrendPoint(
          timestamp: '2026-10-02T12:00:00Z',
          aqiValue: 50.0,
          co2: 500.0,
          pm2_5: double.nan,
          temperature: 22.0,
          humidity: 45.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError when temperature is non-finite', () {
      expect(
        () => TrendPoint(
          timestamp: '2026-10-02T12:00:00Z',
          aqiValue: 50.0,
          co2: 500.0,
          pm2_5: 10.0,
          temperature: double.infinity,
          humidity: 45.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError when humidity is non-finite', () {
      expect(
        () => TrendPoint(
          timestamp: '2026-10-02T12:00:00Z',
          aqiValue: 50.0,
          co2: 500.0,
          pm2_5: 10.0,
          temperature: 20.0,
          humidity: double.nan,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('LiveTelemetry ValueObject', () {
    test('should create instance via constructor with valid properties', () {
      // Arrange & Act
      const telemetry = LiveTelemetry(
        deviceId: 'device-123',
        co2: 580.0,
        pm2_5: 12.0,
        temperature: 23.5,
        humidity: 50.2,
        timestamp: '2026-10-02T12:00:00Z',
      );

      // Assert
      expect(telemetry.deviceId, equals('device-123'));
      expect(telemetry.co2, equals(580.0));
      expect(telemetry.pm2_5, equals(12.0));
      expect(telemetry.temperature, equals(23.5));
      expect(telemetry.humidity, equals(50.2));
      expect(telemetry.timestamp, equals('2026-10-02T12:00:00Z'));
    });

    test('should deserialize from json with complete data', () {
      // Arrange
      final json = {
        'deviceId': 'device-456',
        'co2': 650,
        'pm2_5': 18.2,
        'temperature': '24.1',
        'humidity': 55,
        'timestamp': '2026-10-02T12:30:00Z',
      };

      // Act
      final telemetry = LiveTelemetry.fromJson(json, 'fallback-id');

      // Assert
      expect(telemetry.deviceId, equals('device-456'));
      expect(telemetry.co2, equals(650.0));
      expect(telemetry.pm2_5, equals(18.2));
      expect(telemetry.temperature, equals(24.1));
      expect(telemetry.humidity, equals(55.0));
      expect(telemetry.timestamp, equals('2026-10-02T12:30:00Z'));
    });

    test('should fallback to fallbackDeviceId when deviceId is missing in json', () {
      // Arrange
      final json = {
        'co2': 400.0,
        'pm2_5': 5.0,
        'temperature': 20.0,
        'humidity': 40.0,
      };

      // Act
      final telemetry = LiveTelemetry.fromJson(json, 'fallback-id');

      // Assert
      expect(telemetry.deviceId, equals('fallback-id'));
      expect(telemetry.timestamp, isNotEmpty);
    });

    test('should default invalid numeric values to zero', () {
      // Arrange
      final json = {
        'deviceId': 'device-789',
        'co2': 'invalid',
        'pm2_5': null,
        'temperature': null,
        'humidity': 'bad_number',
      };

      // Act
      final telemetry = LiveTelemetry.fromJson(json, 'fallback-id');

      // Assert
      expect(telemetry.co2, equals(0.0));
      expect(telemetry.pm2_5, equals(0.0));
      expect(telemetry.temperature, equals(0.0));
      expect(telemetry.humidity, equals(0.0));
    });
  });

  group('DashboardMetrics ValueObject', () {
    test('should create instance with all required value objects', () {
      // Arrange
      final aqi = Aqi(45.0, 'Good');
      final co2 = MetricDelta(480.0, -2.5);
      final pm2_5 = MetricDelta(11.0, 1.8);
      final temp = MetricDelta(22.5, null);
      final humidity = MetricDelta(48.0, 0.0);
      const calculatedAt = '2026-10-02T12:00:00Z';

      // Act
      final metrics = DashboardMetrics(
        aqi: aqi,
        co2: co2,
        pm2_5: pm2_5,
        temperature: temp,
        humidity: humidity,
        calculatedAt: calculatedAt,
      );

      // Assert
      expect(metrics.aqi, equals(aqi));
      expect(metrics.co2, equals(co2));
      expect(metrics.pm2_5, equals(pm2_5));
      expect(metrics.temperature, equals(temp));
      expect(metrics.humidity, equals(humidity));
      expect(metrics.calculatedAt, equals(calculatedAt));
    });
  });
}
