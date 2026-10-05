import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_device.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_space.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_daily_summary.query.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_page.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/daily_alert_count.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';
import 'package:mobile/alerts/domain/services/alerts.query-service.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

/// Wraps [child] with the localization harness required by every alerts
/// widget, because they all read `AppLocalizations.of(context)!`.
Widget alertsTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

/// A hand written double of [AlertsQueryService] used by the alerts widget
/// tests. It records the status filters requested by the cubit so that screen
/// behaviour can be asserted without mocking the cubit itself.
class FakeAlertsQueryService implements AlertsQueryService {
  FakeAlertsQueryService({
    this.alertsResult = const Right<Failure, AlertPage>(_emptyPage),
    this.summaryResult =
        const Right<Failure, List<DailyAlertCount>>(<DailyAlertCount>[]),
    this.spaceAlertsResult = const Right<Failure, AlertPage>(_emptyPage),
    this.spaceSummaryResult =
        const Right<Failure, List<DailyAlertCount>>(<DailyAlertCount>[]),
  });

  static const AlertPage _emptyPage = AlertPage(
    content: <Alert>[],
    totalElements: 0,
    totalPages: 0,
    size: 20,
    number: 0,
  );

  Either<Failure, AlertPage> alertsResult;
  Either<Failure, List<DailyAlertCount>> summaryResult;
  Either<Failure, AlertPage> spaceAlertsResult;
  Either<Failure, List<DailyAlertCount>> spaceSummaryResult;

  /// Status filters received by every alert page call, in order.
  final List<List<AlertStatus>?> requestedStatusFilters =
      <List<AlertStatus>?>[];

  /// Pagination queries received by the current user alert call, in order.
  final List<GetAlertsQuery> requestedQueries = <GetAlertsQuery>[];

  int alertsCalls = 0;
  int summaryCalls = 0;
  int spaceAlertsCalls = 0;
  int spaceSummaryCalls = 0;

  @override
  Future<Either<Failure, AlertPage>> handleGetAlerts(
    GetAlertsQuery query, {
    List<AlertStatus>? status,
  }) async {
    alertsCalls++;
    requestedQueries.add(query);
    requestedStatusFilters.add(status);
    return alertsResult;
  }

  @override
  Future<Either<Failure, AlertPage>> handleGetAlertsByDevice(
    GetAlertsByDeviceQuery query, {
    List<AlertStatus>? status,
  }) async {
    spaceAlertsCalls++;
    requestedStatusFilters.add(status);
    return spaceAlertsResult;
  }

  @override
  Future<Either<Failure, AlertPage>> handleGetAlertsBySpace(
    GetAlertsBySpaceQuery query, {
    List<AlertStatus>? status,
  }) async {
    spaceAlertsCalls++;
    requestedStatusFilters.add(status);
    return spaceAlertsResult;
  }

  @override
  Future<Either<Failure, List<DailyAlertCount>>> handleGetDailySummary(
    GetAlertDailySummaryQuery query,
  ) async {
    summaryCalls++;
    return summaryResult;
  }

  @override
  Future<Either<Failure, List<DailyAlertCount>>> handleGetDailySummaryBySpace(
    String spaceId,
    int days,
  ) async {
    spaceSummaryCalls++;
    return spaceSummaryResult;
  }
}
/// Builds a realistic [Alert] for the alerts widget tests.
Alert buildTestAlert({
  String id = 'alert-1',
  String deviceId = 'device-1',
  String? spaceId = 'space-1',
  String? spaceName = 'Living room',
  String? deviceName = 'Sensor A',
  MetricType metric = MetricType.pm25,
  String metricLabel = 'PM2.5',
  String metricUnit = 'µg/m³',
  double thresholdValue = 35,
  double actualValue = 52,
  String message = 'PM2.5 above threshold',
  AlertStatus status = AlertStatus.active,
  AlertSeverity severity = AlertSeverity.critical,
  String occurredAt = '2024-05-01T10:30:00',
  String? resolvedAt,
  String createdAt = '2024-05-01T10:31:00',
}) {
  return Alert(
    id: AlertId(id),
    deviceId: deviceId,
    spaceId: spaceId,
    spaceName: spaceName,
    deviceName: deviceName,
    metric: metric,
    metricLabel: metricLabel,
    metricUnit: metricUnit,
    thresholdValue: thresholdValue,
    actualValue: actualValue,
    message: message,
    status: status,
    severity: severity,
    occurredAt: occurredAt,
    resolvedAt: resolvedAt,
    createdAt: createdAt,
  );
}

/// Builds a page holding [alerts].
AlertPage buildTestPage(
  List<Alert> alerts, {
  int totalElements = 0,
  int totalPages = 1,
  int size = 20,
  int number = 0,
}) {
  return AlertPage(
    content: alerts,
    totalElements: totalElements,
    totalPages: totalPages,
    size: size,
    number: number,
  );
}
