import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';

class AqiGaugeCard extends StatelessWidget {
  final double? value;
  final String category;
  final double? delta;
  final bool isSelected;
  final VoidCallback onTap;

  const AqiGaugeCard({
    super.key,
    required this.value,
    required this.category,
    required this.delta,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = getAqiColor(value);
    final deltaPositive = delta != null && delta! >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
                const Text(
                  'AIR QUALITY INDEX',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: CustomPaint(
                  painter: _GaugePainter(value: value, color: color),
                  child: Center(
                    child: Text(
                      value == null ? '--' : value!.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (delta != null) ...[
                  Icon(
                    deltaPositive ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: deltaPositive ? kGoodColor : kUnhealthyColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatDelta(delta),
                    style: TextStyle(
                      color: deltaPositive ? kGoodColor : kUnhealthyColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else
                  const Text(
                    'N/A',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double? value;
  final Color color;

  _GaugePainter({required this.value, required this.color});

  static const double _maxAqi = 150;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    final stroke = 8.0;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF222222);
    canvas.drawCircle(center, radius, track);

    final percent = value == null ? 0.0 : (value! / _maxAqi).clamp(0.0, 1.0);
    if (percent <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.value != value || old.color != color;
}
