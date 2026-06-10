import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/devices/infrastructure/api/gateways/devices.gateway.dart';

class DevicesHttpGateway implements DevicesGateway {
  final Dio _dio;

  DevicesHttpGateway(this._dio);

  @override
  Future<int> getDeviceCountBySpace(String spaceId) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/devices',
      queryParameters: {
        'spaceId': spaceId,
        'page': 0,
        'size': 1,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final total = data['totalElements'];
    if (total is int) return total;
    if (total is num) return total.toInt();
    return 0;
  }

  @override
  Future<Map<String, dynamic>> getDevicesBySpaceRaw({
    required String spaceId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/devices',
      queryParameters: {
        'spaceId': spaceId,
        'page': page,
        'size': size,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected devices response format');
  }

  @override
  Future<Map<String, dynamic>> getDeviceByIdRaw(String deviceId) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/devices/$deviceId',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected device response format');
  }

  @override
  Future<Map<String, dynamic>> getDeviceStatusRaw(String deviceId) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/devices/$deviceId/status',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected device status response format');
  }

  @override
  Future<void> deleteDeviceRaw(String deviceId) async {
    await _dio.delete('${ApiConstants.apiPrefix}/devices/$deviceId');
  }

  @override
  Future<void> updateDeviceNameRaw(String deviceId, Map<String, dynamic> requestBody) async {
    await _dio.patch(
      '${ApiConstants.apiPrefix}/devices/$deviceId/name',
      data: requestBody,
    );
  }

  @override
  Future<Map<String, dynamic>> pairDeviceRaw({
    required Map<String, dynamic> requestBody,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/devices/pair',
      data: requestBody,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected pair device response format');
  }

  @override
  Future<Map<String, dynamic>> claimDeviceRaw({
    required Map<String, dynamic> requestBody,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/devices/claim',
      data: requestBody,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected claim device response format');
  }
}
