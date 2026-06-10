import 'package:flutter/material.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';

class TrendChartCard extends StatelessWidget {
  final String title;
  final List<TrendPoint> points;
  final String metric;
  final double? delta;

  const TrendChartCard({
    super.key,
    required this.title,
    required this.points,
    required this.metric,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final deltaPositive = delta != null && delta! >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TREND (${title.toUpperCase()})',
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: points.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'No historical data in this time range. Try selecting a '
                        'different range or checking the device connectivity.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                      ),
                    ),
                  )
                : CustomPaint(
                    painter: _TrendPainter(points: points, metric: metric),
                    size: Size.infinite,
                  ),
          ),
          const SizedBox(height: 16),
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
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<TrendPoint> points;
  final String metric;

  _TrendPainter({required this.points, required this.metric});

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 12.0;
    final w = size.width;
    final h = size.height;

    // Gridlines.
    final grid = Paint()
      ..color = const Color(0xFF222222)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = padding + (h - 2 * padding) * (i / 4);
      canvas.drawLine(Offset(padding, y), Offset(w - padding, y), grid);
    }

    if (points.isEmpty) return;

    final values = points.map((p) => getMetricValue(p, metric)).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final offsets = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? padding
          : padding + (i / (points.length - 1)) * (w - 2 * padding);
      final y = h - padding - ((values[i] - minVal) / range) * (h - 2 * padding);
      offsets.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    if (offsets.length == 1) {
      linePath.lineTo(w - padding, offsets.first.dy);
    } else {
      for (var i = 0; i < offsets.length - 1; i++) {
        final curr = offsets[i];
        final next = offsets[i + 1];
        final xc = (curr.dx + next.dx) / 2;
        final yc = (curr.dy + next.dy) / 2;
        linePath.quadraticBezierTo(curr.dx, curr.dy, xc, yc);
      }
      linePath.lineTo(offsets.last.dx, offsets.last.dy);
    }

    // Gradient fill under the line.
    final lastX = offsets.length == 1 ? (w - padding) : offsets.last.dx;
    final fillPath = Path.from(linePath)
      ..lineTo(lastX, h - padding)
      ..lineTo(offsets.first.dx, h - padding)
      ..close();
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x4D10B981), Color(0x0010B981)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = kGoodColor;
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.points != points || old.metric != metric;
}
