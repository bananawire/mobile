class DeviceStatusReadModel {
  final String deviceId;
  final String status;
  final DateTime? lastSeenAt;

  const DeviceStatusReadModel({
    required this.deviceId,
    required this.status,
    required this.lastSeenAt,
  });
}
