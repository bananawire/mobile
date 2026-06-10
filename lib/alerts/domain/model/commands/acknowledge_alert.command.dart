import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';

class AcknowledgeAlertCommand {
  final AlertId alertId;

  const AcknowledgeAlertCommand({required this.alertId});
}
