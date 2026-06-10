import 'package:flutter/material.dart';

import '../../domain/model/valueobjects/alert_severity.valueobject.dart';

class AlertSeverityBadge extends StatelessWidget {
  final AlertSeverity severity;

  const AlertSeverityBadge({
    super.key,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForSeverity(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        severity.apiValue,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          color: colors.text,
          fontSize: 11.2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.64,
          height: 1,
        ),
      ),
    );
  }

  _BadgeColors _colorsForSeverity(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return const _BadgeColors(
          background: Color.fromRGBO(239, 68, 68, 0.15),
          text: Color(0xFFEF4444),
          border: Color.fromRGBO(239, 68, 68, 0.3),
        );
      case AlertSeverity.warning:
        return const _BadgeColors(
          background: Color.fromRGBO(245, 158, 11, 0.15),
          text: Color(0xFFF59E0B),
          border: Color.fromRGBO(245, 158, 11, 0.3),
        );
      case AlertSeverity.low:
        return const _BadgeColors(
          background: Color.fromRGBO(16, 185, 129, 0.15),
          text: Color(0xFF10B981),
          border: Color.fromRGBO(16, 185, 129, 0.3),
        );
    }
  }
}

class _BadgeColors {
  final Color background;
  final Color text;
  final Color border;

  const _BadgeColors({
    required this.background,
    required this.text,
    required this.border,
  });
}
