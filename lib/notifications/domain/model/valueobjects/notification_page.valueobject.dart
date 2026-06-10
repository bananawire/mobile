import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';

class NotificationPage {
  final List<NotificationLog> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;

  const NotificationPage({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
  });
}
