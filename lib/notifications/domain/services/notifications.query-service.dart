import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/notifications/domain/model/queries/get_notifications.query.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';

abstract class NotificationsQueryService {
  Future<Either<Failure, NotificationPage>> handleGetNotifications(
    GetNotificationsQuery query,
  );
}
