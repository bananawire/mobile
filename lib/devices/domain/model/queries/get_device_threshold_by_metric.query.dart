import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';

class GetDeviceThresholdByMetricQuery {
  final String deviceId;
  final MetricThreshold metric;

  GetDeviceThresholdByMetricQuery({
    required this.deviceId,
    required this.metric,
  }) {
    if (deviceId.trim().isEmpty) {
      throw ArgumentError('deviceId cannot be empty');
    }
  }
}