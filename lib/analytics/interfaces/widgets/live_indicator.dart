import 'package:flutter/material.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';

/// LIVE pill with a pulsing dot when active; tap to enter live mode.
class LiveIndicator extends StatefulWidget {
  final bool active;
  final VoidCallback onTap;

  const LiveIndicator({super.key, required this.active, required this.onTap});

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final dotColor = active ? kGoodColor : const Color(0xFF6B7280);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? kGoodColor.withValues(alpha: 0.12) : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: active ? kGoodColor : const Color(0xFF2A2A2A),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: active
                  ? FadeTransition(
                      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
                      child: Container(
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kGoodColor.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
            ),
            const SizedBox(width: 8),
            Text(
              'LIVE',
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF9CA3AF),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
