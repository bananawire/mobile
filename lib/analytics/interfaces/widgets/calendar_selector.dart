import 'package:flutter/material.dart';

/// Calendar selector: pick Day / Week / Month / Custom range.
/// Highlights when a historical range is active (i.e. not LIVE).
class CalendarSelector extends StatelessWidget {
  final String selectedPeriod;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<String> onSelectPreset;
  final void Function(DateTime start, DateTime end) onSelectCustom;

  const CalendarSelector({
    super.key,
    required this.selectedPeriod,
    required this.startDate,
    required this.endDate,
    required this.onSelectPreset,
    required this.onSelectCustom,
  });

  static const String _customValue = '__custom__';

  bool get _active => selectedPeriod != 'LIVE';

  String get _label {
    switch (selectedPeriod) {
      case 'CUSTOM':
        if (startDate != null && endDate != null) {
          return '${_fmt(startDate!)} – ${_fmt(endDate!)}';
        }
        return 'Custom';
      case 'Day':
      case 'Week':
      case 'Month':
        return selectedPeriod;
      default:
        return 'History';
    }
  }

  static String _fmt(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  Future<void> _openCustom(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: (startDate != null && endDate != null)
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF10B981),
            surface: Color(0xFF1A1A1A),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      onSelectCustom(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 48),
      onSelected: (value) {
        if (value == _customValue) {
          _openCustom(context);
        } else {
          onSelectPreset(value);
        }
      },
      itemBuilder: (context) => [
        _item('Day', Icons.today),
        _item('Week', Icons.date_range),
        _item('Month', Icons.calendar_month),
        const PopupMenuDivider(),
        _item(_customValue, Icons.edit_calendar, label: 'Custom range…'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: _active ? const Color(0xFF2A2A2A) : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: _active ? const Color(0xFF3E3E3E) : const Color(0xFF2A2A2A),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: _active ? Colors.white : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 8),
            Text(
              _label,
              style: TextStyle(
                color: _active ? Colors.white : const Color(0xFF9CA3AF),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: _active ? Colors.white : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _item(String value, IconData icon, {String? label}) {
    final isActive = value == selectedPeriod;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isActive ? const Color(0xFF10B981) : Colors.white70),
          const SizedBox(width: 12),
          Text(
            label ?? value,
            style: TextStyle(
              color: isActive ? const Color(0xFF10B981) : Colors.white,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
