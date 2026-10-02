import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';

void main() {
  group('MetricType ValueObject', () {
    test(
      'should provide correct label and unit for all MetricType enum values',
      () {
        // Arrange & Act & Assert
        expect(MetricType.pm25.label, equals('PM2.5'));
        expect(MetricType.pm25.unit, equals('µg/m³'));

        expect(MetricType.co2.label, equals('CO2'));
        expect(MetricType.co2.unit, equals('ppm'));

        expect(MetricType.temperature.label, equals('Temperature'));
        expect(MetricType.temperature.unit, equals('°C'));

        expect(MetricType.humidity.label, equals('Humidity'));
        expect(MetricType.humidity.unit, equals('%'));
      },
    );

    test(
      'should return correct uppercase apiName and apiValue for each MetricType',
      () {
        // Arrange & Act & Assert
        expect(MetricType.pm25.apiName, equals('PM25'));
        expect(MetricType.pm25.apiValue, equals('PM25'));

        expect(MetricType.co2.apiName, equals('CO2'));
        expect(MetricType.co2.apiValue, equals('CO2'));

        expect(MetricType.temperature.apiName, equals('TEMPERATURE'));
        expect(MetricType.temperature.apiValue, equals('TEMPERATURE'));

        expect(MetricType.humidity.apiName, equals('HUMIDITY'));
        expect(MetricType.humidity.apiValue, equals('HUMIDITY'));
      },
    );

    test('should parse MetricType by apiName case-insensitively', () {
      // Arrange & Act & Assert
      expect(MetricType.fromString('PM25'), equals(MetricType.pm25));
      expect(MetricType.fromString('pm25'), equals(MetricType.pm25));
      expect(MetricType.fromString('co2'), equals(MetricType.co2));
      expect(MetricType.fromString('CO2'), equals(MetricType.co2));
      expect(
        MetricType.fromString('temperature'),
        equals(MetricType.temperature),
      );
      expect(
        MetricType.fromString('TEMPERATURE'),
        equals(MetricType.temperature),
      );
      expect(MetricType.fromString('humidity'), equals(MetricType.humidity));
      expect(MetricType.fromString('HUMIDITY'), equals(MetricType.humidity));
    });

    test('should parse MetricType by label', () {
      // Arrange & Act & Assert
      expect(MetricType.fromString('PM2.5'), equals(MetricType.pm25));
      expect(MetricType.fromString('CO2'), equals(MetricType.co2));
      expect(
        MetricType.fromString('Temperature'),
        equals(MetricType.temperature),
      );
      expect(MetricType.fromString('Humidity'), equals(MetricType.humidity));
    });

    test('should return null when string does not match any metric', () {
      // Arrange & Act & Assert
      expect(MetricType.fromString(''), isNull);
      expect(MetricType.fromString('NOISE'), isNull);
      expect(MetricType.fromString('pressure'), isNull);
      expect(MetricType.fromString('unknown_metric'), isNull);
    });
  });
}
