import 'package:flutter/material.dart';

import '../../domain/model/valueobjects/alert.valueobject.dart';
import 'alert_severity_badge.dart';
import 'alert_status_badge.dart';

class AlertTable extends StatelessWidget {
  final List<Alert>? alerts;
  final bool loading;
  final String error;

  const AlertTable({
    super.key,
    this.alerts,
    this.loading = false,
    this.error = '',
  });

  @override
  Widget build(BuildContext context) {
    if (error.isNotEmpty) {
      return _ErrorState(message: error);
    }

    if (loading && (alerts == null || alerts!.isEmpty)) {
      return const _LoadingState();
    }

    if (!loading && (alerts == null || alerts!.isEmpty)) {
      return const _EmptyState();
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 900),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderRow(),
              if (alerts != null)
                ...alerts!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final alert = entry.value;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index > 0)
                        const Divider(
                          height: 1,
                          color: Color(0xFF222222),
                          indent: 16,
                          endIndent: 16,
                        ),
                      _TableRow(alert: alert),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A2A2A)),
        ),
      ),
      child: const Row(
        children: [
          _HeaderCell(width: 160, label: 'DEVICE'),
          _HeaderCell(width: 110, label: 'SEVERITY'),
          _HeaderCell(width: 200, label: 'SPACE'),
          _HeaderCell(width: 130, label: 'VARIABLE'),
          _HeaderCell(width: 100, label: 'TIME'),
          _HeaderCell(width: 120, label: 'STATUS'),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final double width;
  final String label;

  const _HeaderCell({
    required this.width,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final Alert alert;

  const _TableRow({
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              _displayDevice(alert),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Center(
              child: Align(
                alignment: Alignment.centerLeft,
                child: AlertSeverityBadge(severity: alert.severity),
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              alert.spaceName ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            width: 130,
            child: Text(
              alert.metric.apiName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFE5E7EB),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              _formatTime(alert.occurredAt),
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AlertStatusBadge(status: alert.status),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) {
      return iso;
    }

    final local = parsed.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _displayDevice(Alert alert) {
    final name = (alert.deviceName ?? '').trim();
    if (name.isNotEmpty) {
      return name;
    }
    return _shortId(alert.id.value);
  }

  String _shortId(String value) {
    if (value.length <= 6) {
      return value;
    }
    return value.substring(value.length - 6);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
      return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off,
            size: 36,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 12),
          const Text(
            'No alerts found',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9CA3AF)),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Loading alerts...',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
