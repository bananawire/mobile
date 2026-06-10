import 'package:mobile/notifications/interfaces/rest/resources/notification_page.resource.dart';

abstract class NotificationsGateway {
  Future<NotificationPageResource> getNotifications({
    required int page,
    required int size,
  });
}
