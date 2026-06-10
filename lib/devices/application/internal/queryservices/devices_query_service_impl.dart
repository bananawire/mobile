import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/queries/get_device_by_id.query.dart';
import 'package:mobile/devices/domain/model/queries/get_devices_by_space.query.dart';
import 'package:mobile/devices/domain/model/queries/get_device_status.query.dart';
import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/device_page.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/device_status.read_model.dart';
import 'package:mobile/devices/domain/services/devices.query-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/devices.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_page_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_status_response.resource.dart';

class DevicesQueryServiceImpl implements DevicesQueryService {
  final DevicesGateway _gateway;

  DevicesQueryServiceImpl(this._gateway);

  @override
  Future<Either<Failure, DevicePageReadModel>> handleGetDevicesBySpace(
    GetDevicesBySpaceQuery query,
  ) async {
    try {
      final raw = await _gateway.getDevicesBySpaceRaw(
        spaceId: query.spaceId.value,
        page: query.page,
        size: query.size,
      );
      final resource = DevicePageResponseResource.fromJson(raw);
      return Right(
        DevicePageReadModel(
          content: resource.content.map(_toDeviceReadModel).toList(),
          totalElements: resource.totalElements,
          number: resource.number,
          size: resource.size,
        ),
      );
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, DeviceReadModel>> handleGetDeviceById(GetDeviceByIdQuery query) async {
    try {
      final raw = await _gateway.getDeviceByIdRaw(query.deviceId.value);
      final resource = DeviceResponseResource.fromJson(raw);
      return Right(_toDeviceReadModel(resource));
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, DeviceStatusReadModel>> handleGetDeviceStatus(GetDeviceStatusQuery query) async {
    try {
      final raw = await _gateway.getDeviceStatusRaw(query.deviceId.value);
      final resource = DeviceStatusResponseResource.fromJson(raw);
      return Right(
        DeviceStatusReadModel(
          deviceId: resource.deviceId,
          status: resource.status,
          lastSeenAt: resource.lastSeenAt,
        ),
      );
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  DeviceReadModel _toDeviceReadModel(DeviceResponseResource resource) {
    return DeviceReadModel(
      id: resource.id,
      serialNumber: resource.serialNumber,
      name: resource.name,
      status: resource.status,
      spaceId: resource.spaceId,
      ownerUserId: resource.ownerUserId,
      configuration: resource.configuration,
      thresholds: resource.thresholds,
      hardwareId: resource.hardwareId,
      deviceType: resource.deviceType,
      activatedAt: resource.activatedAt,
      lastSeenAt: resource.lastSeenAt,
      createdAt: resource.createdAt,
      updatedAt: resource.updatedAt,
    );
  }

  String _mapError(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
