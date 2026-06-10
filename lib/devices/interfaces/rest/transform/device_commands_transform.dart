import 'package:mobile/devices/domain/model/commands/queue_device_command.command.dart';
import 'package:mobile/devices/interfaces/rest/resources/create_device_command_request.resource.dart';

CreateDeviceCommandRequestResource toCreateDeviceCommandRequestResource(
  QueueDeviceCommandCommand command,
) {
  return CreateDeviceCommandRequestResource(
    type: command.type,
    payload: command.payload,
  );
}
