import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/analytics/domain/model/queries/get_dashboard_metrics.query.dart';
import 'package:mobile/analytics/domain/model/queries/get_trends.query.dart';
import 'package:mobile/analytics/domain/model/valueobjects/aqi.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/dashboard_metrics.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/live_telemetry.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/metric_delta.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';
import 'package:mobile/analytics/domain/services/analytics.query-service.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';
import 'package:mobile/devices/domain/model/queries/get_devices_by_space.query.dart';
import 'package:mobile/devices/domain/model/queries/get_spaces_by_organization.query.dart';
import 'package:mobile/devices/domain/model/queries/get_user_organizations.query.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';
import 'package:mobile/devices/domain/services/devices.query-service.dart';
import 'package:mobile/devices/domain/services/organizations.query-service.dart';
import 'package:mobile/devices/domain/services/spaces.query-service.dart';

part 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsQueryService _analytics;
  final OrganizationsQueryService _organizations;
  final SpacesQueryService _spaces;
  final DevicesQueryService _devices;

  Timer? _pollTimer;
  Timer? _secondsTimer;
  StreamSubscription<LiveTelemetry>? _liveSub;

  AnalyticsCubit(
    this._analytics,
    this._organizations,
    this._spaces,
    this._devices,
  ) : super(const AnalyticsState());

  Future<void> load() async {
    _startSecondsCounter();
    await loadOrganizations();
  }

  Future<void> loadOrganizations() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _organizations.handleGetUserOrganizations(
      const GetUserOrganizationsQuery(),
    );
    await result.fold(
      (failure) async {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load organizations. Please try again.',
        ));
      },
      (orgs) async {
        final options = orgs
            .map((o) => AnalyticsSelectOption(id: o.id, name: o.name))
            .toList();
        emit(state.copyWith(organizations: options));
        if (options.isNotEmpty) {
          await selectOrganization(options.first.id);
        } else {
          emit(state.copyWith(isLoading: false));
        }
      },
    );
  }

  Future<void> selectOrganization(String orgId) async {
    _stopPolling();
    emit(state.copyWith(
      selectedOrgId: orgId,
      spaces: const [],
      devices: const [],
      clearSelectedSpaceId: true,
      clearSelectedDeviceId: true,
      clearLiveData: true,
      trendDataPoints: const [],
      liveUnavailable: false,
      liveUnavailableMessage: '',
      isLoading: true,
      clearError: true,
    ));

    final result = await _spaces.handleGetSpacesByOrganization(
      GetSpacesByOrganizationQuery(organizationId: OrganizationId(orgId)),
    );
    await result.fold(
      (failure) async {
        emit(state.copyWith(isLoading: false, errorMessage: 'Failed to load spaces.'));
      },
      (spaces) async {
        final options = spaces
            .map((s) => AnalyticsSelectOption(id: s.id, name: s.name))
            .toList();
        emit(state.copyWith(spaces: options));
        if (options.isNotEmpty) {
          await selectSpace(options.first.id);
        } else {
          emit(state.copyWith(isLoading: false));
        }
      },
    );
  }

  Future<void> selectSpace(String spaceId) async {
    _stopPolling();
    emit(state.copyWith(
      selectedSpaceId: spaceId,
      devices: const [],
      clearSelectedDeviceId: true,
      clearLiveData: true,
      trendDataPoints: const [],
      liveUnavailable: false,
      liveUnavailableMessage: '',
      isLoading: true,
      clearError: true,
    ));

    final result = await _devices.handleGetDevicesBySpace(
      GetDevicesBySpaceQuery(spaceId: SpaceId(spaceId), size: 100),
    );
    await result.fold(
      (failure) async {
        emit(state.copyWith(isLoading: false, errorMessage: 'Failed to load devices.'));
      },
      (page) async {
        final options = page.content
            .map((d) => AnalyticsSelectOption(id: d.id, name: d.name))
            .toList();
        emit(state.copyWith(devices: options));
        if (options.isNotEmpty) {
          await selectDevice(options.first.id);
        } else {
          emit(state.copyWith(isLoading: false));
        }
      },
    );
  }

  Future<void> selectDevice(String deviceId) async {
    _stopPolling();
    emit(state.copyWith(
      selectedDeviceId: deviceId,
      clearLiveData: true,
      trendDataPoints: const [],
      liveUnavailable: false,
      liveUnavailableMessage: '',
    ));
    await fetchData();
    _startPolling();
  }

  /// LIVE / Day / Week / Month — clears any custom range.
  void selectPeriod(String period) {
    _stopPolling();
    emit(state.copyWith(selectedPeriod: period, clearDateRange: true));
    fetchData();
    _startPolling();
  }

  // DATE-RANGE SELECTION DISABLED — analytics is live-stream only.
  // Backend kept for future re-enable; do not delete.
  // void selectCustomRange(DateTime start, DateTime end) {
  //   _stopPolling();
  //   emit(state.copyWith(
  //     selectedPeriod: 'CUSTOM',
  //     startDate: start,
  //     endDate: end,
  //   ));
  //   fetchData();
  //   _startPolling();
  // }

  void selectMetric(String metric) {
    emit(state.copyWith(selectedMetric: metric));
  }

  Future<void> fetchData() async {
    final deviceId = state.selectedDeviceId;
    if (deviceId == null) return;

    emit(state.copyWith(isLoading: true, clearError: true, liveUnavailable: false));

    // DATE-RANGE SELECTION DISABLED — live-stream only, so period is always LIVE.
    // Original date-aware logic kept for future re-enable; do not delete.
    // final period = state.selectedPeriod;
    // final isCustom = period == 'CUSTOM';
    // final startIso = isCustom ? state.startDate?.toUtc().toIso8601String() : null;
    // final endIso = isCustom ? state.endDate?.toUtc().toIso8601String() : null;
    // // Metrics: 'LIVE'/'Day'/'Week'/'Month'; CUSTOM passes null period + dates.
    // final metricsPeriod = isCustom ? null : period;
    // // Trends: LIVE falls back to DAY; CUSTOM null period + dates; else uppercase.
    // final trendPeriod = period == 'LIVE'
    //     ? 'DAY'
    //     : isCustom
    //         ? null
    //         : period.toUpperCase();

    const metricsPeriod = 'LIVE';
    const trendPeriod = 'DAY';
    const startIso = null;
    const endIso = null;

    final metricsFuture = _analytics.handleGetDashboardMetrics(
      GetDashboardMetricsQuery(
        deviceId: deviceId,
        period: metricsPeriod,
        startDate: startIso,
        endDate: endIso,
      ),
    );

    final trendsFuture = _analytics.handleGetTrends(
      GetTrendsQuery(
        deviceId: deviceId,
        period: trendPeriod,
        startDate: startIso,
        endDate: endIso,
      ),
    );

    final metricsResult = await metricsFuture;
    metricsResult.fold(
      (failure) {
        if (failure.statusCode == 404) {
          final deviceName = state.devices
              .firstWhere(
                (d) => d.id == deviceId,
                orElse: () => const AnalyticsSelectOption(id: '', name: 'Device'),
              )
              .name;
          final message = failure.message.replaceAll(deviceId, '"$deviceName"');
          emit(state.copyWith(
            clearLiveData: true,
            liveUnavailable: true,
            liveUnavailableMessage: message,
          ));
        } else {
          emit(state.copyWith(clearLiveData: true));
        }
      },
      (metrics) {
        emit(state.copyWith(liveData: metrics, secondsSinceUpdate: 0));
      },
    );

    final trendsResult = await trendsFuture;
    trendsResult.fold(
      (failure) => emit(state.copyWith(isLoading: false, trendDataPoints: const [])),
      (trends) => emit(state.copyWith(isLoading: false, trendDataPoints: trends)),
    );
  }

  void _startPolling() {
    _stopPolling();
    if (state.selectedDeviceId == null) return;
    // Live-stream only. Historical/custom 30s polling disabled (kept for re-enable).
    _startLiveStream();
    // if (state.selectedPeriod == 'LIVE') {
    //   _startLiveStream();
    // } else {
    //   // Historical / custom: periodic re-fetch.
    //   _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => fetchData());
    // }
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _liveSub?.cancel();
    _liveSub = null;
  }

  void _startLiveStream() {
    final deviceId = state.selectedDeviceId;
    if (deviceId == null) return;

    _liveSub?.cancel();
    _liveSub = _analytics.handleStreamLiveTelemetry(deviceId).listen(_onTelemetry);
  }

  void _onTelemetry(LiveTelemetry t) {
    // Live stream carries raw pollutants; derive AQI like the web app.
    final aqi = calculateAqiFromPm25(t.pm2_5);
    final prev = state.liveData;

    final merged = DashboardMetrics(
      aqi: Aqi(aqi.value, aqi.category),
      co2: MetricDelta(t.co2, prev?.co2.deltaPercentage),
      pm2_5: MetricDelta(t.pm2_5, prev?.pm2_5.deltaPercentage),
      temperature: MetricDelta(t.temperature, prev?.temperature.deltaPercentage),
      humidity: MetricDelta(t.humidity, prev?.humidity.deltaPercentage),
      calculatedAt: t.timestamp,
    );

    final newPoint = TrendPoint(
      timestamp: t.timestamp,
      aqiValue: aqi.value,
      co2: t.co2,
      pm2_5: t.pm2_5,
      temperature: t.temperature,
      humidity: t.humidity,
    );

    final existing = state.trendDataPoints;
    final List<TrendPoint> points;
    if (existing.isNotEmpty) {
      final limit = math.max(30, existing.length);
      final appended = [...existing, newPoint];
      points = appended.length > limit
          ? appended.sublist(appended.length - limit)
          : appended;
    } else {
      points = [newPoint];
    }

    emit(state.copyWith(
      liveData: merged,
      trendDataPoints: points,
      liveUnavailable: false,
      isLoading: false,
      secondsSinceUpdate: 0,
    ));
  }

  void _startSecondsCounter() {
    _secondsTimer?.cancel();
    _secondsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.liveData == null) return;
      emit(state.copyWith(secondsSinceUpdate: state.secondsSinceUpdate + 1));
    });
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _secondsTimer?.cancel();
    _liveSub?.cancel();
    return super.close();
  }
}
