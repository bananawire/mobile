import 'package:flutter/material.dart';
import 'package:mobile/devices/interfaces/pages/device_detail/device_detail_view_model.dart';
import 'package:mobile/devices/interfaces/widgets/device_threshold_card.dart';

class DeviceThresholdsSection extends StatelessWidget {
  final List<DeviceDetailThresholdViewModel> thresholds;
  final VoidCallback? onEditTap;

  const DeviceThresholdsSection({
    super.key,
    required this.thresholds,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Thresholds',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.info_outline,
              size: 16,
              color: Colors.white.withValues(alpha: 0.45),
            ),
            const Spacer(),
            IconButton(
              onPressed: onEditTap,
              icon: const Icon(Icons.edit, color: Colors.white70),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'May affect device health',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.40),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: thresholds.length,
          itemBuilder: (context, index) {
            final t = thresholds[index];
            return DeviceThresholdCard(
              label: t.label,
              value: _formatThresholdValue(t.value),
              unit: t.unit,
            );
          },
        ),
      ],
    );
  }

  String _formatThresholdValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    final s = value.toStringAsFixed(2);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}
