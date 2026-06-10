import 'package:mobile/analytics/domain/model/valueobjects/live_telemetry.valueobject.dart';
import 'package:mobile/analytics/interfaces/rest/resources/dashboard_metrics.resource.dart';
import 'package:mobile/analytics/interfaces/rest/resources/trends.resource.dart';

abstract class AnalyticsGateway {
  Future<DashboardMetricsResource> getDashboardMetrics({
    required String deviceId,
    String? period,
    String? startDate,
    String? endDate,
  });

  Future<TrendsResource> getTrends({
    required String deviceId,
    String? period,
    String? startDate,
    String? endDate,
  });

  /// Server-Sent Events stream of live telemetry for a device.
  /// Cancelling the subscription closes the underlying SSE connection.
  Stream<LiveTelemetry> streamLiveTelemetry(String deviceId);
}
