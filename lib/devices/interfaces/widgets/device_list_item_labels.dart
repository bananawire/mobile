import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';

String buildDeviceChipLabel(DeviceReadModel device) {
  if (device.serialNumber.isNotEmpty) return device.serialNumber;
  if (device.hardwareId.isNotEmpty) return device.hardwareId;
  return 'DEVICE';
}

String buildDeviceUpdatedLabel(DeviceReadModel device, {DateTime? now}) {
  final ts = device.lastSeenAt ?? device.updatedAt ?? device.createdAt;
  if (ts == null) return 'Updated recently';

  final current = now ?? DateTime.now();
  final diff = current.difference(ts);

  if (diff.inSeconds < 10) return 'Updated just now';
  if (diff.inMinutes < 1) return 'Updated ${diff.inSeconds} seconds ago';
  if (diff.inHours < 1) return 'Updated ${diff.inMinutes} minutes ago';
  if (diff.inDays < 1) return 'Updated ${diff.inHours} hours ago';
  return 'Updated ${diff.inDays} days ago';
}
