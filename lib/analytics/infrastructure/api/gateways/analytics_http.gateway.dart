import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eventflux/eventflux.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:mobile/analytics/domain/model/valueobjects/live_telemetry.valueobject.dart';
import 'package:mobile/analytics/infrastructure/api/gateways/analytics.gateway.dart';
import 'package:mobile/analytics/interfaces/rest/resources/dashboard_metrics.resource.dart';
import 'package:mobile/analytics/interfaces/rest/resources/trends.resource.dart';

class AnalyticsHttpGateway implements AnalyticsGateway {
  final Dio _dio;
  final TokenLocalStorage _tokenStorage;

  AnalyticsHttpGateway(this._dio, this._tokenStorage);

  static const String _path = '${ApiConstants.apiPrefix}/analytics';

  @override
  Future<DashboardMetricsResource> getDashboardMetrics({
    required String deviceId,
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    // Decide /live vs /historical, mirroring the web gateway.
    final isLive = period == null || period.toUpperCase() == 'LIVE';
    final endpoint = isLive ? 'live' : 'historical';

    final params = <String, dynamic>{};
    if (period != null && !isLive) params['period'] = period;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _dio.get(
      '$_path/devices/$deviceId/$endpoint',
      queryParameters: params.isEmpty ? null : params,
    );
    return DashboardMetricsResource.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TrendsResource> getTrends({
    required String deviceId,
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, dynamic>{};
    if (period != null) params['period'] = period;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _dio.get(
      '$_path/devices/$deviceId/trends',
      queryParameters: params.isEmpty ? null : params,
    );
    return TrendsResource.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Stream<LiveTelemetry> streamLiveTelemetry(String deviceId) {
    final flux = EventFlux.spawn();
    final controller = StreamController<LiveTelemetry>();

    controller.onCancel = () async {
      await flux.disconnect();
    };

    Future<void> open() async {
      final token = await _tokenStorage.getAccessToken();
      final url = '${ApiConstants.baseUrl}$_path/devices/$deviceId/live/stream';

      flux.connect(
        EventFluxConnectionType.get,
        url,
        header: {
          'Accept': 'text/event-stream',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        autoReconnect: true,
        reconnectConfig: ReconnectConfig(
          mode: ReconnectMode.linear,
          interval: const Duration(seconds: 3),
          maxAttempts: -1, // unlimited
          reconnectHeader: () async {
            final t = await _tokenStorage.getAccessToken();
            return {
              'Accept': 'text/event-stream',
              if (t != null && t.isNotEmpty) 'Authorization': 'Bearer $t',
            };
          },
        ),
        onSuccessCallback: (response) {
          response?.stream?.listen((event) {
            // Backend emits named 'telemetry' events; ignore 'connected' heartbeats.
            if (event.event.isNotEmpty && event.event != 'telemetry') return;
            final raw = event.data.trim();
            if (raw.isEmpty) return;
            try {
              final json = jsonDecode(raw) as Map<String, dynamic>;
              if (!controller.isClosed) {
                controller.add(LiveTelemetry.fromJson(json, deviceId));
              }
            } catch (_) {
              // Skip malformed frames; reconnect loop keeps the stream alive.
            }
          });
        },
        onError: (_) {
          // Swallow; autoReconnect handles recovery.
        },
      );
    }

    open();
    return controller.stream;
  }
}
