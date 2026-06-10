import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/analytics/domain/model/queries/get_dashboard_metrics.query.dart';
import 'package:mobile/analytics/domain/model/queries/get_trends.query.dart';
import 'package:mobile/analytics/domain/model/valueobjects/dashboard_metrics.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/live_telemetry.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';

abstract class AnalyticsQueryService {
  Future<Either<Failure, DashboardMetrics>> handleGetDashboardMetrics(
    GetDashboardMetricsQuery query,
  );

  Future<Either<Failure, List<TrendPoint>>> handleGetTrends(GetTrendsQuery query);

  /// Live telemetry SSE stream. Cancel the subscription to close the connection.
  Stream<LiveTelemetry> handleStreamLiveTelemetry(String deviceId);
}
