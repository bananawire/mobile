import 'package:mobile/evaluation/domain/model/valueobjects/connectivity.valueobject.dart';

class TelemetryEvaluationReadModel {
  final String id;
  final String deviceId;
  final int uptimeSeconds;
  final Connectivity connectivity;
  final int healthStatus;
  final String status;
  final DateTime recordedAt;

  const TelemetryEvaluationReadModel({
    required this.id,
    required this.deviceId,
    required this.uptimeSeconds,
    required this.connectivity,
    required this.healthStatus,
    required this.status,
    required this.recordedAt,
  });
}
