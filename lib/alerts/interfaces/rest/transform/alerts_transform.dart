import 'package:mobile/alerts/domain/model/valueobjects/alert.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_page.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/daily_alert_count.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';

import '../resources/alert_page.resource.dart';
import '../resources/alert_response.resource.dart';
import '../resources/daily_alert_summary.resource.dart';

Alert alertResponseResourceToDomain(
    AlertResponseResource resource,
    ) {
  return Alert(
    id: AlertId(resource.id),
    deviceId: resource.deviceId,
    spaceId: resource.spaceId,
    spaceName: resource.spaceName,
    deviceName: resource.deviceName,
    metric: MetricType.fromString(resource.metric) ?? MetricType.pm25,
    metricLabel: resource.metricLabel,
    metricUnit: resource.metricUnit,
    thresholdValue: resource.thresholdValue.toDouble(),
    actualValue: resource.actualValue.toDouble(),
    message: resource.message,
    status: AlertStatus.fromString(resource.status) ?? AlertStatus.active,
    severity:
    AlertSeverity.fromString(resource.severity) ??
        AlertSeverity.low,
    occurredAt: resource.occurredAt,
    resolvedAt: resource.resolvedAt,
    createdAt: resource.createdAt,
  );
}

AlertPage alertPageResourceToDomain(
    AlertPageResource resource,
    ) {
  return AlertPage(
    content: resource.content
        .map(alertResponseResourceToDomain)
        .toList(),
    totalElements: resource.totalElements,
    totalPages: resource.totalPages,
    size: resource.size,
    number: resource.number,
  );
}

DailyAlertCount dailyAlertSummaryResourceToDomain(
    DailyAlertSummaryResource resource,
    ) {
  return DailyAlertCount(
    date: resource.date,
    count: resource.count.toInt(),
  );
}
