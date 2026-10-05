import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';
import 'package:mobile/devices/interfaces/widgets/device_list_item_labels.dart';
import 'package:mobile/devices/interfaces/widgets/device_power_status_badge.dart';

class DeviceListTile extends StatelessWidget {
  final DeviceReadModel device;

  const DeviceListTile({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = device.status.toUpperCase() == 'ONLINE';
    final isRecentlySeen = device.lastSeenAt != null &&
        DateTime.now().difference(device.lastSeenAt!).inMinutes < 2;
    final isPoweredOn = isOnline || isRecentlySeen;

    return GestureDetector(
      onTap: () => context.push('/devices/${device.id}', extra: device),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          DevicePowerStatusBadge(isOn: isPoweredOn),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  buildDeviceUpdatedLabel(context, device),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              buildDeviceChipLabel(device),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
