import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/interfaces/rest/resources/dashboard_metrics.resource.dart';
import 'package:mobile/analytics/interfaces/rest/resources/trends.resource.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_transform.dart';

import '../../../analytics_fixtures.dart';

void main() {
  group('dashboardMetricsResourceToDomain', () {
    test('should map each JSON field onto the matching domain value object '
        'field', () {
      // Arrange — an explicit backend payload, not a round trip.
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
      final resource = DashboardMetricsResource.fromJson(json);

      // Act
      final metrics = dashboardMetricsResourceToDomain(resource);

      // Assert
      expect(metrics.aqi.value, 128.5);
      expect(metrics.aqi.category, 'Unhealthy for Sensitive');
      expect(metrics.co2.value, 812.25);
      expect(metrics.co2.deltaPercentage, 4.25);
      expect(metrics.pm2_5.value, 47.9);
      expect(metrics.pm2_5.deltaPercentage, -18.5);
      expect(metrics.temperature.value, 24.75);
      expect(metrics.temperature.deltaPercentage, 1.5);
      expect(metrics.humidity.value, 63.0);
      expect(metrics.humidity.deltaPercentage, -0.75);
      expect(metrics.calculatedAt, '2024-05-01T10:15:30Z');
    });

    test('should keep a missing delta null on the domain value object', () {
      // Arrange
      final resource = DashboardMetricsResource.fromJson(dashboardMetricsJson());

      // Act
      final metrics = dashboardMetricsResourceToDomain(resource);

      // Assert
      expect(metrics.co2.deltaPercentage, isNull);
      expect(metrics.pm2_5.deltaPercentage, isNull);
      expect(metrics.temperature.deltaPercentage, isNull);
      expect(metrics.humidity.deltaPercentage, isNull);
    });

    test('should map an empty backend payload onto a zeroed aggregate', () {
      // Arrange
      final resource = DashboardMetricsResource.fromJson(emptyDashboardMetricsJson);

      // Act
      final metrics = dashboardMetricsResourceToDomain(resource);

      // Assert
      expect(metrics.aqi.value, 0);
      expect(metrics.aqi.category, kFallbackAqiCategory);
      expect(metrics.co2.value, 0);
      expect(metrics.pm2_5.value, 0);
      expect(metrics.temperature.value, 0);
      expect(metrics.humidity.value, 0);
      expect(metrics.calculatedAt, '');
    });

    test('should pass an unrecognised category string through untouched '
        'because the domain keeps it as free-form text', () {
      // Arrange
      final resource = buildDashboardMetricsResource(
        aqiValue: 42,
        aqiCategory: 'Alien Category From A Newer Backend',
      );

      // Act
      final metrics = dashboardMetricsResourceToDomain(resource);

      // Assert
      expect(metrics.aqi.category, 'Alien Category From A Newer Backend');
    });

    test('should trim the category while mapping it to the domain object', () {
      // Arrange
      final resource = buildDashboardMetricsResource(aqiCategory: '  Good  ');

      // Act
      final metrics = dashboardMetricsResourceToDomain(resource);

      // Assert
      expect(metrics.aqi.category, 'Good');
    });

    test('should reject a blank category so an unlabelled reading cannot reach '
        'the UI', () {
      // Arrange
      final resource = buildDashboardMetricsResource(aqiCategory: '   ');

      // Act / Assert
      expect(
        () => dashboardMetricsResourceToDomain(resource),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject a negative AQI reading with the value object guard', () {
      // Arrange
      final resource = buildDashboardMetricsResource(aqiValue: -1);

      // Act / Assert
      expect(
        () => dashboardMetricsResourceToDomain(resource),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should never renumber a delta percentage while mapping', () {
      // Arrange
      final resource = buildDashboardMetricsResource(
        co2DeltaPercentage: 150,
        pm2_5DeltaPercentage: -0.4,
      );

      // Act
      final metrics = dashboardMetricsResourceToDomain(resource);

      // Assert
      expect(metrics.co2.deltaPercentage, 150);
      expect(metrics.pm2_5.deltaPercentage, -0.4);
    });
  });

  group('trendDataPointResourceToDomain', () {
    test('should map each trend series field onto the matching domain field',
        () {
      // Arrange
      final json = trendPointJson(
        timestamp: '2024-05-01T09:15:00Z',
        aqiValue: 128.5,
        co2: 812.25,
        pm2_5: 47.9,
        temperature: 24.75,
        humidity: 63,
      );
      final resource = TrendDataPointResource.fromJson(json);

      // Act
      final point = trendDataPointResourceToDomain(resource);

      // Assert
      expect(point.timestamp, '2024-05-01T09:15:00Z');
      expect(point.aqiValue, 128.5);
      expect(point.co2, 812.25);
      expect(point.pm2_5, 47.9);
      expect(point.temperature, 24.75);
      expect(point.humidity, 63.0);
    });

    test('should trim the timestamp while mapping it to the domain object',
        () {
      // Arrange
      final resource = buildTrendDataPointResource(
        timestamp: '  2024-05-01T09:00:00Z  ',
      );

      // Act
      final point = trendDataPointResourceToDomain(resource);

      // Assert
      expect(point.timestamp, '2024-05-01T09:00:00Z');
    });

    test('should reject a point whose timestamp was missing in the payload',
        () {
      // Arrange
      final resource = TrendDataPointResource.fromJson(
        trendPointJson(timestamp: null),
      );

      // Act / Assert
      expect(
        () => trendDataPointResourceToDomain(resource),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Timestamp cannot be empty',
          ),
        ),
      );
    });

    test('should map an empty trend series onto an empty domain list when the '
        'whole resource is traversed', () {
      // Arrange
      final resource = TrendsResource.fromJson(trendsJson(dataPoints: <dynamic>[]));

      // Act
      final points = resource.dataPoints.map(trendDataPointResourceToDomain).toList();

      // Assert
      expect(points, isEmpty);
    });
  });
}