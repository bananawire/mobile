import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/devices/interfaces/pages/device_detail/device_detail_view_model.dart';

class DeviceDetailMetricsGrid extends StatelessWidget {
  final DeviceDetailViewModel device;

  const DeviceDetailMetricsGrid({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final metrics = [
      _MetricItem(
        label: l10n.devices_vitals_connectivity,
        value: '${device.connectivityDbm}',
        unit: 'dBm',
        icon: Icons.signal_cellular_alt,
      ),
      _MetricItem(
        label: l10n.devices_vitals_uptime,
        value: '${device.uptimeHours}',
        unit: l10n.devices_vitals_uptime_unit,
        icon: Icons.trending_up,
      ),
      _MetricItem(
        label: l10n.devices_vitals_health,
        value: '${device.deviceHealthPercent}',
        unit: '%',
        icon: Icons.favorite_border,
      ),
      _MetricItem(
        label: l10n.devices_vitals_last_update,
        value: '${device.lastUpdateHours}',
        unit: l10n.devices_vitals_last_update_unit,
        icon: Icons.access_time,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _MetricCard(metric: metric);
      },
    );
  }
}

class _MetricItem {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricItem metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            metric.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(
                metric.icon,
                size: 14,
                color: Colors.white.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 6),
              Text(
                metric.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                metric.unit,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
