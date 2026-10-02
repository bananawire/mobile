import 'package:mobile/evaluation/domain/model/readmodels/telemetry_evaluation.read_model.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/connectivity.valueobject.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceId': deviceId,
    'uptime': uptime,
    'connectivity': connectivity.toJson(),
    'healthStatus': healthStatus,
    'status': status,
    'recordedAt': recordedAt.toIso8601String(),
  };

  TelemetryEvaluationReadModel toDomain() {
    return TelemetryEvaluationReadModel(
      id: id,
      deviceId: deviceId,
      uptimeSeconds: uptime,
      connectivity: connectivity.toDomain(),
      healthStatus: healthStatus,
      status: status,
      recordedAt: recordedAt,
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

  Map<String, dynamic> toJson() => {
    'status': status,
    'network': network,
    'signalStrength': signalStrength,
  };

  Connectivity toDomain() {
    return Connectivity(
      status: status,
      network: network,
      signalStrength: signalStrength,
    );
  }
}

