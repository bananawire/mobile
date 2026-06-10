import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/alerts/infrastructure/api/gateways/alerts.gateway.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_page.resource.dart';
import 'package:mobile/alerts/interfaces/rest/resources/daily_alert_summary.resource.dart';

class AlertsHttpGateway implements AlertsGateway {
  final Dio _dio;

  AlertsHttpGateway(this._dio);

  static const String _path = '${ApiConstants.apiPrefix}/alerts';

  @override
  Future<AlertPageResource> getAlerts({
    required int page,
    required int size,
    List<String>? status,
  }) async {
    final response = await _dio.get(
      _path,
      queryParameters: _buildPageParams(page, size, status),
    );

    return AlertPageResource.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<AlertPageResource> getAlertsByDevice({
    required String deviceId,
    required int page,
    required int size,
    List<String>? status,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/devices/$deviceId/alerts',
      queryParameters: _buildPageParams(page, size, status),
    );

    return AlertPageResource.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<AlertPageResource> getAlertsBySpace({
    required String spaceId,
    required int page,
    required int size,
    List<String>? status,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/spaces/$spaceId/alerts',
      queryParameters: _buildPageParams(page, size, status),
    );

    return AlertPageResource.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<List<DailyAlertSummaryResource>>
  getCurrentUserDailyAlertSummary({
    required int days,
  }) async {
    final response = await _dio.get(
      '$_path/daily-summary',
      queryParameters: {'days': days},
    );

    return (response.data as List)
        .map(
          (e) => DailyAlertSummaryResource.fromJson(
        e as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  @override
  Future<List<DailyAlertSummaryResource>> getDailyAlertSummary({
    required String spaceId,
    required int days,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/spaces/$spaceId/alerts/daily-summary',
      queryParameters: {'days': days},
    );

    return (response.data as List)
        .map(
          (e) => DailyAlertSummaryResource.fromJson(
        e as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  Map<String, dynamic> _buildPageParams(
      int page,
      int size,
      List<String>? status,
      ) {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
    };

    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }

    return params;
  }
}
