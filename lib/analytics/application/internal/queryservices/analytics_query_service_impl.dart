import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/analytics/domain/model/queries/get_dashboard_metrics.query.dart';
import 'package:mobile/analytics/domain/model/queries/get_trends.query.dart';
import 'package:mobile/analytics/domain/model/valueobjects/dashboard_metrics.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/live_telemetry.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';
import 'package:mobile/analytics/domain/services/analytics.query-service.dart';
import 'package:mobile/analytics/infrastructure/api/gateways/analytics.gateway.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_transform.dart';

class AnalyticsQueryServiceImpl implements AnalyticsQueryService {
  final AnalyticsGateway _gateway;

  AnalyticsQueryServiceImpl(this._gateway);

  @override
  Future<Either<Failure, DashboardMetrics>> handleGetDashboardMetrics(
    GetDashboardMetricsQuery query,
  ) async {
    try {
      final resource = await _gateway.getDashboardMetrics(
        deviceId: query.deviceId,
        period: query.period,
        startDate: query.startDate,
        endDate: query.endDate,
      );
      return Right(dashboardMetricsResourceToDomain(resource));
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (_) {
      return const Left(Failure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<TrendPoint>>> handleGetTrends(GetTrendsQuery query) async {
    try {
      final resource = await _gateway.getTrends(
        deviceId: query.deviceId,
        period: query.period,
        startDate: query.startDate,
        endDate: query.endDate,
      );
      return Right(resource.dataPoints.map(trendDataPointResourceToDomain).toList());
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (_) {
      return const Left(Failure('An unexpected error occurred'));
    }
  }

  @override
  Stream<LiveTelemetry> handleStreamLiveTelemetry(String deviceId) {
    return _gateway.streamLiveTelemetry(deviceId);
  }

  Failure _mapError(DioException error) {
    final status = error.response?.statusCode;
    String? serverMessage;
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      serverMessage = data['message'].toString();
    }
    if (status == 404) {
      return Failure(
        serverMessage ?? 'Live data is not available right now.',
        statusCode: 404,
      );
    }
    return Failure(
      serverMessage ?? error.message ?? 'An unexpected error occurred',
      statusCode: status,
    );
  }
}
