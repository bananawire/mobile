import 'package:mobile/analytics/domain/model/valueobjects/aqi.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/dashboard_metrics.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/live_telemetry.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/metric_delta.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';
import 'package:mobile/analytics/interfaces/rest/resources/dashboard_metrics.resource.dart';
import 'package:mobile/analytics/interfaces/rest/resources/trends.resource.dart';

/// Shared fixtures for the analytics bounded context.
///
/// This helper is intentionally NOT named `*_test.dart` so that the test
/// runner never executes it as a suite.

const String kFallbackAqiCategory = 'No measurements';

/// A fully populated dashboard-metrics JSON payload as the backend sends it.
Map<String, dynamic> dashboardMetricsJson({
  Object? aqiValue = 42.0,
  Object? aqiCategory = 'Good',
  Object? averageCo2 = 612.0,
  Object? averagePm2_5 = 8.4,
  Object? averageTemperature = 21.6,
  Object? averageHumidity = 48.2,
  Object? co2DeltaPercentage,
  Object? pm2_5DeltaPercentage,
  Object? temperatureDeltaPercentage,
  Object? humidityDeltaPercentage,
  Object? calculatedAt = '2024-05-01T10:00:00Z',
}) {
  return <String, dynamic>{
    'aqiValue': aqiValue,
    'aqiCategory': aqiCategory,
    'averageCo2': averageCo2,
    'averagePm2_5': averagePm2_5,
    'averageTemperature': averageTemperature,
    'averageHumidity': averageHumidity,
    'co2DeltaPercentage': ?co2DeltaPercentage,
    'pm2_5DeltaPercentage': ?pm2_5DeltaPercentage,
    'temperatureDeltaPercentage': ?temperatureDeltaPercentage,
    'humidityDeltaPercentage': ?humidityDeltaPercentage,
    'calculatedAt': ?calculatedAt,
  };
}

/// The payload the backend answers with when a device has no measurements.
const Map<String, dynamic> emptyDashboardMetricsJson = <String, dynamic>{};

/// A single trend data-point JSON payload.
Map<String, dynamic> trendPointJson({
  Object? timestamp = '2024-05-01T09:00:00Z',
  Object? aqiValue = 42.0,
  Object? co2 = 612.0,
  Object? pm2_5 = 8.4,
  Object? temperature = 21.6,
  Object? humidity = 48.2,
}) {
  return <String, dynamic>{
    'timestamp': ?timestamp,
    'aqiValue': aqiValue,
    'co2': co2,
    'pm2_5': pm2_5,
    'temperature': temperature,
    'humidity': humidity,
  };
}

/// A trends JSON payload carrying [dataPoints] under the `dataPoints` key.
Map<String, dynamic> trendsJson({List<dynamic>? dataPoints}) {
  return <String, dynamic>{
    'dataPoints': ?dataPoints,
  };
}

/// A realistic [DashboardMetricsResource] built straight from [dashboardMetricsJson].
DashboardMetricsResource buildDashboardMetricsResource({
  double aqiValue = 42,
  String aqiCategory = 'Good',
  double averageCo2 = 612,
  double averagePm2_5 = 8.4,
  double averageTemperature = 21.6,
  double averageHumidity = 48.2,
  double? co2DeltaPercentage = 3.5,
  double? pm2_5DeltaPercentage = -12.25,
  double? temperatureDeltaPercentage,
  double? humidityDeltaPercentage,
  String calculatedAt = '2024-05-01T10:00:00Z',
}) {
  return DashboardMetricsResource(
    aqiValue: aqiValue,
    aqiCategory: aqiCategory,
    averageCo2: averageCo2,
    averagePm2_5: averagePm2_5,
    averageTemperature: averageTemperature,
    averageHumidity: averageHumidity,
    co2DeltaPercentage: co2DeltaPercentage,
    pm2_5DeltaPercentage: pm2_5DeltaPercentage,
    temperatureDeltaPercentage: temperatureDeltaPercentage,
    humidityDeltaPercentage: humidityDeltaPercentage,
    calculatedAt: calculatedAt,
  );
}

/// A realistic [TrendDataPointResource].
TrendDataPointResource buildTrendDataPointResource({
  String timestamp = '2024-05-01T09:00:00Z',
  double aqiValue = 42,
  double co2 = 612,
  double pm2_5 = 8.4,
  double temperature = 21.6,
  double humidity = 48.2,
}) {
  return TrendDataPointResource(
    timestamp: timestamp,
    aqiValue: aqiValue,
    co2: co2,
    pm2_5: pm2_5,
    temperature: temperature,
    humidity: humidity,
  );
}

/// A [TrendsResource] holding [points].
TrendsResource buildTrendsResource({
  List<TrendDataPointResource> points = const [],
}) {
  return TrendsResource(dataPoints: points);
}

/// A realistic [DashboardMetrics] domain aggregate.
DashboardMetrics buildDashboardMetrics({
  Aqi? aqi,
  MetricDelta? co2,
  MetricDelta? pm2_5,
  MetricDelta? temperature,
  MetricDelta? humidity,
  String calculatedAt = '2024-05-01T10:00:00Z',
}) {
  return DashboardMetrics(
    aqi: aqi ?? Aqi(42, 'Good'),
    co2: co2 ?? MetricDelta(612, 3.5),
    pm2_5: pm2_5 ?? MetricDelta(8.4, -12.25),
    temperature: temperature ?? MetricDelta(21.6, null),
    humidity: humidity ?? MetricDelta(48.2, 0),
    calculatedAt: calculatedAt,
  );
}

/// A realistic [TrendPoint] domain read model.
TrendPoint buildTrendPoint({
  String timestamp = '2024-05-01T09:00:00Z',
  double aqiValue = 42,
  double co2 = 612,
  double pm2_5 = 8.4,
  double temperature = 21.6,
  double humidity = 48.2,
}) {
  return TrendPoint(
    timestamp: timestamp,
    aqiValue: aqiValue,
    co2: co2,
    pm2_5: pm2_5,
    temperature: temperature,
    humidity: humidity,
  );
}

/// A realistic [LiveTelemetry] sample as the SSE stream would emit it.
LiveTelemetry buildLiveTelemetry({
  String deviceId = 'device-1',
  double co2 = 700,
  double pm2_5 = 12.5,
  double temperature = 22.5,
  double humidity = 55,
  String timestamp = '2024-05-01T10:00:00Z',
}) {
  return LiveTelemetry(
    deviceId: deviceId,
    co2: co2,
    pm2_5: pm2_5,
    temperature: temperature,
    humidity: humidity,
    timestamp: timestamp,
  );
}