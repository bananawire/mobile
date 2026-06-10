import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';

class DeviceThresholdReadModel {
  final String deviceId;
  final MetricThreshold metric;
  final double value;
  final bool enabled;
  final String metricLabel;
  final String metricUnit;

  const DeviceThresholdReadModel({
    required this.deviceId,
    required this.metric,
    required this.value,
    required this.enabled,
    required this.metricLabel,
    required this.metricUnit,
  });
}
