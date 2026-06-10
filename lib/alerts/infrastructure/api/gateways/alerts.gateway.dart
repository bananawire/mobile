  import 'package:mobile/alerts/interfaces/rest/resources/alert_page.resource.dart';
  import 'package:mobile/alerts/interfaces/rest/resources/daily_alert_summary.resource.dart';

  abstract class AlertsGateway {
    Future<AlertPageResource> getAlerts({
      required int page,
      required int size,
      List<String>? status,
    });

    Future<AlertPageResource> getAlertsByDevice({
      required String deviceId,
      required int page,
      required int size,
      List<String>? status,
    });

    Future<AlertPageResource> getAlertsBySpace({
      required String spaceId,
      required int page,
      required int size,
      List<String>? status,
    });

    Future<List<DailyAlertSummaryResource>> getCurrentUserDailyAlertSummary({
      required int days,
    });

    Future<List<DailyAlertSummaryResource>> getDailyAlertSummary({
      required String spaceId,
      required int days,
    });
  }
