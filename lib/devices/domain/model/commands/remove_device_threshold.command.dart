import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';

class RemoveDeviceThresholdCommand {
  final String deviceId;
  final MetricThreshold metric;

  RemoveDeviceThresholdCommand({
    required this.deviceId,
    required this.metric,
  }) {
    if (deviceId.trim().isEmpty) {
      throw ArgumentError('deviceId cannot be empty');
    }
  }
}