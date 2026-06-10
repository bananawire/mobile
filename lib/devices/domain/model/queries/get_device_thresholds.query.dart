class GetDeviceThresholdsQuery {
  final String deviceId;

  GetDeviceThresholdsQuery({required this.deviceId}) {
    if (deviceId.trim().isEmpty) {
      throw ArgumentError('deviceId cannot be empty');
    }
  }
}