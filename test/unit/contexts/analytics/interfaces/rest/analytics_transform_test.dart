import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/domain/model/valueobjects/aqi.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/dashboard_metrics.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/metric_delta.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';
import 'package:mobile/analytics/interfaces/rest/resources/dashboard_metrics.resource.dart';
import 'package:mobile/analytics/interfaces/rest/resources/trends.resource.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_transform.dart';

import '../../../../../support/test_widget_harness.dart';

void main() {
  group('analytics_transform', () {
    test('should map DashboardMetricsResource to DashboardMetrics domain model', () {
      // Arrange
      const resource = DashboardMetricsResource(
        aqiValue: 48.0,
        aqiCategory: 'Good',
        averageCo2: 520.0,
        averagePm2_5: 11.2,
        averageTemperature: 22.0,
        averageHumidity: 45.0,
        co2DeltaPercentage: 3.1,
        pm2_5DeltaPercentage: -0.5,
        temperatureDeltaPercentage: 1.2,
        humidityDeltaPercentage: -2.0,
        calculatedAt: '2026-10-02T12:00:00Z',
      );

      // Act
      final domain = dashboardMetricsResourceToDomain(resource);

      // Assert
      expect(domain.aqi.value, equals(48.0));
      expect(domain.aqi.category, equals('Good'));
      expect(domain.co2.value, equals(520.0));
      expect(domain.co2.deltaPercentage, equals(3.1));
      expect(domain.pm2_5.value, equals(11.2));
      expect(domain.pm2_5.deltaPercentage, equals(-0.5));
      expect(domain.temperature.value, equals(22.0));
      expect(domain.temperature.deltaPercentage, equals(1.2));
      expect(domain.humidity.value, equals(45.0));
      expect(domain.humidity.deltaPercentage, equals(-2.0));
      expect(domain.calculatedAt, equals('2026-10-02T12:00:00Z'));
    });

    test('should map TrendDataPointResource to TrendPoint domain model', () {
      // Arrange
      const resource = TrendDataPointResource(
        timestamp: '2026-10-02T12:00:00Z',
        aqiValue: 52.0,
        co2: 610.0,
        pm2_5: 13.0,
        temperature: 23.0,
        humidity: 47.0,
      );

      // Act
      final domain = trendDataPointResourceToDomain(resource);

      // Assert
      expect(domain.timestamp, equals('2026-10-02T12:00:00Z'));
      expect(domain.aqiValue, equals(52.0));
      expect(domain.co2, equals(610.0));
      expect(domain.pm2_5, equals(13.0));
      expect(domain.temperature, equals(23.0));
      expect(domain.humidity, equals(47.0));
    });
  });

  group('analytics_presentation colors and formatters', () {
    test('should return correct AQI status color based on thresholds', () {
      expect(getAqiColor(null), equals(kMutedColor));
      expect(getAqiColor(0), equals(kGoodColor));
      expect(getAqiColor(50), equals(kGoodColor));
      expect(getAqiColor(51), equals(kModerateColor));
      expect(getAqiColor(100), equals(kModerateColor));
      expect(getAqiColor(101), equals(kSensitiveColor));
      expect(getAqiColor(150), equals(kSensitiveColor));
      expect(getAqiColor(151), equals(kUnhealthyColor));
      expect(getAqiColor(300), equals(kUnhealthyColor));
    });

    test('should return correct PM2.5 status color based on thresholds', () {
      expect(getPm25StatusColor(null), equals(kMutedColor));
      expect(getPm25StatusColor(10.0), equals(kGoodColor));
      expect(getPm25StatusColor(25.0), equals(kGoodColor));
      expect(getPm25StatusColor(25.1), equals(kModerateColor));
      expect(getPm25StatusColor(60.0), equals(kModerateColor));
      expect(getPm25StatusColor(60.1), equals(kUnhealthyColor));
    });

    test('should return correct CO2 status color based on thresholds', () {
      expect(getCo2StatusColor(null), equals(kMutedColor));
      expect(getCo2StatusColor(600.0), equals(kGoodColor));
      expect(getCo2StatusColor(700.0), equals(kGoodColor));
      expect(getCo2StatusColor(701.0), equals(kModerateColor));
      expect(getCo2StatusColor(1000.0), equals(kModerateColor));
      expect(getCo2StatusColor(1001.0), equals(kUnhealthyColor));
    });

    test('should return correct Temperature status color based on thresholds', () {
      expect(getTempStatusColor(null), equals(kMutedColor));
      expect(getTempStatusColor(22.0), equals(kGoodColor));
      expect(getTempStatusColor(26.0), equals(kGoodColor));
      expect(getTempStatusColor(26.1), equals(kUnhealthyColor));
    });

    test('should return correct Humidity status color based on thresholds', () {
      expect(getHumidityStatusColor(null), equals(kMutedColor));
      expect(getHumidityStatusColor(50.0), equals(kGoodColor));
      expect(getHumidityStatusColor(60.0), equals(kGoodColor));
      expect(getHumidityStatusColor(60.1), equals(kModerateColor));
      expect(getHumidityStatusColor(85.0), equals(kModerateColor));
      expect(getHumidityStatusColor(85.1), equals(kUnhealthyColor));
    });

    test('should format delta percentage correctly', () {
      expect(formatDelta(null), equals('N/A'));
      expect(formatDelta(double.infinity), equals('N/A'));
      expect(formatDelta(double.nan), equals('N/A'));
      expect(formatDelta(5.234), equals('5.2%'));
      expect(formatDelta(-3.87), equals('3.9%'));
      expect(formatDelta(0.0), equals('0.0%'));
    });

    test('should format metric value correctly', () {
      expect(formatValue(null), equals('--'));
      expect(formatValue(double.infinity), equals('--'));
      expect(formatValue(double.nan), equals('--'));
      expect(formatValue(12.345), equals('12.35'));
      expect(formatValue(0.0), equals('0.00'));
    });

    testWidgets('should format update time relative to elapsed seconds', (tester) async {
      late String resultJustNow;
      late String resultSecondsAgo;

      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder: (context) {
              resultJustNow = formatUpdateTime(context, 3);
              resultSecondsAgo = formatUpdateTime(context, 15);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resultJustNow.toLowerCase(), contains('just now'));
      expect(resultSecondsAgo, contains('15'));
    });

    test('should extract correct metric value from TrendPoint', () {
      final point = TrendPoint(
        timestamp: '2026-10-02T12:00:00Z',
        aqiValue: 45.0,
        co2: 500.0,
        pm2_5: 12.0,
        temperature: 22.0,
        humidity: 55.0,
      );

      expect(getMetricValue(point, 'co2'), equals(500.0));
      expect(getMetricValue(point, 'pm2_5'), equals(12.0));
      expect(getMetricValue(point, 'temperature'), equals(22.0));
      expect(getMetricValue(point, 'humidity'), equals(55.0));
      expect(getMetricValue(point, 'aqiValue'), equals(45.0));
      expect(getMetricValue(point, 'unknown'), equals(45.0));
    });

    test('should calculate AQI and category from PM2.5 reading according to EPA breakpoints', () {
      // 0 - 12.0 -> Good
      final good = calculateAqiFromPm25(6.0);
      expect(good.value, equals(25.0));
      expect(good.category, equals('Good'));

      // 12.1 - 35.4 -> Moderate
      final moderate = calculateAqiFromPm25(24.0);
      expect(moderate.category, equals('Moderate'));

      // 35.5 - 55.4 -> Unhealthy for Sensitive
      final sensitive = calculateAqiFromPm25(45.0);
      expect(sensitive.category, equals('Unhealthy for Sensitive'));

      // 55.5 - 150.4 -> Unhealthy
      final unhealthy = calculateAqiFromPm25(100.0);
      expect(unhealthy.category, equals('Unhealthy'));

      // 150.5 - 250.4 -> Very Unhealthy
      final veryUnhealthy = calculateAqiFromPm25(200.0);
      expect(veryUnhealthy.category, equals('Very Unhealthy'));

      // 250.5 - 350.4 -> Hazardous
      final hazardous1 = calculateAqiFromPm25(300.0);
      expect(hazardous1.category, equals('Hazardous'));

      // > 350.4 -> Hazardous
      final hazardous2 = calculateAqiFromPm25(400.0);
      expect(hazardous2.category, equals('Hazardous'));
    });

    test('should extract active metric delta percentage based on selected metric', () {
      final liveData = DashboardMetrics(
        aqi: Aqi(45.0, 'Good'),
        co2: MetricDelta(500.0, 4.5),
        pm2_5: MetricDelta(12.0, -1.5),
        temperature: MetricDelta(22.0, 2.0),
        humidity: MetricDelta(50.0, -3.0),
        calculatedAt: '2026-10-02T12:00:00Z',
      );

      expect(getActiveMetricDelta(null, 'co2'), isNull);
      expect(getActiveMetricDelta(liveData, 'aqiValue'), equals(-1.5));
      expect(getActiveMetricDelta(liveData, 'pm2_5'), equals(-1.5));
      expect(getActiveMetricDelta(liveData, 'co2'), equals(4.5));
      expect(getActiveMetricDelta(liveData, 'temperature'), equals(2.0));
      expect(getActiveMetricDelta(liveData, 'humidity'), equals(-3.0));
      expect(getActiveMetricDelta(liveData, 'unknown'), isNull);
    });
  });
}
