class Aqi {
  final double value;
  final String category;

  const Aqi._(this.value, this.category);

  factory Aqi(double value, String category) {
    if (!value.isFinite || value < 0) {
      throw ArgumentError('AQI value must be a non-negative finite number');
    }
    if (category.trim().isEmpty) {
      throw ArgumentError('AQI category cannot be empty');
    }
    return Aqi._(value, category.trim());
  }
}
