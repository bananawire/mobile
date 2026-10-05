import 'package:flutter/widgets.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';

String buildDeviceChipLabel(DeviceReadModel device) {
  if (device.serialNumber.isNotEmpty) return device.serialNumber;
  if (device.hardwareId.isNotEmpty) return device.hardwareId;
  return 'DEVICE';
}

String buildDeviceUpdatedLabel(BuildContext context, DeviceReadModel device, {DateTime? now}) {
  final l10n = AppLocalizations.of(context)!;
  final ts = device.lastSeenAt ?? device.updatedAt ?? device.createdAt;
  if (ts == null) return l10n.time_updated_recently;

  final current = now ?? DateTime.now();
  final diff = current.difference(ts);

  if (diff.inSeconds < 10) return l10n.time_updated_just_now;
  if (diff.inMinutes < 1) return l10n.time_updated_seconds_ago(diff.inSeconds);
  if (diff.inHours < 1) return l10n.time_updated_minutes_ago(diff.inMinutes);
  if (diff.inDays < 1) return l10n.time_updated_hours_ago(diff.inHours);
  return l10n.time_updated_days_ago(diff.inDays);
}
