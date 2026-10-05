import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';
import 'package:mobile/devices/interfaces/pages/device_detail/device_detail_view_model.dart';
import 'package:mobile/devices/interfaces/rest/transform/device_detail_threshold_defaults_transform.dart';

class DeviceThresholdsEditorDialog extends StatefulWidget {
  final List<DeviceDetailThresholdViewModel> initialThresholds;
  final Future<bool> Function(List<DeviceDetailThresholdViewModel> thresholds) onSave;

  const DeviceThresholdsEditorDialog({
    super.key,
    required this.initialThresholds,
    required this.onSave,
  });

  @override
  State<DeviceThresholdsEditorDialog> createState() => _DeviceThresholdsEditorDialogState();
}

class _DeviceThresholdsEditorDialogState extends State<DeviceThresholdsEditorDialog> {
  late Map<MetricThreshold, double> _values;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _values = _buildMergedValues(widget.initialThresholds);
  }

  Map<MetricThreshold, double> _buildMergedValues(List<DeviceDetailThresholdViewModel> items) {
    final defaults = buildDefaultDeviceDetailThresholdResources();
    final map = <MetricThreshold, double>{for (final item in defaults) item.metric: item.value};
    for (final item in items) {
      map[item.metric] = item.value;
    }
    return map;
  }

  void _resetValues() {
    setState(() {
      _values = _buildMergedValues(buildDefaultDeviceDetailThresholdResources());
    });
  }

  Future<void> _saveValues() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    final updated = _buildUpdatedThresholds();
    final ok = await widget.onSave(updated);
    if (!mounted) return;

    setState(() => _isSaving = false);
    if (ok) {
      Navigator.of(context).pop(true);
    }
  }

  List<DeviceDetailThresholdViewModel> _buildUpdatedThresholds() {
    final defaults = buildDefaultDeviceDetailThresholdResources();
    return defaults
        .map(
          (item) => DeviceDetailThresholdViewModel(
            metric: item.metric,
            label: item.label,
            value: _values[item.metric] ?? item.value,
            unit: item.unit,
            enabled: true,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildUpdatedThresholds();

    return Dialog(
      insetPadding: const EdgeInsets.all(14),
      backgroundColor: const Color(0xFF070809),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.07),
                  minimumSize: const Size(30, 30),
                  maximumSize: const Size(30, 30),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 400,
              child: Row(
                children: items
                    .map(
                      (item) => Expanded(
                        child: _ThresholdEditorColumn(
                          label: item.label,
                          unit: item.unit,
                          value: item.value,
                          min: _configFor(item.metric).min,
                          max: _configFor(item.metric).max,
                          step: _configFor(item.metric).step,
                          onChanged: (next) {
                            setState(() {
                              _values[item.metric] = next;
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _resetValues,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.devices_thresholds_reset),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveValues,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : Text(AppLocalizations.of(context)!.devices_thresholds_save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ({double min, double max, double step, double defaultValue}) _configFor(MetricThreshold metric) {
    switch (metric) {
      case MetricThreshold.pm25:
        return (min: 1, max: 250, step: 1, defaultValue: 60);
      case MetricThreshold.co2:
        return (min: 100, max: 5000, step: 10, defaultValue: 1000);
      case MetricThreshold.temperature:
        return (min: 5, max: 60, step: 0.1, defaultValue: 28.7);
      case MetricThreshold.humidity:
        return (min: 1, max: 100, step: 1, defaultValue: 80);
    }
  }
}

class _ThresholdEditorColumn extends StatelessWidget {
  final String label;
  final String unit;
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;

  const _ThresholdEditorColumn({
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 10),
          Text(
            _formatValue(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.devices_thresholds_max,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _VerticalThresholdSlider(
              value: value,
              min: min,
              max: max,
              step: step,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    final s = value.toStringAsFixed(2);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

class _VerticalThresholdSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;

  const _VerticalThresholdSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const sliderHeight = 240.0;
    const sliderWidth = 32.0;
    const trackWidth = 3.0;
    const thumbWidth = 24.0;
    const thumbHeight = 6.0;

    double clampValue(double input) {
      if (input < min) return min;
      if (input > max) return max;
      return input;
    }

    double roundToStep(double input) {
      final stepped = (input / step).round() * step;
      final decimals = step < 1 ? 2 : 0;
      final clamped = clampValue(stepped);
      return double.parse(clamped.toStringAsFixed(decimals));
    }

    void updateFromDy(double localDy) {
      final clamped = localDy.clamp(0, sliderHeight);
      final progressFromTop = clamped / sliderHeight;
      final rawValue = max - ((max - min) * progressFromTop);
      onChanged(roundToStep(rawValue));
    }

    final ratio = (value - min) / (max - min);
    final thumbY = (1 - ratio) * sliderHeight;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) => updateFromDy(details.localPosition.dy),
      onTapDown: (details) => updateFromDy(details.localPosition.dy),
      child: SizedBox(
        width: sliderWidth,
        height: sliderHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: trackWidth,
                height: thumbY,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Positioned(
              top: thumbY,
              child: Container(
                width: trackWidth,
                height: sliderHeight - thumbY,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D18F),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Positioned(
              top: thumbY - (thumbHeight / 2),
              child: Container(
                width: thumbWidth,
                height: thumbHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D18F),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
