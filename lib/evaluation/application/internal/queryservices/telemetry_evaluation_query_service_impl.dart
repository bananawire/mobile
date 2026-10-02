import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/evaluation/domain/model/queries/get_latest_telemetry_evaluation_by_device.query.dart';
import 'package:mobile/evaluation/domain/model/readmodels/telemetry_evaluation.read_model.dart';
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
      return Right(resource.toDomain());
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  Failure _mapError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      String? serverMessage;
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        serverMessage = data['message'].toString();
      }
      return Failure(
        serverMessage ?? error.message ?? 'An unexpected error occurred',
        statusCode: status,
      );
    }
    if (error is Exception) {
      return Failure(error.toString().replaceFirst('Exception: ', ''));
    }
    return const Failure('An unexpected error occurred');
  }
}
