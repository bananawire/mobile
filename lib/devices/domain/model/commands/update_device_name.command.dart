import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_name.valueobject.dart';

class UpdateDeviceNameCommand {
  final DeviceId deviceId;
  final DeviceName name;

  const UpdateDeviceNameCommand({
    required this.deviceId,
    required this.name,
  });
}
