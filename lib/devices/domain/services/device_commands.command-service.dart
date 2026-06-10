import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/queue_device_command.command.dart';
import 'package:mobile/devices/domain/model/readmodels/device_command.read_model.dart';

abstract class DeviceCommandsCommandService {
  Future<Either<Failure, DeviceCommandReadModel>> handleQueueDeviceCommand(
    QueueDeviceCommandCommand command,
  );
}
