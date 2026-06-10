import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';

class Alert {
  final AlertId id;
  final String deviceId;

  final String? spaceId;
  final String? spaceName;
  final String? deviceName;

  final MetricType metric;

  final String metricLabel;
  final String metricUnit;

  final double thresholdValue;
  final double actualValue;

  final String message;

  final AlertStatus status;
  final AlertSeverity severity;

  final String occurredAt;
  final String? resolvedAt;
  final String createdAt;

  const Alert({
    required this.id,
    required this.deviceId,
    this.spaceId,
    this.spaceName,
    this.deviceName,
    required this.metric,
    required this.metricLabel,
    required this.metricUnit,
    required this.thresholdValue,
    required this.actualValue,
    required this.message,
    required this.status,
    required this.severity,
    required this.occurredAt,
    this.resolvedAt,
    required this.createdAt,
  });
}
