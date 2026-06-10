import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_thresholds.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_threshold.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_device_threshold.resource.dart';

class DeviceThresholdsHttpGateway implements DeviceThresholdsGateway {
  final Dio _dio;

  DeviceThresholdsHttpGateway(this._dio);

  @override
  Future<List<DeviceThresholdResource>> getThresholdsByDevice(String deviceId) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/devices/$deviceId/thresholds',
    );

    final list = response.data as List<dynamic>;
    return list
        .map((e) => DeviceThresholdResource.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DeviceThresholdResource> getThresholdByMetric(
    String deviceId,
    MetricThreshold metric,
  ) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/devices/$deviceId/thresholds',
    );

    final list = response.data as List<dynamic>;
    final found = list.firstWhere(
      (e) => (e['metric'] ?? '').toString().toUpperCase() == metric.apiName,
      orElse: () => null,
    );

    if (found == null) {
      throw Exception('Threshold not found for metric: ${metric.name}');
    }

    return DeviceThresholdResource.fromJson(found as Map<String, dynamic>);
  }

  @override
  Future<DeviceThresholdResource> createThreshold(
    String deviceId,
    UpdateDeviceThresholdResource resource,
  ) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/devices/$deviceId/thresholds',
      data: resource.toJson(),
    );
    return DeviceThresholdResource.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DeviceThresholdResource> updateThreshold(
    String deviceId,
    UpdateDeviceThresholdResource resource,
  ) async {
    final response = await _dio.put(
      '${ApiConstants.apiPrefix}/devices/$deviceId/thresholds',
      data: resource.toJson(),
    );
    return DeviceThresholdResource.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeThreshold(String deviceId, MetricThreshold metric) async {
    await _dio.delete(
      '${ApiConstants.apiPrefix}/devices/$deviceId/thresholds/${metric.apiName}',
    );
  }
}
