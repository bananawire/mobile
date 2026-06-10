import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/analytics/interfaces/pages/analytics_cubit.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';
import 'package:mobile/analytics/interfaces/widgets/aqi_gauge_card.dart';
// Calendar/date-range selector disabled — analytics is live-stream only.
// import 'package:mobile/analytics/interfaces/widgets/calendar_selector.dart';
import 'package:mobile/analytics/interfaces/widgets/live_indicator.dart';
import 'package:mobile/analytics/interfaces/widgets/metric_card.dart';
import 'package:mobile/analytics/interfaces/widgets/trend_chart_card.dart';
import 'package:mobile/shared/interfaces/widgets/widgets.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ClairAppBar(),
      body: SafeArea(
        child: BlocBuilder<AnalyticsCubit, AnalyticsState>(
          builder: (context, state) {
            final cubit = context.read<AnalyticsCubit>();
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context, state, cubit),
                  const SizedBox(height: 20),
                  _DropdownsRow(state: state, cubit: cubit),
                  const SizedBox(height: 20),
                  _body(context, state, cubit),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AnalyticsState state, AnalyticsCubit cubit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'Air Quality',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        LiveIndicator(
          active: state.isLive,
          onTap: () => cubit.selectPeriod('LIVE'),
        ),
      ],
    );
    // Calendar / date-range picker removed — live-stream only.
    // CalendarSelector(
    //   selectedPeriod: state.selectedPeriod,
    //   startDate: state.startDate,
    //   endDate: state.endDate,
    //   onSelectPreset: cubit.selectPeriod,
    //   onSelectCustom: cubit.selectCustomRange,
    // );
  }

  Widget _body(BuildContext context, AnalyticsState state, AnalyticsCubit cubit) {
    if (state.errorMessage != null) {
      return _InfoState(
        icon: Icons.error_outline,
        iconColor: kUnhealthyColor,
        message: state.errorMessage!,
      );
    }

    if (state.isLoading && !state.hasData) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(child: CircularProgressIndicator(color: kGoodColor)),
      );
    }

    if (state.liveUnavailable && !state.hasData) {
      return _InfoState(
        icon: Icons.cloud_off,
        iconColor: const Color(0xFF6B7280),
        message: state.liveUnavailableMessage.isEmpty
            ? 'Live data is not available right now.'
            : state.liveUnavailableMessage,
      );
    }

    if (!state.hasData) {
      return const _InfoState(
        icon: Icons.analytics_outlined,
        iconColor: Color(0xFF4B5563),
        title: 'No measurements available',
        message: 'This device has no telemetry or historical data for the selected period.',
      );
    }

    return _Dashboard(state: state, cubit: cubit);
  }
}

class _Dashboard extends StatelessWidget {
  final AnalyticsState state;
  final AnalyticsCubit cubit;

  const _Dashboard({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final live = state.liveData;
    final activeDelta = getActiveMetricDelta(live, state.selectedMetric);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AqiGaugeCard(
          value: live?.aqi.value,
          category: live?.aqi.category ?? 'No measurements',
          delta: activeDelta,
          isSelected: state.selectedMetric == 'aqiValue',
          onTap: () => cubit.selectMetric('aqiValue'),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            MetricCard(
              title: 'PM2.5',
              value: live?.pm2_5.value,
              unit: 'µg/m³',
              delta: live?.pm2_5.deltaPercentage,
              statusColor: getPm25StatusColor(live?.pm2_5.value),
              isSelected: state.selectedMetric == 'pm2_5',
              onTap: () => cubit.selectMetric('pm2_5'),
            ),
            MetricCard(
              title: 'CO₂',
              value: live?.co2.value,
              unit: 'ppm',
              delta: live?.co2.deltaPercentage,
              statusColor: getCo2StatusColor(live?.co2.value),
              isSelected: state.selectedMetric == 'co2',
              onTap: () => cubit.selectMetric('co2'),
            ),
            MetricCard(
              title: 'TEMP',
              value: live?.temperature.value,
              unit: '°C',
              delta: live?.temperature.deltaPercentage,
              statusColor: getTempStatusColor(live?.temperature.value),
              isSelected: state.selectedMetric == 'temperature',
              onTap: () => cubit.selectMetric('temperature'),
            ),
            MetricCard(
              title: 'HUMIDITY',
              value: live?.humidity.value,
              unit: '%',
              delta: live?.humidity.deltaPercentage,
              statusColor: getHumidityStatusColor(live?.humidity.value),
              isSelected: state.selectedMetric == 'humidity',
              onTap: () => cubit.selectMetric('humidity'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TrendChartCard(
          title: state.selectedMetric == 'aqiValue' ? 'AQI' : state.selectedMetric.toUpperCase(),
          points: state.trendDataPoints,
          metric: state.selectedMetric,
          delta: activeDelta,
        ),
        if (live != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.sync, size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(
                'Updated ${formatUpdateTime(state.secondsSinceUpdate)}',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DropdownsRow extends StatelessWidget {
  final AnalyticsState state;
  final AnalyticsCubit cubit;

  const _DropdownsRow({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Dropdown(
            label: 'ORGANIZATION',
            value: state.selectedOrgId,
            options: state.organizations,
            onChanged: (id) {
              if (id != null) cubit.selectOrganization(id);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Dropdown(
            label: 'SPACE',
            value: state.selectedSpaceId,
            options: state.spaces,
            onChanged: (id) {
              if (id != null) cubit.selectSpace(id);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Dropdown(
            label: 'DEVICE',
            value: state.selectedDeviceId,
            options: state.devices,
            onChanged: (id) {
              if (id != null) cubit.selectDevice(id);
            },
          ),
        ),
      ],
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<AnalyticsSelectOption> options;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && options.any((o) => o.id == value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: hasValue ? value : null,
              isExpanded: true,
              isDense: true,
              dropdownColor: const Color(0xFF1A1A1A),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF), size: 18),
              hint: Text(
                options.isEmpty ? 'None' : 'Select',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: options
                  .map((o) => DropdownMenuItem(
                        value: o.id,
                        child: Text(o.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: options.isEmpty ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String? title;
  final String message;

  const _InfoState({
    required this.icon,
    required this.iconColor,
    this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 44),
          const SizedBox(height: 12),
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
