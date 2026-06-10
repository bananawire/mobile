import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/claim_device_to_space.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_device.command.dart';
import 'package:mobile/devices/domain/model/commands/pair_device.command.dart';
import 'package:mobile/devices/domain/model/commands/update_device_name.command.dart';
import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/device_pairing.read_model.dart';
import 'package:mobile/devices/domain/services/devices.command-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/devices.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_pairing.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/transform/devices_transform.dart';

class DevicesCommandServiceImpl implements DevicesCommandService {
  final DevicesGateway _gateway;

  DevicesCommandServiceImpl(this._gateway);

  @override
  Future<Either<Failure, DevicePairingReadModel>> handlePairDevice(
    PairDeviceCommand command,
  ) async {
    try {
      final req = toPairDeviceRequestResource(command);
      final raw = await _gateway.pairDeviceRaw(requestBody: req.toJson());
      final resource = DevicePairingResource.fromJson(raw);
      return Right(DevicePairingReadModel(deviceId: resource.deviceId, claimToken: resource.claimToken));
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, DeviceReadModel>> handleClaimDeviceToSpace(
    ClaimDeviceToSpaceCommand command,
  ) async {
    try {
      final req = toClaimDeviceRequestResource(command);
      final raw = await _gateway.claimDeviceRaw(requestBody: req.toJson());
      final resource = DeviceResponseResource.fromJson(raw);
      return Right(
        DeviceReadModel(
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
        ),
      );
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> handleDeleteDevice(DeleteDeviceCommand command) async {
    try {
      await _gateway.deleteDeviceRaw(command.deviceId.value);
      return const Right(null);
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> handleUpdateDeviceName(UpdateDeviceNameCommand command) async {
    try {
      await _gateway.updateDeviceNameRaw(
        command.deviceId.value,
        {'name': command.name.value},
      );
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
          return 'Invalid request.';
        case 401:
          return 'Session expired. Please sign in again.';
        case 403:
          return 'Access denied.';
        case 404:
          return 'Not found.';
        case 409:
          return 'Conflict.';
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
