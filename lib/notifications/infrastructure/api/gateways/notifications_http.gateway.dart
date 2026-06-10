import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/notifications/infrastructure/api/gateways/notifications.gateway.dart';
import 'package:mobile/notifications/interfaces/rest/resources/notification_page.resource.dart';

class NotificationsHttpGateway implements NotificationsGateway {
  final Dio _dio;

  NotificationsHttpGateway(this._dio);

  static const String _path = '${ApiConstants.apiPrefix}/notifications/push';

  @override
  Future<NotificationPageResource> getNotifications({
    required int page,
    required int size,
  }) async {
    final response = await _dio.get(
      _path,
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    return NotificationPageResource.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
