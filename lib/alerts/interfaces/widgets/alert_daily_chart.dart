import 'package:flutter/material.dart';
import '../../domain/model/valueobjects/daily_alert_count.valueobject.dart';

class AlertDailyChart extends StatelessWidget {
  final List<DailyAlertCount>? data;

  const AlertDailyChart({super.key, this.data});

  static const int _daysToShow = 30;

  @override
  Widget build(BuildContext context) {
    final bars = _buildChartBars();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last 30 days',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE5E7EB),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 130,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _GridPainter()),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: bars.map((bar) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1),
                              child: Container(
                                height: constraints.maxHeight * (bar.heightPct / 100),
                                decoration: BoxDecoration(
                                  color: bar.color,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_ChartBarData> _buildChartBars() {
    final safeData = data ?? [];

    final map = {
      for (final e in safeData) e.date: e.count,
    };

    final days = _buildLastNDays(_daysToShow);

    final series = days.map((d) {
      return _ChartPoint(date: d, count: map[d] ?? 0);
    }).toList();

    final maxCount = series.map((e) => e.count).fold<int>(
      0,
          (a, b) => a > b ? a : b,
    );

    return series.map((d) {
      double pct;

      if (maxCount == 0) {
        pct = 0;
      } else {
        pct = (d.count / maxCount) * 100;
      }

      return _ChartBarData(
        heightPct: d.count == 0 ? 2 : pct.clamp(5, 100),
        color: d.count == 0
            ? const Color(0xFF10B981).withValues(alpha: 0.3)
            : _barColor(d.count),
      );
    }).toList();
  }

  List<String> _buildLastNDays(int days) {
    final now = DateTime.now();

    return List.generate(days, (i) {

      final d = DateTime(now.year, now.month, now.day - i);

      return "${d.year.toString().padLeft(4, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.day.toString().padLeft(2, '0')}";
    });
  }

  Color _barColor(int count) {
    if (count <= 3) return const Color(0xFF10B981);
    if (count <= 7) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class _ChartPoint {
  final String date;
  final int count;

  _ChartPoint({required this.date, required this.count});
}

class _ChartBarData {
  final double heightPct;
  final Color color;

  _ChartBarData({required this.heightPct, required this.color});
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 1;

    const spacing = 28.0;

    for (double y = size.height; y >= 0; y -= spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
