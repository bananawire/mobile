import 'package:flutter/material.dart';

import '../../domain/model/valueobjects/alert_status.valueobject.dart';

class AlertStatusBadge extends StatelessWidget {
  final AlertStatus status;

  const AlertStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _resolveColor(status),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        status.apiValue,
        maxLines: 1,
        softWrap: false,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          height: 1,
        ),
      ),
    );
  }

  Color _resolveColor(AlertStatus status) {
    switch (status) {
      case AlertStatus.active:
        return const Color(0xFF10B981);
      case AlertStatus.acknowledged:
        return const Color(0xFFF59E0B);
      case AlertStatus.resolved:
        return const Color(0xFF6B7280);
    }
  }
}
