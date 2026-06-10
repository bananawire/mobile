class GetAlertsByDeviceQuery {
  final String deviceId;
  final int page;
  final int size;

  GetAlertsByDeviceQuery({
    required this.deviceId,
    this.page = 0,
    this.size = 20,
  }) {
    if (deviceId.trim().isEmpty) {
      throw ArgumentError('deviceId cannot be empty');
    }

    if (page < 0) {
      throw ArgumentError('page must be >= 0');
    }

    if (size < 1 || size > 100) {
      throw ArgumentError('size must be between 1 and 100');
    }
  }
}
