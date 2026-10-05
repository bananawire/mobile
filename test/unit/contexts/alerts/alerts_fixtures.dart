import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_page.resource.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_response.resource.dart';
import 'package:mobile/alerts/interfaces/rest/resources/daily_alert_summary.resource.dart';

/// Shared fixtures for the alerts bounded context.
///
/// This helper is intentionally NOT named `*_test.dart` so that the test
/// runner never executes it as a suite.

/// A fully populated alert JSON payload as the backend would send it.
Map<String, dynamic> alertJson({
  Object? id = 'alert-1',
  Object? deviceId = 'device-1',
  Object? spaceId = 'space-1',
  Object? spaceName = 'Living room',
  Object? deviceName = 'Sensor A',
  Object? metric = 'PM25',
  Object? metricLabel = 'PM2.5',
  Object? metricUnit = 'µg/m³',
  Object? thresholdValue = 35,
  Object? actualValue = 52,
  Object? message = 'PM2.5 above threshold',
  Object? status = 'ACTIVE',
  Object? severity = 'CRITICAL',
  Object? occurredAt = '2024-05-01T10:30:00Z',
  Object? resolvedAt,
  Object? createdAt = '2024-05-01T10:31:00Z',
}) {
  return <String, dynamic>{
    'id': id,
    'deviceId': deviceId,
    'spaceId': spaceId,
    'spaceName': spaceName,
    'deviceName': deviceName,
    'metric': metric,
    'metricLabel': metricLabel,
    'metricUnit': metricUnit,
    'thresholdValue': thresholdValue,
    'actualValue': actualValue,
    'message': message,
    'status': status,
    'severity': severity,
    'occurredAt': occurredAt,
    'resolvedAt': ?resolvedAt,
    'createdAt': createdAt,
  };
}

/// A complete alert JSON payload including the optional `resolvedAt`.
Map<String, dynamic> resolvedAlertJson({
  String id = 'alert-2',
  String deviceId = 'device-2',
  String spaceId = 'space-2',
  String spaceName = 'Bedroom',
  String deviceName = 'Sensor B',
  String metric = 'TEMPERATURE',
  String metricLabel = 'Temperature',
  String metricUnit = '°C',
  int thresholdValue = 30,
  int actualValue = 33,
  String message = 'Temperature above threshold',
  String status = 'RESOLVED',
  String severity = 'WARNING',
  String occurredAt = '2024-05-02T08:00:00Z',
  String resolvedAt = '2024-05-02T09:15:00Z',
  String createdAt = '2024-05-02T08:01:00Z',
}) {
  return alertJson(
    id: id,
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

/// A Spring `Page` shaped wrapper around [content].
Map<String, dynamic> alertPageJson({
  List<Map<String, dynamic>> content = const [],
  Object? totalElements,
  Object? totalPages,
  Object? size,
  Object? number,
}) {
  return <String, dynamic>{
    'content': content,
    'totalElements': totalElements ?? content.length,
    'totalPages': totalPages ?? 1,
    'size': size ?? 20,
    'number': number ?? 0,
  };
}

/// Empty page wrapper as returned by the backend when there is nothing to show.
const Map<String, dynamic> emptyAlertPageJson = <String, dynamic>{
  'content': <dynamic>[],
  'totalElements': 0,
  'totalPages': 0,
  'size': 20,
  'number': 0,
};

/// A realistic [AlertResponseResource].
AlertResponseResource buildAlertResource({
  String id = 'alert-1',
  String deviceId = 'device-1',
  String? spaceId = 'space-1',
  String? spaceName = 'Living room',
  String? deviceName = 'Sensor A',
  String metric = 'PM25',
  String metricLabel = 'PM2.5',
  String metricUnit = 'µg/m³',
  num thresholdValue = 35,
  num actualValue = 52,
  String message = 'PM2.5 above threshold',
  String status = 'ACTIVE',
  String severity = 'CRITICAL',
  String occurredAt = '2024-05-01T10:30:00Z',
  String? resolvedAt,
  String createdAt = '2024-05-01T10:31:00Z',
}) {
  return AlertResponseResource(
    id: id,
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

/// A page resource wrapping [content] with pagination metadata.
AlertPageResource buildAlertPageResource({
  List<AlertResponseResource> content = const [],
  int totalElements = 0,
  int totalPages = 1,
  int size = 20,
  int number = 0,
}) {
  return AlertPageResource(
    content: content,
    totalElements: totalElements,
    totalPages: totalPages,
    size: size,
    number: number,
  );
}

/// A realistic [Alert] domain object.
Alert buildAlert({
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
  String occurredAt = '2024-05-01T10:30:00Z',
  String? resolvedAt,
  String createdAt = '2024-05-01T10:31:00Z',
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

/// A realistic daily summary resource.
DailyAlertSummaryResource buildDailySummaryResource({
  String date = '2024-05-01',
  num count = 3,
}) {
  return DailyAlertSummaryResource(date: date, count: count);
}