import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/notifications/domain/model/queries/get_notifications.query.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';
import 'package:mobile/notifications/domain/services/notifications.query-service.dart';
import 'package:mobile/notifications/infrastructure/api/gateways/notifications.gateway.dart';
import 'package:mobile/notifications/interfaces/rest/transform/notifications_transform.dart';

class NotificationsQueryServiceImpl implements NotificationsQueryService {
  final NotificationsGateway _gateway;

  NotificationsQueryServiceImpl(this._gateway);

  @override
  Future<Either<Failure, NotificationPage>> handleGetNotifications(
    GetNotificationsQuery query,
  ) async {
    try {
      final resource = await _gateway.getNotifications(
        page: query.page,
        size: query.size,
      );

      return Right(
        notificationPageResourceToDomain(resource),
      );
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (_) {
      return const Left(
        Failure('An unexpected error occurred'),
      );
    }
  }

  Failure _mapError(DioException error) {
    final status = error.response?.statusCode;
    String? serverMessage;
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      serverMessage = data['message'].toString();
    }

    return Failure(
      serverMessage ?? error.message ?? 'An unexpected error occurred',
      statusCode: status,
    );
  }
}
