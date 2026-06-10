import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';

enum DeviceThresholdWriteIntent { create, update }

class WriteDeviceThresholdCommand {
  final String deviceId;
  final MetricThreshold metric;
  final double value;
  final bool enabled;
  final DeviceThresholdWriteIntent intent;

  WriteDeviceThresholdCommand({
    required this.deviceId,
    required this.metric,
    required this.value,
    required this.enabled,
    required this.intent,
  }) {
    if (deviceId.trim().isEmpty) {
      throw ArgumentError('deviceId cannot be empty');
    }
    if (value <= 0) {
      throw ArgumentError('value must be greater than 0');
    }
  }
}