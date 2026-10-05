import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/interfaces/rest/resources/dashboard_metrics.resource.dart';

import '../../../analytics_fixtures.dart';

void main() {
  group('DashboardMetricsResource.fromJson', () {
    test('should map every field of a well-formed payload', () {
      // Arrange
      final json = dashboardMetricsJson(
        aqiValue: 128.5,
        aqiCategory: 'Unhealthy for Sensitive',
        averageCo2: 812.25,
        averagePm2_5: 47.9,
        averageTemperature: 24.75,
        averageHumidity: 63,
        co2DeltaPercentage: 4.25,
        pm2_5DeltaPercentage: -18.5,
        temperatureDeltaPercentage: 1.5,
        humidityDeltaPercentage: -0.75,
        calculatedAt: '2024-05-01T10:15:30Z',
      );

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.aqiValue, 128.5);
      expect(resource.aqiCategory, 'Unhealthy for Sensitive');
      expect(resource.averageCo2, 812.25);
      expect(resource.averagePm2_5, 47.9);
      expect(resource.averageTemperature, 24.75);
      expect(resource.averageHumidity, 63.0);
      expect(resource.co2DeltaPercentage, 4.25);
      expect(resource.pm2_5DeltaPercentage, -18.5);
      expect(resource.temperatureDeltaPercentage, 1.5);
      expect(resource.humidityDeltaPercentage, -0.75);
      expect(resource.calculatedAt, '2024-05-01T10:15:30Z');
    });

    test('should convert integer JSON numbers to doubles', () {
      // Arrange
      final json = dashboardMetricsJson(
        aqiValue: 42,
        averageCo2: 612,
        averagePm2_5: 8,
        averageTemperature: 21,
        averageHumidity: 48,
        co2DeltaPercentage: 3,
      );

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.aqiValue, 42.0);
      expect(resource.averageCo2, 612.0);
      expect(resource.averagePm2_5, 8.0);
      expect(resource.averageTemperature, 21.0);
      expect(resource.averageHumidity, 48.0);
      expect(resource.co2DeltaPercentage, 3.0);
    });

    test('should parse numeric strings sent by the backend', () {
      // Arrange
      final json = dashboardMetricsJson(
        aqiValue: '42.5',
        averageCo2: '812',
        averagePm2_5: '8.4',
        calculatedAt: 12345,
      );

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.aqiValue, 42.5);
      expect(resource.averageCo2, 812.0);
      expect(resource.averagePm2_5, 8.4);
      expect(resource.calculatedAt, '12345');
    });

    test('should fall back to zero when a reading is not parsable', () {
      // Arrange
      final json = dashboardMetricsJson(
        aqiValue: 'not-a-number',
        averageCo2: null,
        averageHumidity: <String>[],
      );

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.aqiValue, 0);
      expect(resource.averageCo2, 0);
      expect(resource.averageHumidity, 0);
    });

    test('should default the category to the no-measurements label when the '
        'payload omits it', () {
      // Arrange
      final json = dashboardMetricsJson(aqiCategory: null);

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.aqiCategory, kFallbackAqiCategory);
    });

    test('should stringify a non-string category', () {
      // Arrange
      final json = dashboardMetricsJson(aqiCategory: 7);

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.aqiCategory, '7');
    });

    test('should default the calculation timestamp to an empty string', () {
      // Arrange
      final json = dashboardMetricsJson(calculatedAt: null);

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.calculatedAt, '');
    });

    test('should keep every delta null when the payload omits them', () {
      // Arrange
      final json = dashboardMetricsJson();

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.co2DeltaPercentage, isNull);
      expect(resource.pm2_5DeltaPercentage, isNull);
      expect(resource.temperatureDeltaPercentage, isNull);
      expect(resource.humidityDeltaPercentage, isNull);
    });

    test('should keep an explicit null delta null instead of coercing it to '
        'zero', () {
      // Arrange
      final json = dashboardMetricsJson(
        co2DeltaPercentage: null,
        pm2_5DeltaPercentage: 'n/a',
      );

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.co2DeltaPercentage, isNull);
      expect(resource.pm2_5DeltaPercentage, isNull);
    });

    test('should zero out an empty payload instead of failing', () {
      // Arrange
      const json = emptyDashboardMetricsJson;

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.aqiValue, 0);
      expect(resource.aqiCategory, kFallbackAqiCategory);
      expect(resource.averageCo2, 0);
      expect(resource.averagePm2_5, 0);
      expect(resource.averageTemperature, 0);
      expect(resource.averageHumidity, 0);
      expect(resource.calculatedAt, '');
    });

    test('should ignore unknown fields so a newer backend payload still '
        'parses', () {
      // Arrange
      final json = dashboardMetricsJson()..['brandNewField'] = 'ignored';

      // Act
      final resource = DashboardMetricsResource.fromJson(json);

      // Assert
      expect(resource.aqiValue, 42.0);
    });
  });
}