import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/domain/model/valueobjects/aqi.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/dashboard_metrics.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/metric_delta.valueobject.dart';

import '../analytics_fixtures.dart';

void main() {
  group('DashboardMetrics', () {
    test('should expose every metric of the aggregate exactly as constructed',
        () {
      // Arrange
      final aqi = Aqi(42, 'Good');
      final co2 = MetricDelta(612, 3.5);
      final pm2_5 = MetricDelta(8.4, -12.25);
      final temperature = MetricDelta(21.6, null);
      final humidity = MetricDelta(48.2, 0);
      const calculatedAt = '2024-05-01T10:00:00Z';

      // Act
      final metrics = DashboardMetrics(
        aqi: aqi,
        co2: co2,
        pm2_5: pm2_5,
        temperature: temperature,
        humidity: humidity,
        calculatedAt: calculatedAt,
      );

      // Assert
      expect(metrics.aqi.value, 42);
      expect(metrics.aqi.category, 'Good');
      expect(metrics.co2.value, 612);
      expect(metrics.co2.deltaPercentage, 3.5);
      expect(metrics.pm2_5.value, 8.4);
      expect(metrics.pm2_5.deltaPercentage, -12.25);
      expect(metrics.temperature.value, 21.6);
      expect(metrics.temperature.deltaPercentage, isNull);
      expect(metrics.humidity.value, 48.2);
      expect(metrics.humidity.deltaPercentage, 0);
      expect(metrics.calculatedAt, calculatedAt);
    });

    test('should aggregate a metrics snapshot carrying no comparison period',
        () {
      // Arrange / Act
      final metrics = buildDashboardMetrics(
        temperature: MetricDelta(21.6, null),
      );

      // Assert
      expect(metrics.temperature.deltaPercentage, isNull);
      expect(metrics.pm2_5.deltaPercentage, isNotNull);
    });

    test('should hold an all-zero snapshot representing a device that has no '
        'measurements', () {
      // Arrange / Act
      final metrics = DashboardMetrics(
        aqi: Aqi(0, kFallbackAqiCategory),
        co2: MetricDelta(0, null),
        pm2_5: MetricDelta(0, null),
        temperature: MetricDelta(0, null),
        humidity: MetricDelta(0, null),
        calculatedAt: '',
      );

      // Assert
      expect(metrics.aqi.value, 0);
      expect(metrics.aqi.category, kFallbackAqiCategory);
      expect(metrics.co2.value, 0);
      expect(metrics.co2.deltaPercentage, isNull);
      expect(metrics.pm2_5.value, 0);
      expect(metrics.temperature.value, 0);
      expect(metrics.humidity.value, 0);
      expect(metrics.calculatedAt, '');
    });
  });
}