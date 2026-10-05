import 'package:dio/dio.dart';

/// Shared JSON fixtures for the `devices` context tests.
///
/// Every fixture is an explicit literal map so that a wrong field name in
/// production code cannot be masked by a symmetric round trip.

/// A fully populated `DeviceResponseResource` payload.
Map<String, dynamic> deviceResourceJson({
  String id = 'dev-1',
  String name = 'Living Room Sensor',
  String status = 'ONLINE',
  String? spaceId = 'space-1',
  String? ownerUserId = 'user-1',
  Map<String, String> configuration = const {'reportingInterval': '60'},
  List<dynamic> thresholds = const [
    {'metric': 'PM25', 'value': 60.0},
  ],
  String hardwareId = 'HW-1',
  String deviceType = 'AIR_QUALITY',
  String? activatedAt = '2024-01-15T10:30:00Z',
  String? lastSeenAt = '2024-02-20T08:00:00Z',
  String? createdAt = '2024-01-15T10:00:00Z',
  String? updatedAt = '2024-02-20T08:05:00Z',
}) {
  return <String, dynamic>{
    'id': id,
    'serialNumber': 'SN-$id',
    'name': name,
    'status': status,
    'spaceId': spaceId,
    'ownerUserId': ownerUserId,
    'configuration': configuration,
    'thresholds': thresholds,
    'hardwareId': hardwareId,
    'deviceType': deviceType,
    'activatedAt': activatedAt,
    'lastSeenAt': lastSeenAt,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

/// A page payload wrapping [count] device payloads.
Map<String, dynamic> devicePageJson({
  num totalElements = 2,
  num number = 0,
  num size = 20,
  List<Map<String, dynamic>>? content,
}) {
  return <String, dynamic>{
    'content': content ??
        <Map<String, dynamic>>[
          deviceResourceJson(id: 'dev-1'),
          deviceResourceJson(id: 'dev-2', name: 'Kitchen Probe', status: 'OFFLINE'),
        ],
    'totalElements': totalElements,
    'number': number,
    'size': size,
  };
}

/// A `DeviceStatusResponseResource` payload.
Map<String, dynamic> deviceStatusJson({
  String key = 'deviceId',
  String deviceId = 'dev-1',
  String status = 'ONLINE',
  String? lastSeenAt = '2024-02-20T08:00:00Z',
}) {
  return <String, dynamic>{
    key: deviceId,
    'status': status,
    'lastSeenAt': lastSeenAt,
  };
}

/// A `DevicePairingResource` payload.
Map<String, dynamic> devicePairingJson({
  String deviceId = 'dev-1',
  String? claimToken = 'claim-token-1',
}) {
  return <String, dynamic>{'deviceId': deviceId, 'claimToken': claimToken};
}

/// A `DeviceCommandResponseResource` payload.
Map<String, dynamic> deviceCommandJson({
  String id = 'cmd-1',
  String deviceId = 'dev-1',
  String type = 'STANDBY',
  String status = 'QUEUED',
  String? payload = '{"deep":true}',
  String? sentAt = '2024-02-20T08:00:00Z',
  String? executedAt,
  String? failureReason,
  String? createdAt = '2024-02-20T07:59:00Z',
}) {
  return <String, dynamic>{
    'id': id,
    'deviceId': deviceId,
    'type': type,
    'status': status,
    'payload': payload,
    'sentAt': sentAt,
    'executedAt': executedAt,
    'failureReason': failureReason,
    'createdAt': createdAt,
  };
}

/// A `SpaceResponseResource` payload.
Map<String, dynamic> spaceResourceJson({
  String id = 'space-1',
  String name = 'Main Bedroom',
  String organizationId = 'org-1',
  String? ownerUserId = 'user-1',
  String? createdAt = '2024-01-15T10:00:00Z',
  String? updatedAt = '2024-02-20T08:05:00Z',
}) {
  return <String, dynamic>{
    'id': id,
    'name': name,
    'organizationId': organizationId,
    'ownerUserId': ownerUserId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

/// An `OrganizationResponseResource` payload.
Map<String, dynamic> organizationResourceJson({
  String id = 'org-1',
  String name = 'Acme Corp',
  String? ownerUserId = 'user-1',
  String? createdAt = '2024-01-15T10:00:00Z',
  String? updatedAt = '2024-02-20T08:05:00Z',
}) {
  return <String, dynamic>{
    'id': id,
    'name': name,
    'ownerUserId': ownerUserId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

/// A `DeviceThresholdResource` payload.
Map<String, dynamic> deviceThresholdJson({
  String deviceId = 'dev-1',
  String metric = 'PM25',
  Object? value = 60.5,
  Object? enabled = true,
  String? metricLabel,
  String? metricUnit,
}) {
  return <String, dynamic>{
    'deviceId': deviceId,
    'metric': metric,
    'value': value,
    'enabled': enabled,
    'metricLabel': ?metricLabel,
    'metricUnit': ?metricUnit,
  };
}

/// Builds a `DioException.badResponse` carrying an HTTP [statusCode] response.
DioException dioError(int statusCode, {String path = '/api/v1/devices'}) {
  final options = RequestOptions(path: path);
  return DioException.badResponse(
    statusCode: statusCode,
    requestOptions: options,
    response: Response<Map<String, dynamic>>(
      requestOptions: options,
      statusCode: statusCode,
      data: <String, dynamic>{'message': 'boom'},
    ),
  );
}

/// Builds a `DioException.connectionError`, as produced by a connectivity failure.
DioException dioConnectionError({String path = '/api/v1/devices'}) {
  return DioException.connectionError(
    requestOptions: RequestOptions(path: path),
    reason: 'connection refused',
  );
}