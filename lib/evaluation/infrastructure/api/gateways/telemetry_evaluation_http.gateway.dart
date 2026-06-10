import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/evaluation/infrastructure/api/gateways/telemetry_evaluation.gateway.dart';

class TelemetryEvaluationHttpGateway implements TelemetryEvaluationGateway {
  final Dio _dio;

  TelemetryEvaluationHttpGateway(this._dio);

  @override
  Future<Map<String, dynamic>> getLatestByDeviceRaw(String deviceId) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/evaluations/devices/$deviceId/latest',
    );

    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected latest evaluation response format');
  }
}
