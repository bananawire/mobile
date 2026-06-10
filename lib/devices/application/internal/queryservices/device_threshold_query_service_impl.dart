import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/readmodels/device_threshold.read_model.dart';
import 'package:mobile/devices/domain/model/queries/get_device_threshold_by_metric.query.dart';
import 'package:mobile/devices/domain/model/queries/get_device_thresholds.query.dart';
import 'package:mobile/devices/domain/services/device_threshold.query-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_thresholds.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_threshold.resource.dart';

class DeviceThresholdQueryServiceImpl implements DeviceThresholdQueryService {
  final DeviceThresholdsGateway _gateway;

  DeviceThresholdQueryServiceImpl(this._gateway);

  @override
  Future<Either<Failure, List<DeviceThresholdReadModel>>> handleGetDeviceThresholds(
    GetDeviceThresholdsQuery query,
  ) async {
    try {
      final result = await _gateway.getThresholdsByDevice(query.deviceId);
      return Right(result.map(_toReadModel).toList());
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, DeviceThresholdReadModel>> handleGetDeviceThresholdByMetric(
    GetDeviceThresholdByMetricQuery query,
  ) async {
    try {
      final result = await _gateway.getThresholdByMetric(
        query.deviceId,
        query.metric,
      );
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

  String _mapError(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
