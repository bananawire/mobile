import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/interfaces/rest/resources/dashboard_metrics.resource.dart';
import 'package:mobile/analytics/interfaces/rest/resources/trends.resource.dart';

void main() {
  group('DashboardMetricsResource', () {
    test('should deserialize from complete json and serialize to json correctly', () {
      // Arrange
      final json = {
        'aqiValue': 42.0,
        'aqiCategory': 'Good',
        'averageCo2': 550.5,
        'averagePm2_5': 12.3,
        'averageTemperature': 23.4,
        'averageHumidity': 48.6,
        'co2DeltaPercentage': 5.2,
        'pm2_5DeltaPercentage': -1.4,
        'temperatureDeltaPercentage': 0.8,
        'humidityDeltaPercentage': -2.1,
        'calculatedAt': '2026-10-02T12:00:00Z',
      };

      // Act
      final resource = DashboardMetricsResource.fromJson(json);
      final serialized = resource.toJson();

      // Assert
      expect(resource.aqiValue, equals(42.0));
      expect(resource.aqiCategory, equals('Good'));
      expect(resource.averageCo2, equals(550.5));
      expect(resource.averagePm2_5, equals(12.3));
      expect(resource.averageTemperature, equals(23.4));
      expect(resource.averageHumidity, equals(48.6));
      expect(resource.co2DeltaPercentage, equals(5.2));
      expect(resource.pm2_5DeltaPercentage, equals(-1.4));
      expect(resource.temperatureDeltaPercentage, equals(0.8));
      expect(resource.humidityDeltaPercentage, equals(-2.1));
      expect(resource.calculatedAt, equals('2026-10-02T12:00:00Z'));
      expect(serialized, equals(json));
    });

    test('should fallback aqiCategory to "No measurements" when missing in json', () {
      // Arrange
      final json = <String, dynamic>{
        'aqiValue': 0.0,
      };

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.aqiCategory, equals('No measurements'));
      expect(resource.calculatedAt, equals(''));
    });

    test('should parse string numbers and handle null delta percentages gracefully', () {
      // Arrange
      final json = <String, dynamic>{
        'aqiValue': '68.5',
        'aqiCategory': 'Moderate',
        'averageCo2': '720',
        'averagePm2_5': '22.4',
        'averageTemperature': '25.0',
        'averageHumidity': '60.0',
        'co2DeltaPercentage': null,
        'pm2_5DeltaPercentage': '3.5',
        'temperatureDeltaPercentage': null,
        'humidityDeltaPercentage': null,
        'calculatedAt': '2026-10-02T12:00:00Z',
      };

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.aqiValue, equals(68.5));
      expect(resource.averageCo2, equals(720.0));
      expect(resource.averagePm2_5, equals(22.4));
      expect(resource.averageTemperature, equals(25.0));
      expect(resource.averageHumidity, equals(60.0));
      expect(resource.co2DeltaPercentage, isNull);
      expect(resource.pm2_5DeltaPercentage, equals(3.5));
      expect(resource.temperatureDeltaPercentage, isNull);
      expect(resource.humidityDeltaPercentage, isNull);
    });
  });

  group('TrendDataPointResource', () {
    test('should deserialize from json and serialize to json correctly', () {
      // Arrange
      final json = {
        'timestamp': '2026-10-02T11:00:00Z',
        'aqiValue': 55.0,
        'co2': 580.0,
        'pm2_5': 14.0,
        'temperature': 21.5,
        'humidity': 46.0,
      };

      // Act
      final resource = TrendDataPointResource.fromJson(json);
      final serialized = resource.toJson();

      // Assert
      expect(resource.timestamp, equals('2026-10-02T11:00:00Z'));
      expect(resource.aqiValue, equals(55.0));
      expect(resource.co2, equals(580.0));
      expect(resource.pm2_5, equals(14.0));
      expect(resource.temperature, equals(21.5));
      expect(resource.humidity, equals(46.0));
      expect(serialized, equals(json));
    });

    test('should fallback timestamp to empty string when missing in json', () {
      // Arrange
      final json = <String, dynamic>{
        'aqiValue': 30,
        'co2': 400,
        'pm2_5': 8,
        'temperature': 20,
        'humidity': 40,
      };

      // Act
      final resource = TrendDataPointResource.fromJson(json);

      // Assert
      expect(resource.timestamp, equals(''));
      expect(resource.aqiValue, equals(30.0));
    });
  });

  group('TrendsResource', () {
    test('should deserialize from json containing dataPoints list and serialize correctly', () {
      // Arrange
      final json = {
        'dataPoints': [
          {
            'timestamp': '2026-10-02T10:00:00Z',
            'aqiValue': 45.0,
            'co2': 500.0,
            'pm2_5': 10.0,
            'temperature': 22.0,
            'humidity': 50.0,
          },
          {
            'timestamp': '2026-10-02T11:00:00Z',
            'aqiValue': 50.0,
            'co2': 520.0,
            'pm2_5': 12.0,
            'temperature': 22.5,
            'humidity': 49.0,
          },
        ],
      };

      // Act
      final resource = TrendsResource.fromJson(json);
      final serialized = resource.toJson();

      // Assert
      expect(resource.dataPoints.length, equals(2));
      expect(resource.dataPoints.first.timestamp, equals('2026-10-02T10:00:00Z'));
      expect(resource.dataPoints.last.aqiValue, equals(50.0));
      expect(serialized, equals(json));
    });

    test('should handle empty or missing dataPoints array in json', () {
      // Arrange & Act
      final fromEmpty = TrendsResource.fromJson({'dataPoints': []});
      final fromMissing = TrendsResource.fromJson({});
      final fromInvalid = TrendsResource.fromJson({'dataPoints': 'not-a-list'});

      // Assert
      expect(fromEmpty.dataPoints, isEmpty);
      expect(fromMissing.dataPoints, isEmpty);
      expect(fromInvalid.dataPoints, isEmpty);
    });
  });
}
