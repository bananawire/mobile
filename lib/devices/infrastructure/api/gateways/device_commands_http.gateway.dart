import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_commands.gateway.dart';

class DeviceCommandsHttpGateway implements DeviceCommandsGateway {
  final Dio _dio;

  DeviceCommandsHttpGateway(this._dio);

  @override
  Future<Map<String, dynamic>> createDeviceCommandRaw({
    required String deviceId,
    required Map<String, dynamic> requestBody,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/devices/$deviceId/commands',
      data: requestBody,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected device command response format');
  }
}
