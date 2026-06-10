class DeviceReadModel {
  final String id;
  final String serialNumber;
  final String name;
  final String status;
  final String? spaceId;
  final String? ownerUserId;
  final Map<String, String> configuration;
  final List<Object?> thresholds;
  final String hardwareId;
  final String deviceType;
  final DateTime? activatedAt;
  final DateTime? lastSeenAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeviceReadModel({
    required this.id,
    required this.serialNumber,
    required this.name,
    required this.status,
    required this.spaceId,
    required this.ownerUserId,
    required this.configuration,
    required this.thresholds,
    required this.hardwareId,
    required this.deviceType,
    required this.activatedAt,
    required this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
