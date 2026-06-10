import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';

class GetDeviceStatusQuery {
  final DeviceId deviceId;

  const GetDeviceStatusQuery({required this.deviceId});
}
