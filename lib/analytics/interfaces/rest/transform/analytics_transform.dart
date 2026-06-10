import 'package:mobile/analytics/domain/model/valueobjects/aqi.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/dashboard_metrics.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/metric_delta.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';
import 'package:mobile/analytics/interfaces/rest/resources/dashboard_metrics.resource.dart';
import 'package:mobile/analytics/interfaces/rest/resources/trends.resource.dart';

DashboardMetrics dashboardMetricsResourceToDomain(DashboardMetricsResource resource) {
  return DashboardMetrics(
    aqi: Aqi(resource.aqiValue, resource.aqiCategory),
    co2: MetricDelta(resource.averageCo2, resource.co2DeltaPercentage),
    pm2_5: MetricDelta(resource.averagePm2_5, resource.pm2_5DeltaPercentage),
    temperature: MetricDelta(resource.averageTemperature, resource.temperatureDeltaPercentage),
    humidity: MetricDelta(resource.averageHumidity, resource.humidityDeltaPercentage),
    calculatedAt: resource.calculatedAt,
  );
}

TrendPoint trendDataPointResourceToDomain(TrendDataPointResource resource) {
  return TrendPoint(
    timestamp: resource.timestamp,
    aqiValue: resource.aqiValue,
    co2: resource.co2,
    pm2_5: resource.pm2_5,
    temperature: resource.temperature,
    humidity: resource.humidity,
  );
}
