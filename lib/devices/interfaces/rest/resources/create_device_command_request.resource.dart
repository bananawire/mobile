import 'package:mobile/devices/domain/model/valueobjects/device_command_type.valueobject.dart';

class CreateDeviceCommandRequestResource {
  final DeviceCommandType type;
  final String? payload;

  const CreateDeviceCommandRequestResource({
    required this.type,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.apiValue,
      'payload': payload,
    };
  }
}
