import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';

class DeleteDeviceCommand {
  final DeviceId deviceId;

  const DeleteDeviceCommand({required this.deviceId});
}
