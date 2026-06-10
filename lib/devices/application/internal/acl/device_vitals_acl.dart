import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/evaluation/domain/model/queries/get_latest_telemetry_evaluation_by_device.query.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/evaluation/domain/services/telemetry_evaluation.query-service.dart';

class DeviceVitalsSnapshot {
  final double connectivityDbm;
  final int uptimeHours;
  final double deviceHealthPercent;
  final int lastUpdateHours;

  const DeviceVitalsSnapshot({
    required this.connectivityDbm,
    required this.uptimeHours,
    required this.deviceHealthPercent,
    required this.lastUpdateHours,
  });
}

/// ACL from Devices -> Evaluation bounded context.
/// Converts evaluation telemetry snapshot into the UI vitals required by Devices screens.
class DeviceVitalsAcl {
  final TelemetryEvaluationQueryService _evaluationQueryService;

  DeviceVitalsAcl(this._evaluationQueryService);

  Future<Either<Failure, DeviceVitalsSnapshot>> fetchLatestVitals(DeviceId deviceId) async {
    final result = await _evaluationQueryService.handleGetLatestByDevice(
      GetLatestTelemetryEvaluationByDeviceQuery(
        deviceId: EvaluationDeviceId(deviceId.value),
      ),
    );

    return result.map((eval) {
      final signal = eval.connectivity.signalStrength;
      final connectivityDbm = (signal ?? 0).toDouble();
      final uptimeHours = (eval.uptimeSeconds ~/ 3600);
      final health = eval.healthStatus.clamp(0, 100).toDouble();
      final lastUpdateHours = _hoursSince(eval.recordedAt);
      return DeviceVitalsSnapshot(
        connectivityDbm: connectivityDbm,
        uptimeHours: uptimeHours,
        deviceHealthPercent: health,
        lastUpdateHours: lastUpdateHours,
      );
    });
  }

  int _hoursSince(DateTime recordedAt) {
    final diff = DateTime.now().difference(recordedAt).inHours;
    if (diff < 0) return 0;
    return diff;
  }
}
