class MetricDelta {
  final double value;
  final double? deltaPercentage;

  const MetricDelta._(this.value, this.deltaPercentage);

  factory MetricDelta(double value, double? deltaPercentage) {
    if (!value.isFinite) {
      throw ArgumentError('Metric value must be a finite number');
    }
    if (deltaPercentage != null && !deltaPercentage.isFinite) {
      throw ArgumentError('Delta percentage must be null or a finite number');
    }
    return MetricDelta._(value, deltaPercentage);
  }
}
