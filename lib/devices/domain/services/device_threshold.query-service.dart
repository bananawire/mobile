import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/readmodels/device_threshold.read_model.dart';
import 'package:mobile/devices/domain/model/queries/get_device_thresholds.query.dart';
import 'package:mobile/devices/domain/model/queries/get_device_threshold_by_metric.query.dart';

abstract class DeviceThresholdQueryService {
  Future<Either<Failure, List<DeviceThresholdReadModel>>> handleGetDeviceThresholds(
    GetDeviceThresholdsQuery query,
  );

  Future<Either<Failure, DeviceThresholdReadModel>> handleGetDeviceThresholdByMetric(
    GetDeviceThresholdByMetricQuery query,
  );
}
