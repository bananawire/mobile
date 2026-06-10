import 'package:mobile/devices/domain/model/commands/write_device_threshold.command.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_device_threshold.resource.dart';

UpdateDeviceThresholdResource toUpdateDeviceThresholdResource(WriteDeviceThresholdCommand command) {
  return UpdateDeviceThresholdResource(
    metric: command.metric,
    value: command.value,
    enabled: command.enabled,
  );
}

WriteDeviceThresholdCommand toWriteDeviceThresholdCommand({
  required String deviceId,
  required MetricThreshold metric,
  required double value,
  required bool enabled,
  required DeviceThresholdWriteIntent intent,
}) {
  return WriteDeviceThresholdCommand(
    deviceId: deviceId,
    metric: metric,
    value: value,
    enabled: enabled,
    intent: intent,
  );
}
