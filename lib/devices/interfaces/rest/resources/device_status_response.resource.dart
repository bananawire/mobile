class DeviceStatusResponseResource {
  final String deviceId;
  final String status;
  final DateTime? lastSeenAt;

  const DeviceStatusResponseResource({
    required this.deviceId,
    required this.status,
    required this.lastSeenAt,
  });

  factory DeviceStatusResponseResource.fromJson(Map<String, dynamic> json) {
    return DeviceStatusResponseResource(
      deviceId: (json['deviceId'] ?? json['id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      lastSeenAt: _tryParseDateTime(json['lastSeenAt']),
    );
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
