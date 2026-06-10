import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';

class DeviceThresholdResource {
  final String deviceId;
  final MetricThreshold metric;
  final double value;
  final bool enabled;
  final String metricLabel;
  final String metricUnit;

  const DeviceThresholdResource({
    required this.deviceId,
    required this.metric,
    required this.value,
    required this.enabled,
    required this.metricLabel,
    required this.metricUnit,
  });

  factory DeviceThresholdResource.fromJson(Map<String, dynamic> json) {
    final metricRaw = (json['metric'] ?? '').toString();
    final metric = MetricThreshold.fromString(metricRaw);
    if (metric == null) {
      throw Exception('Unknown metric: $metricRaw');
    }

    final valueRaw = json['value'];
    final value = valueRaw is num ? valueRaw.toDouble() : double.tryParse(valueRaw?.toString() ?? '');
    if (value == null) {
      throw Exception('Invalid threshold value');
    }

    final enabledRaw = json['enabled'];
    final enabled = enabledRaw is bool ? enabledRaw : enabledRaw?.toString().toLowerCase() == 'true';

    return DeviceThresholdResource(
      deviceId: (json['deviceId'] ?? '').toString(),
      metric: metric,
      value: value,
      enabled: enabled,
      metricLabel: (json['metricLabel'] ?? metric.label).toString(),
      metricUnit: (json['metricUnit'] ?? metric.unit).toString(),
    );
  }
}
