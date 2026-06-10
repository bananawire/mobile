class AlertResponseResource {
  final String id;
  final String deviceId;
  final String? spaceId;
  final String? spaceName;
  final String? deviceName;
  final String metric;
  final String metricLabel;
  final String metricUnit;
  final num thresholdValue;
  final num actualValue;
  final String message;
  final String status;
  final String severity;
  final String occurredAt;
  final String? resolvedAt;
  final String createdAt;

  AlertResponseResource({
    required this.id,
    required this.deviceId,
    this.spaceId,
    this.spaceName,
    this.deviceName,
    required this.metric,
    required this.metricLabel,
    required this.metricUnit,
    required this.thresholdValue,
    required this.actualValue,
    required this.message,
    required this.status,
    required this.severity,
    required this.occurredAt,
    this.resolvedAt,
    required this.createdAt,
  });

  factory AlertResponseResource.fromJson(
      Map<String, dynamic> json,
      ) {
    return AlertResponseResource(
      id: (json['id'] ?? '').toString(),
      deviceId: (json['deviceId'] ?? '').toString(),
      spaceId: json['spaceId']?.toString(),
      spaceName: json['spaceName']?.toString(),
      deviceName: json['deviceName']?.toString(),
      metric: (json['metric'] ?? '').toString(),
      metricLabel: (json['metricLabel'] ?? '').toString(),
      metricUnit: (json['metricUnit'] ?? '').toString(),
      thresholdValue: _toNum(json['thresholdValue']),
      actualValue: _toNum(json['actualValue']),
      message: (json['message'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      severity: (json['severity'] ?? '').toString(),
      occurredAt: (json['occurredAt'] ?? '').toString(),
      resolvedAt: json['resolvedAt']?.toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }

  static num _toNum(Object? value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}
