import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/write_device_threshold.command.dart';
import 'package:mobile/devices/domain/model/commands/remove_device_threshold.command.dart';
import 'package:mobile/devices/domain/model/readmodels/device_threshold.read_model.dart';

abstract class DeviceThresholdCommandService {
  Future<Either<Failure, DeviceThresholdReadModel>> handleWriteThreshold(
    WriteDeviceThresholdCommand command,
  );

  Future<Either<Failure, void>> handleRemoveThreshold(
    RemoveDeviceThresholdCommand command,
  );
}
