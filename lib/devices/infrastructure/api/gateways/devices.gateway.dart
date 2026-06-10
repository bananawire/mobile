abstract class DevicesGateway {
  Future<int> getDeviceCountBySpace(String spaceId);

  Future<Map<String, dynamic>> getDevicesBySpaceRaw({
    required String spaceId,
    int page = 0,
    int size = 20,
  });

  Future<Map<String, dynamic>> getDeviceByIdRaw(String deviceId);

  Future<Map<String, dynamic>> getDeviceStatusRaw(String deviceId);

  Future<void> deleteDeviceRaw(String deviceId);

  Future<void> updateDeviceNameRaw(String deviceId, Map<String, dynamic> requestBody);

  Future<Map<String, dynamic>> pairDeviceRaw({
    required Map<String, dynamic> requestBody,
  });

  Future<Map<String, dynamic>> claimDeviceRaw({
    required Map<String, dynamic> requestBody,
  });
}
