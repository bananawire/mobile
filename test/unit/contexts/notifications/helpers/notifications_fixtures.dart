import 'package:mobile/notifications/domain/model/valueobjects/notification_id.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';
import 'package:mobile/notifications/domain/services/notifications.query-service.dart';
import 'package:mobile/notifications/infrastructure/api/gateways/notifications.gateway.dart';
import 'package:mobile/notifications/interfaces/rest/resources/notification_page.resource.dart';
import 'package:mobile/notifications/interfaces/rest/resources/notification_response.resource.dart';
import 'package:mocktail/mocktail.dart';

/// Doubles for the two collaborators of the notifications application layer.
class MockNotificationsQueryService extends Mock
    implements NotificationsQueryService {}

class MockNotificationsGateway extends Mock implements NotificationsGateway {}

/// A fully populated notification payload, using the wire field names that
/// `NotificationResponseResource.fromJson` reads.
const Map<String, Object?> notificationJson = <String, Object?>{
  'id': 'notification-1',
  'userId': 'user-1',
  'alertId': 'alert-1',
  'title': 'High temperature',
  'message': 'The kitchen sensor reported 41 degrees',
  'sent': true,
  'errorMessage': null,
  'createdAt': '2024-05-01T10:30:00Z',
  'updatedAt': '2024-05-01T10:31:00Z',
};

/// A page wrapper payload holding a single [notificationJson] element.
const Map<String, Object?> notificationPageJson = <String, Object?>{
  'content': <Object?>[notificationJson],
  'totalElements': 1,
  'totalPages': 1,
  'size': 20,
  'number': 0,
};

/// The page wrapper the backend answers with when there is nothing to show.
const Map<String, Object?> emptyNotificationsPageJson = <String, Object?>{
  'content': <Object?>[],
  'totalElements': 0,
  'totalPages': 0,
  'size': 20,
  'number': 0,
};

/// Builds a [NotificationResponseResource] from raw JSON, so the resource
/// factories are exercised instead of bypassed.
NotificationResponseResource notificationResourceFromJson(
  Map<String, Object?> json,
) {
  return NotificationResponseResource.fromJson(
    json.map((key, value) => MapEntry<String, dynamic>(key, value)),
  );
}

/// Builds a [NotificationPageResource] from a raw JSON wrapper.
NotificationPageResource notificationPageResourceFromJson(
  Map<String, Object?> json,
) {
  return NotificationPageResource.fromJson(
    json.map((key, value) => MapEntry<String, dynamic>(key, value)),
  );
}

/// Builds a real [NotificationLog]; only [id] is defaulted so each test states
/// the fields that matter to it.
NotificationLog buildNotificationLog({
  String id = 'notification-1',
  String userId = 'user-1',
  String? alertId,
  String title = 'High temperature',
  String message = 'The kitchen sensor reported 41 degrees',
  bool sent = true,
  String? errorMessage,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final timestamp = createdAt ?? DateTime.utc(2024, 5, 1, 10, 30);
  return NotificationLog(
    id: NotificationId(id),
    userId: userId,
    alertId: alertId,
    title: title,
    message: message,
    sent: sent,
    errorMessage: errorMessage,
    createdAt: timestamp,
    updatedAt: updatedAt ?? timestamp,
  );
}

/// Builds a real [NotificationPage] holding [content].
NotificationPage buildNotificationPage(
  List<NotificationLog> content, {
  int totalElements = 0,
  int totalPages = 1,
  int size = 20,
  int number = 0,
}) {
  return NotificationPage(
    content: content,
    totalElements: totalElements,
    totalPages: totalPages,
    size: size,
    number: number,
  );
}

/// The page the application layer receives for an empty backend answer.
NotificationPage get emptyNotificationsPage => buildNotificationPage(
      const <NotificationLog>[],
      totalElements: 0,
      totalPages: 0,
    );