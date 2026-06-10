class DeviceResponseResource {
  final String id;
  final String serialNumber;
  final String name;
  final String status;
  final String? spaceId;
  final String? ownerUserId;
  final Map<String, String> configuration;
  final List<dynamic> thresholds;
  final String hardwareId;
  final String deviceType;
  final DateTime? activatedAt;
  final DateTime? lastSeenAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeviceResponseResource({
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

  factory DeviceResponseResource.fromJson(Map<String, dynamic> json) {
    final configRaw = json['configuration'];
    final config = <String, String>{};
    if (configRaw is Map) {
      for (final entry in configRaw.entries) {
        final k = entry.key;
        final v = entry.value;
        if (k is String && v is String) config[k] = v;
      }
    }

    final thresholdsRaw = json['thresholds'];
    final thresholds = <dynamic>[];
    if (thresholdsRaw is List) {
      thresholds.addAll(thresholdsRaw);
    }

    return DeviceResponseResource(
      id: (json['id'] ?? '').toString(),
      serialNumber: (json['serialNumber'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      spaceId: json['spaceId']?.toString(),
      ownerUserId: json['ownerUserId']?.toString(),
      configuration: config,
      thresholds: thresholds,
      hardwareId: (json['hardwareId'] ?? '').toString(),
      deviceType: (json['deviceType'] ?? '').toString(),
      activatedAt: _tryParseDateTime(json['activatedAt']),
      lastSeenAt: _tryParseDateTime(json['lastSeenAt']),
      createdAt: _tryParseDateTime(json['createdAt']),
      updatedAt: _tryParseDateTime(json['updatedAt']),
    );
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
