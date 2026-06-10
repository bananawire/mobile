import 'package:mobile/notifications/domain/model/valueobjects/notification_id.valueobject.dart';

class NotificationLog {
  final NotificationId id;
  final String userId;
  final String? alertId;
  final String title;
  final String message;
  final bool sent;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationLog({
    required this.id,
    required this.userId,
    this.alertId,
    required this.title,
    required this.message,
    required this.sent,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });
}
