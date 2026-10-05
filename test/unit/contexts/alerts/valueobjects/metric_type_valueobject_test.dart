import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';

void main() {
  group('MetricType', () {
    group('label and unit', () {
      test('should expose the PM2.5 label and microgram unit for pm25', () {
        // Arrange / Act / Assert
        expect(MetricType.pm25.label, 'PM2.5');
        expect(MetricType.pm25.unit, 'µg/m³');
      });

      test('should expose the CO2 label and ppm unit for co2', () {
        // Arrange / Act / Assert
        expect(MetricType.co2.label, 'CO2');
        expect(MetricType.co2.unit, 'ppm');
      });

      test('should expose the Temperature label and celsius unit for '
          'temperature', () {
        // Arrange / Act / Assert
        expect(MetricType.temperature.label, 'Temperature');
        expect(MetricType.temperature.unit, '°C');
      });

      test('should expose the Humidity label and percent unit for humidity', () {
        // Arrange / Act / Assert
        expect(MetricType.humidity.label, 'Humidity');
        expect(MetricType.humidity.unit, '%');
      });
    });

    group('apiName', () {
      test('should expose PM25 as the wire name for pm25', () {
        // Arrange / Act / Assert
        expect(MetricType.pm25.apiName, 'PM25');
      });

      test('should expose CO2 as the wire name for co2', () {
        // Arrange / Act / Assert
        expect(MetricType.co2.apiName, 'CO2');
      });

      test('should expose TEMPERATURE as the wire name for temperature', () {
        // Arrange / Act / Assert
        expect(MetricType.temperature.apiName, 'TEMPERATURE');
      });

      test('should expose HUMIDITY as the wire name for humidity', () {
        // Arrange / Act / Assert
        expect(MetricType.humidity.apiName, 'HUMIDITY');
      });
    });

    group('fromString', () {
      test('should parse the upper case PM25 wire name', () {
        // Arrange
        const wire = 'PM25';

        // Act
        final metric = MetricType.fromString(wire);

        // Assert
        expect(metric, MetricType.pm25);
      });

      test('should parse the upper case CO2 wire name', () {
        // Arrange
        const wire = 'CO2';

        // Act
        final metric = MetricType.fromString(wire);

        // Assert
        expect(metric, MetricType.co2);
      });

      test('should parse the upper case TEMPERATURE wire name', () {
        // Arrange
        const wire = 'TEMPERATURE';

        // Act
        final metric = MetricType.fromString(wire);

        // Assert
        expect(metric, MetricType.temperature);
      });

      test('should parse the upper case HUMIDITY wire name', () {
        // Arrange
        const wire = 'HUMIDITY';

        // Act
        final metric = MetricType.fromString(wire);

        // Assert
        expect(metric, MetricType.humidity);
      });

      test('should parse a lower case wire name because the lookup upper cases '
          'the input', () {
        // Arrange
        const wire = 'humidity';

        // Act
        final metric = MetricType.fromString(wire);

        // Assert
        expect(metric, MetricType.humidity);
      });

      test('should parse the exact PM2.5 label even though it is not a wire '
          'name', () {
        // Arrange
        const label = 'PM2.5';

        // Act
        final metric = MetricType.fromString(label);

        // Assert
        expect(metric, MetricType.pm25);
      });

      test('should parse the exact Temperature label', () {
        // Arrange
        const label = 'Temperature';

        // Act
        final metric = MetricType.fromString(label);

        // Assert
        expect(metric, MetricType.temperature);
      });

      test('should return null for a lower case label because only the wire '
          'name comparison is case insensitive', () {
        // Arrange
        const label = 'pm2.5';

        // Act
        final metric = MetricType.fromString(label);

        // Assert
        expect(
          metric,
          isNull,
          reason: 'The label comparison is case sensitive and PM2.5 is not PM25',
        );
      });

      test('should return null when the wire name is unknown', () {
        // Arrange
        const wire = 'NOISE';

        // Act
        final metric = MetricType.fromString(wire);

        // Assert
        expect(metric, isNull);
      });

      test('should return null when the wire name is empty', () {
        // Arrange
        const wire = '';

        // Act
        final metric = MetricType.fromString(wire);

        // Assert
        expect(metric, isNull);
      });

      test('should return null when the wire name is padded with whitespace',
          () {
        // Arrange
        const wire = ' CO2 ';

        // Act
        final metric = MetricType.fromString(wire);

        // Assert
        expect(metric, isNull);
      });
    });

    group('round trip', () {
      test('should map every declared metric back from its own wire name', () {
        // Arrange
        final metrics = MetricType.values;

        // Act
        final parsed = metrics
            .map((metric) => MetricType.fromString(metric.apiName))
            .toList();

        // Assert
        expect(parsed, metrics);
      });
    });
  });
}