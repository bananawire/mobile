import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/queries/get_device_by_id.query.dart';
import 'package:mobile/devices/domain/model/queries/get_devices_by_space.query.dart';
import 'package:mobile/devices/domain/model/queries/get_device_status.query.dart';
import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/device_page.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/device_status.read_model.dart';

abstract class DevicesQueryService {
  Future<Either<Failure, DevicePageReadModel>> handleGetDevicesBySpace(
    GetDevicesBySpaceQuery query,
  );

  Future<Either<Failure, DeviceReadModel>> handleGetDeviceById(GetDeviceByIdQuery query);

  Future<Either<Failure, DeviceStatusReadModel>> handleGetDeviceStatus(GetDeviceStatusQuery query);
}
