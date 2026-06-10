import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/evaluation/domain/model/queries/get_latest_telemetry_evaluation_by_device.query.dart';
import 'package:mobile/evaluation/domain/model/readmodels/telemetry_evaluation.read_model.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/connectivity.valueobject.dart';
import 'package:mobile/evaluation/domain/services/telemetry_evaluation.query-service.dart';
import 'package:mobile/evaluation/infrastructure/api/gateways/telemetry_evaluation.gateway.dart';
import 'package:mobile/evaluation/interfaces/rest/resources/telemetry_evaluation_response.resource.dart';

class TelemetryEvaluationQueryServiceImpl implements TelemetryEvaluationQueryService {
  final TelemetryEvaluationGateway _gateway;

  TelemetryEvaluationQueryServiceImpl(this._gateway);

  @override
  Future<Either<Failure, TelemetryEvaluationReadModel>> handleGetLatestByDevice(
    GetLatestTelemetryEvaluationByDeviceQuery query,
  ) async {
    try {
      final raw = await _gateway.getLatestByDeviceRaw(query.deviceId.value);
      final resource = TelemetryEvaluationResponseResource.fromJson(raw);
      return Right(
        TelemetryEvaluationReadModel(
          id: resource.id,
          deviceId: resource.deviceId,
          uptimeSeconds: resource.uptime,
          connectivity: Connectivity(
            status: resource.connectivity.status,
            network: resource.connectivity.network,
            signalStrength: resource.connectivity.signalStrength,
          ),
          healthStatus: resource.healthStatus,
          status: resource.status,
          recordedAt: resource.recordedAt,
        ),
      );
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  String _mapError(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
