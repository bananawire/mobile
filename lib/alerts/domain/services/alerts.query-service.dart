import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';

import '../model/queries/get_alerts.query.dart';
import '../model/queries/get_alerts_by_device.query.dart';
import '../model/queries/get_alerts_by_space.query.dart';
import '../model/queries/get_alerts_daily_summary.query.dart';

import '../model/valueobjects/alert_page.valueobject.dart';
import '../model/valueobjects/alert_status.valueobject.dart';
import '../model/valueobjects/daily_alert_count.valueobject.dart';

abstract class AlertsQueryService {
  Future<Either<Failure, AlertPage>> handleGetAlerts(
    GetAlertsQuery query, {
    List<AlertStatus>? status,
  });

  Future<Either<Failure, AlertPage>> handleGetAlertsByDevice(
    GetAlertsByDeviceQuery query, {
    List<AlertStatus>? status,
  });

  Future<Either<Failure, AlertPage>> handleGetAlertsBySpace(
    GetAlertsBySpaceQuery query, {
    List<AlertStatus>? status,
  });

  Future<Either<Failure, List<DailyAlertCount>>> handleGetDailySummary(
    GetAlertDailySummaryQuery query,
  );

  Future<Either<Failure, List<DailyAlertCount>>> handleGetDailySummaryBySpace(
    String spaceId,
    int days,
  );
}
