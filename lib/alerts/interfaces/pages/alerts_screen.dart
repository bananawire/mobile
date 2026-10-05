import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile/alerts/domain/model/valueobjects/alert.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';
import 'package:mobile/alerts/interfaces/pages/alerts_cubit.dart';

import 'package:mobile/alerts/interfaces/widgets/alert_daily_chart.dart';
import 'package:mobile/alerts/interfaces/widgets/alert_table.dart';
import 'package:mobile/shared/interfaces/widgets/widgets.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AlertsCubit>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ClairAppBar(),
      body: SafeArea(
        child: BlocBuilder<AlertsCubit, AlertsState>(
          builder: (context, state) {
            final filteredAlerts = _applyFilters(
              state.currentAlerts,
              metric: state.selectedMetric,
            );

            final displayError =
            state.errorMessage == 'An unexpected error occurred'
                ? ''
                : state.errorMessage ?? '';

            return RefreshIndicator(
              onRefresh: () => context.read<AlertsCubit>().load(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.alerts_title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AlertDailyChart(
                            data: state.dailySummary,
                          ),
                          const SizedBox(height: 12),
                          const _UpdateInfo(),
                          const SizedBox(height: 24),
                          _AlertsTabBar(
                            tab: state.tab,
                            onChanged: context.read<AlertsCubit>().setTab,
                          ),
                          const SizedBox(height: 16),
                          AlertTable(
                            alerts: filteredAlerts,
                            loading: state.isLoading,
                            error: displayError,
                          ),
                          if (state.totalPages > 1) ...[
                            const SizedBox(height: 16),
                            _PaginationBar(
                              currentPage: state.currentPage,
                              totalPages: state.totalPages,
                              canGoPrevious: state.canGoPrevious,
                              canGoNext: state.canGoNext,
                              onPrevious: context.read<AlertsCubit>().previousPage,
                              onNext: context.read<AlertsCubit>().nextPage,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Alert> _applyFilters(
      List<Alert> alerts, {
        required MetricType? metric,
      }) {
    return alerts.where((alert) {
      final matchesMetric = metric == null || alert.metric == metric;
      return matchesMetric;
    }).toList();
  }
}

class _UpdateInfo extends StatelessWidget {
  const _UpdateInfo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.sync,
          size: 14,
          color: Color(0xFF9CA3AF),
        ),
        const SizedBox(width: 6),
        Text(
          AppLocalizations.of(context)!.time_updated_just_now,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AlertsTabBar extends StatelessWidget {
  final AlertTab tab;
  final ValueChanged<AlertTab> onChanged;

  const _AlertsTabBar({
    required this.tab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A2A2A)),
        ),
      ),
      child: Row(
        children: [
          _TabButton(
            label: AppLocalizations.of(context)!.alerts_tab_active,
            isActive: tab == AlertTab.active,
            onTap: () => onChanged(AlertTab.active),
          ),
          const SizedBox(width: 24),
          _TabButton(
            label: AppLocalizations.of(context)!.alerts_tab_history,
            isActive: tab == AlertTab.history,
            onTap: () => onChanged(AlertTab.history),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isActive ? Colors.white : const Color(0xFF9CA3AF);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 2,
              width: isActive ? 100 : 0,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: canGoPrevious ? onPrevious : null,
          icon: const Icon(Icons.chevron_left, size: 18),
          label: Text(AppLocalizations.of(context)!.alerts_btn_previous),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: const Color(0xFF4B5563),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          AppLocalizations.of(context)!.alerts_page_info(currentPage + 1, totalPages),
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        TextButton.icon(
          onPressed: canGoNext ? onNext : null,
          label: Text(AppLocalizations.of(context)!.alerts_btn_next),
          icon: const Icon(Icons.chevron_right, size: 18),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}
