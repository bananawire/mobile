class TelemetryEvaluationResponseResource {
  final String id;
  final String deviceId;
  final int uptime;
  final ConnectivityResponseResource connectivity;
  final int healthStatus;
  final String status;
  final DateTime recordedAt;

  const TelemetryEvaluationResponseResource({
    required this.id,
    required this.deviceId,
    required this.uptime,
    required this.connectivity,
    required this.healthStatus,
    required this.status,
    required this.recordedAt,
  });

  factory TelemetryEvaluationResponseResource.fromJson(Map<String, dynamic> json) {
    return TelemetryEvaluationResponseResource(
      id: (json['id'] ?? '').toString(),
      deviceId: (json['deviceId'] ?? '').toString(),
      uptime: _asInt(json['uptime']),
      connectivity: ConnectivityResponseResource.fromJson(
        (json['connectivity'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{},
      ),
      healthStatus: _asInt(json['healthStatus']),
      status: (json['status'] ?? '').toString(),
      recordedAt: DateTime.parse((json['recordedAt'] ?? '').toString()),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ConnectivityResponseResource {
  final String status;
  final String? network;
  final int? signalStrength;

  const ConnectivityResponseResource({
    required this.status,
    required this.network,
    required this.signalStrength,
  });

  factory ConnectivityResponseResource.fromJson(Map<String, dynamic> json) {
    final ss = json['signalStrength'];
    final signalStrength = ss is int ? ss : (ss is num ? ss.toInt() : int.tryParse(ss?.toString() ?? ''));
    return ConnectivityResponseResource(
      status: (json['status'] ?? '').toString(),
      network: json['network']?.toString(),
      signalStrength: signalStrength,
    );
  }
}
