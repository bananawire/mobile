import 'package:mobile/analytics/domain/model/valueobjects/aqi.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/metric_delta.valueobject.dart';

class DashboardMetrics {
  final Aqi aqi;
  final MetricDelta co2;
  final MetricDelta pm2_5;
  final MetricDelta temperature;
  final MetricDelta humidity;
  final String calculatedAt;

  const DashboardMetrics({
    required this.aqi,
    required this.co2,
    required this.pm2_5,
    required this.temperature,
    required this.humidity,
    required this.calculatedAt,
  });
}
