import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';

class UpdateDeviceThresholdResource {
  final MetricThreshold metric;
  final double value;
  final bool enabled;

  const UpdateDeviceThresholdResource({
    required this.metric,
    required this.value,
    required this.enabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'metric': metric.apiName,
      'value': value,
      'enabled': enabled,
    };
  }
}
