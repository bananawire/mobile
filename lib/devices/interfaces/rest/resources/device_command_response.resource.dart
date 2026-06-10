import 'package:mobile/devices/domain/model/valueobjects/device_command_type.valueobject.dart';

class DeviceCommandResponseResource {
  final String id;
  final String deviceId;
  final String type;
  final String status;
  final String? payload;
  final DateTime? sentAt;
  final DateTime? executedAt;
  final String? failureReason;
  final DateTime? createdAt;

  const DeviceCommandResponseResource({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.status,
    required this.payload,
    required this.sentAt,
    required this.executedAt,
    required this.failureReason,
    required this.createdAt,
  });

  factory DeviceCommandResponseResource.fromJson(Map<String, dynamic> json) {
    return DeviceCommandResponseResource(
      id: (json['id'] ?? '').toString(),
      deviceId: (json['deviceId'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      payload: json['payload']?.toString(),
      sentAt: _tryParseDateTime(json['sentAt']),
      executedAt: _tryParseDateTime(json['executedAt']),
      failureReason: json['failureReason']?.toString(),
      createdAt: _tryParseDateTime(json['createdAt']),
    );
  }

  DeviceCommandType? get typeAsEnum {
    final v = type.toUpperCase();
    if (v == 'STANDBY') return DeviceCommandType.standby;
    if (v == 'WAKE') return DeviceCommandType.wake;
    if (v == 'RESTART') return DeviceCommandType.restart;
    return null;
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
