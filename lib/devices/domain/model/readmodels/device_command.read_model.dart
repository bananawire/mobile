import 'package:mobile/devices/domain/model/valueobjects/device_command_type.valueobject.dart';

class DeviceCommandReadModel {
  final String id;
  final String deviceId;
  final DeviceCommandType type;
  final String status;
  final String? payload;
  final DateTime? sentAt;
  final DateTime? executedAt;
  final String? failureReason;
  final DateTime? createdAt;

  const DeviceCommandReadModel({
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
}
