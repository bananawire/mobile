import 'package:mobile/notifications/domain/model/valueobjects/notification_id.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';
import 'package:mobile/notifications/interfaces/rest/resources/notification_page.resource.dart';
import 'package:mobile/notifications/interfaces/rest/resources/notification_response.resource.dart';

NotificationLog notificationResponseResourceToDomain(
  NotificationResponseResource resource,
) {
  return NotificationLog(
    id: NotificationId(resource.id),
    userId: resource.userId,
    alertId: resource.alertId,
    title: resource.title,
    message: resource.message,
    sent: resource.sent,
    errorMessage: resource.errorMessage,
    createdAt: DateTime.tryParse(resource.createdAt) ?? DateTime.now(),
    updatedAt: DateTime.tryParse(resource.updatedAt) ?? DateTime.now(),
  );
}

NotificationPage notificationPageResourceToDomain(
  NotificationPageResource resource,
) {
  return NotificationPage(
    content: resource.content
        .map(notificationResponseResourceToDomain)
        .toList(),
    totalElements: resource.totalElements,
    totalPages: resource.totalPages,
    size: resource.size,
    number: resource.number,
  );
}
