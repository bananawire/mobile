import 'package:mobile/devices/interfaces/rest/resources/device_threshold.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_device_threshold.resource.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';

abstract class DeviceThresholdsGateway {
  Future<List<DeviceThresholdResource>> getThresholdsByDevice(String deviceId);

  Future<DeviceThresholdResource> getThresholdByMetric(String deviceId, MetricThreshold metric);

  Future<DeviceThresholdResource> createThreshold(String deviceId, UpdateDeviceThresholdResource resource);

  Future<DeviceThresholdResource> updateThreshold(String deviceId, UpdateDeviceThresholdResource resource);

  Future<void> removeThreshold(String deviceId, MetricThreshold metric);
}
