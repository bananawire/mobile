import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/remove_device_threshold.command.dart';
import 'package:mobile/devices/domain/model/commands/write_device_threshold.command.dart';
import 'package:mobile/devices/domain/model/readmodels/device_threshold.read_model.dart';
import 'package:mobile/devices/domain/services/device_threshold.command-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_thresholds.gateway.dart';
import 'package:mobile/devices/interfaces/rest/transform/device_thresholds_transform.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_threshold.resource.dart';

class DeviceThresholdCommandServiceImpl implements DeviceThresholdCommandService {
  final DeviceThresholdsGateway _gateway;

  DeviceThresholdCommandServiceImpl(this._gateway);

  @override
  Future<Either<Failure, DeviceThresholdReadModel>> handleWriteThreshold(
    WriteDeviceThresholdCommand command,
  ) async {
    try {
      final resource = toUpdateDeviceThresholdResource(command);
      final result = command.intent == DeviceThresholdWriteIntent.create
          ? await _gateway.createThreshold(command.deviceId, resource)
          : await _gateway.updateThreshold(command.deviceId, resource);
      return Right(_toReadModel(result));
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  DeviceThresholdReadModel _toReadModel(DeviceThresholdResource resource) {
    return DeviceThresholdReadModel(
      deviceId: resource.deviceId,
      metric: resource.metric,
      value: resource.value,
      enabled: resource.enabled,
      metricLabel: resource.metricLabel,
      metricUnit: resource.metricUnit,
    );
  }

  @override
  Future<Either<Failure, void>> handleRemoveThreshold(
    RemoveDeviceThresholdCommand command,
  ) async {
    try {
      await _gateway.removeThreshold(command.deviceId, command.metric);
      return const Right(null);
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  String _mapError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      switch (statusCode) {
        case 400:
          return 'Invalid request. Check threshold values.';
        case 401:
          return 'Session expired. Please sign in again.';
        case 403:
          return 'Access denied. Device does not belong to you.';
        case 404:
          return 'Device or threshold not found.';
        case 409:
          return 'Threshold already exists for this metric.';
        case 500:
        case 502:
        case 503:
          return 'Server error. Please try again later.';
        default:
          return 'Network error. Please check your connection.';
      }
    }
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
