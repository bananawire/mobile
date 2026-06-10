import 'package:flutter/material.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final double? value;
  final String unit;
  final double? delta;
  final Color statusColor;
  final bool isSelected;
  final VoidCallback onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.delta,
    required this.statusColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deltaPositive = delta != null && delta! >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kGoodColor : const Color(0xFF2A2A2A),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    formatValue(value),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (delta != null) ...[
                  Icon(
                    deltaPositive ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: deltaPositive ? kGoodColor : kUnhealthyColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatDelta(delta),
                    style: TextStyle(
                      color: deltaPositive ? kGoodColor : kUnhealthyColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else
                  const Text(
                    'N/A',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
