import 'package:mobile/devices/domain/model/commands/claim_device_to_space.command.dart';
import 'package:mobile/devices/domain/model/commands/pair_device.command.dart';
import 'package:mobile/devices/interfaces/rest/resources/claim_device_request.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/pair_device_request.resource.dart';

PairDeviceRequestResource toPairDeviceRequestResource(PairDeviceCommand command) {
  return PairDeviceRequestResource(hardwareId: command.hardwareId.value);
}

ClaimDeviceRequestResource toClaimDeviceRequestResource(ClaimDeviceToSpaceCommand command) {
  return ClaimDeviceRequestResource(
    claimToken: command.claimToken.value,
    spaceId: command.spaceId.value,
  );
}
