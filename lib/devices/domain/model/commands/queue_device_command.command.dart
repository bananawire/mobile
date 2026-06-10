import 'package:mobile/devices/domain/model/valueobjects/device_command_type.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';

class QueueDeviceCommandCommand {
  final DeviceId deviceId;
  final DeviceCommandType type;
  final String? payload;

  const QueueDeviceCommandCommand({
    required this.deviceId,
    required this.type,
    required this.payload,
  });
}
