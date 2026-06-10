abstract class DeviceCommandsGateway {
  Future<Map<String, dynamic>> createDeviceCommandRaw({
    required String deviceId,
    required Map<String, dynamic> requestBody,
  });
}
