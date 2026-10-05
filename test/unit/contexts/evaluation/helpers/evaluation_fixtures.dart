import 'package:mobile/evaluation/domain/model/readmodels/telemetry_evaluation.read_model.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/connectivity.valueobject.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/device_id.valueobject.dart';

/// Deterministic timestamp shared by every evaluation fixture so that no test
/// ever depends on [DateTime.now] or on the wall clock.
const String evaluationRecordedAtIso = '2024-05-01T10:15:30Z';

final DateTime evaluationRecordedAt = DateTime.utc(2024, 5, 1, 10, 15, 30);

/// Well-formed `/evaluations/devices/{id}/latest` payload as it arrives from the
/// backend, used to exercise resource parsing and gateway deserialization.
///
/// Every key is always present so that passing `null` produces an explicit JSON
/// `null`; tests that need a *missing* key remove it from the returned map.
Map<String, dynamic> buildEvaluationJson({
  Object? id = 'eval-1',
  Object? deviceId = 'device-1',
  Object? uptime = 7200,
  Object? connectivity,
  Object? healthStatus = 92,
  Object? status = 'HEALTHY',
  Object? recordedAt = evaluationRecordedAtIso,
}) {
  return <String, dynamic>{
    'id': id,
    'deviceId': deviceId,
    'uptime': uptime,
    'connectivity': connectivity ?? buildConnectivityJson(),
    'healthStatus': healthStatus,
    'status': status,
    'recordedAt': recordedAt,
  };
}

/// Well-formed `connectivity` sub-object.
Map<String, dynamic> buildConnectivityJson({
  Object? status = 'ONLINE',
  Object? network = 'wifi',
  Object? signalStrength = -57,
}) {
  return <String, dynamic>{
    'status': status,
    'network': network,
    'signalStrength': signalStrength,
  };
}

/// Real connectivity value object with realistic dBm values (negative, as
/// produced by Wi-Fi radios).
Connectivity buildConnectivity({
  String status = 'ONLINE',
  String? network = 'wifi',
  int? signalStrength = -57,
}) {
  return Connectivity(
    status: status,
    network: network,
    signalStrength: signalStrength,
  );
}

/// Real read model, the value the query service hands to the devices ACL.
TelemetryEvaluationReadModel buildTelemetryEvaluationReadModel({
  String id = 'eval-1',
  String deviceId = 'device-1',
  int uptimeSeconds = 7200,
  Connectivity? connectivity,
  int healthStatus = 92,
  String status = 'HEALTHY',
  DateTime? recordedAt,
}) {
  return TelemetryEvaluationReadModel(
    id: id,
    deviceId: deviceId,
    uptimeSeconds: uptimeSeconds,
    connectivity: connectivity ?? buildConnectivity(),
    healthStatus: healthStatus,
    status: status,
    recordedAt: recordedAt ?? evaluationRecordedAt,
  );
}

EvaluationDeviceId buildEvaluationDeviceId([String value = 'device-1']) {
  return EvaluationDeviceId(value);
}
