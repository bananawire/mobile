import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/evaluation/domain/model/queries/get_latest_telemetry_evaluation_by_device.query.dart';
import 'package:mobile/evaluation/domain/model/readmodels/telemetry_evaluation.read_model.dart';

abstract class TelemetryEvaluationQueryService {
  Future<Either<Failure, TelemetryEvaluationReadModel>> handleGetLatestByDevice(
    GetLatestTelemetryEvaluationByDeviceQuery query,
  );
}
