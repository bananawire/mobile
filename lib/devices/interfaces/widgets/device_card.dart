import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';
import 'package:mobile/devices/interfaces/widgets/device_list_item_labels.dart';
import 'package:mobile/devices/interfaces/widgets/device_power_status_badge.dart';

class DeviceCard extends StatelessWidget {
  final DeviceReadModel device;

  const DeviceCard({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    final label = buildDeviceChipLabel(device);
    final updatedLabel = buildDeviceUpdatedLabel(context, device);
    final isOnline = device.status.toUpperCase() == 'ONLINE';
    final isRecentlySeen = device.lastSeenAt != null &&
        DateTime.now().difference(device.lastSeenAt!).inMinutes < 2;
    final isPoweredOn = isOnline || isRecentlySeen;

    return GestureDetector(
      onTap: () => context.push('/devices/${device.id}', extra: device),
      child: Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.signal_cellular_alt,
                size: 18,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  device.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              DevicePowerStatusBadge(isOn: isPoweredOn),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.white.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  updatedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.50),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
