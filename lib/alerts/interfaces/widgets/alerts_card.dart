import 'package:flutter/material.dart';
import '../../domain/model/valueobjects/metric_type.valueobject.dart';
import '../../domain/model/valueobjects/alert.valueobject.dart';
import 'alert_status_badge.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;

  const AlertCard({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      _metricIcon(alert.metric),
                      size: 18,
                      color: const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        alert.metricLabel,
                        style: const TextStyle(
                          color: Color(0xFFE5E7EB),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${alert.metricUnit})',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: AlertStatusBadge(status: alert.status),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.message,
            style: const TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ValueBlock(
                label: 'Threshold',
                value: _formatValue(alert.thresholdValue),
              ),
              const SizedBox(width: 16),
              _ValueBlock(
                label: 'Actual',
                value: _formatValue(alert.actualValue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF2C2C2E)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(alert.occurredAt),
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (alert.resolvedAt != null)
                  Text(
                    'Resolved ${_formatDate(alert.resolvedAt!)}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) {
      return iso;
    }

    final local = parsed.toLocal();
    final yyyy = local.year.toString().padLeft(4, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');

    return '$yyyy-$mm-$dd $hh:$min';
  }

  static String _formatValue(double value) {
    final text = value.toString();
    if (text.endsWith('.0')) {
      return text.substring(0, text.length - 2);
    }

    return text;
  }

  static IconData _metricIcon(MetricType metric) {
    switch (metric) {
      case MetricType.pm25:
        return Icons.cloud;
      case MetricType.co2:
        return Icons.co2;
      case MetricType.temperature:
        return Icons.thermostat;
      case MetricType.humidity:
        return Icons.water_drop;
    }
  }
}

class _ValueBlock extends StatelessWidget {
  final String label;
  final String value;

  const _ValueBlock({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 11,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
