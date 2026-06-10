import 'package:flutter/material.dart';

import '../../domain/model/valueobjects/alert.valueobject.dart';
import 'alerts_card.dart';

enum AlertViewMode {
  grid,
  list,
}

class AlertList extends StatelessWidget {
  final List<Alert>? alerts;
  final bool loading;
  final String error;
  final AlertViewMode viewMode;
  final ValueChanged<AlertViewMode> onViewModeChanged;

  const AlertList({
    super.key,
    this.alerts,
    this.loading = false,
    this.error = '',
    this.viewMode = AlertViewMode.grid,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isMobile)
          _Toolbar(
            viewMode: viewMode,
            onViewModeChanged: onViewModeChanged,
          ),
        if (loading && (alerts == null || alerts!.isEmpty))
          const _StateMessage(
            icon: Icons.hourglass_empty,
            text: 'Loading alerts...',
            color: Color(0xFF9CA3AF),
            showSpinner: true,
          )
        else if (error.isNotEmpty)
          _StateMessage(
            icon: Icons.error_outline,
            text: error,
            color: const Color(0xFFEF4444),
          )
        else if (alerts == null || alerts!.isEmpty)
          const _StateMessage(
            icon: Icons.notifications_off,
            text: 'No alerts',
            color: Color(0xFF9CA3AF),
          )
        else
          _AlertItems(
            alerts: alerts!,
            viewMode: viewMode,
          ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  final AlertViewMode viewMode;
  final ValueChanged<AlertViewMode> onViewModeChanged;

  const _Toolbar({
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _ToggleButton(
                  icon: Icons.grid_view,
                  isActive: viewMode == AlertViewMode.grid,
                  onTap: () => onViewModeChanged(AlertViewMode.grid),
                ),
                _ToggleButton(
                  icon: Icons.view_list,
                  isActive: viewMode == AlertViewMode.list,
                  onTap: () => onViewModeChanged(AlertViewMode.list),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFF2C2C2E) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? Colors.white : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool showSpinner;

  const _StateMessage({
    required this.icon,
    required this.text,
    required this.color,
    this.showSpinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 48,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: color),
          ),
          if (showSpinner) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AlertItems extends StatelessWidget {
  final List<Alert> alerts;
  final AlertViewMode viewMode;

  const _AlertItems({
    required this.alerts,
    required this.viewMode,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (viewMode == AlertViewMode.list || width < 600) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final alert in alerts) ...[
            AlertCard(alert: alert),
            const SizedBox(height: 16),
          ],
        ],
      );
    }

    final crossAxisCount = width >= 1200
        ? 3
        : width >= 800
            ? 2
            : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alerts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        return AlertCard(
          alert: alerts[index],
        );
      },
    );
  }
}
