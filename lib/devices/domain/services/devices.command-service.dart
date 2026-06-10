import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/claim_device_to_space.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_device.command.dart';
import 'package:mobile/devices/domain/model/commands/pair_device.command.dart';
import 'package:mobile/devices/domain/model/commands/update_device_name.command.dart';
import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/device_pairing.read_model.dart';

abstract class DevicesCommandService {
  Future<Either<Failure, DevicePairingReadModel>> handlePairDevice(PairDeviceCommand command);

  Future<Either<Failure, DeviceReadModel>> handleClaimDeviceToSpace(
    ClaimDeviceToSpaceCommand command,
  );

  Future<Either<Failure, void>> handleDeleteDevice(DeleteDeviceCommand command);

  Future<Either<Failure, void>> handleUpdateDeviceName(UpdateDeviceNameCommand command);
}
