import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/queue_device_command.command.dart';
import 'package:mobile/devices/domain/model/readmodels/device_command.read_model.dart';
import 'package:mobile/devices/domain/services/device_commands.command-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_commands.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_command_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/transform/device_commands_transform.dart';

class DeviceCommandsCommandServiceImpl implements DeviceCommandsCommandService {
  final DeviceCommandsGateway _gateway;

  DeviceCommandsCommandServiceImpl(this._gateway);

  @override
  Future<Either<Failure, DeviceCommandReadModel>> handleQueueDeviceCommand(
    QueueDeviceCommandCommand command,
  ) async {
    try {
      final req = toCreateDeviceCommandRequestResource(command);
      final raw = await _gateway.createDeviceCommandRaw(
        deviceId: command.deviceId.value,
        requestBody: req.toJson(),
      );
      final resource = DeviceCommandResponseResource.fromJson(raw);
      final type = resource.typeAsEnum ?? command.type;
      return Right(
        DeviceCommandReadModel(
          id: resource.id,
          deviceId: resource.deviceId,
          type: type,
          status: resource.status,
          payload: resource.payload,
          sentAt: resource.sentAt,
          executedAt: resource.executedAt,
          failureReason: resource.failureReason,
          createdAt: resource.createdAt,
        ),
      );
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  String _mapError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      switch (statusCode) {
        case 400:
          return 'Invalid command request.';
        case 401:
          return 'Session expired. Please sign in again.';
        case 403:
          return 'Access denied.';
        case 404:
          return 'Device not found.';
        case 409:
          return 'Conflict.';
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
