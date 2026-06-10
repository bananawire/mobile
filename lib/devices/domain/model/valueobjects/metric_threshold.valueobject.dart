enum MetricThreshold {
  pm25('PM2.5', 'µg/m³'),
  co2('CO2', 'ppm'),
  temperature('Temperature', '°C'),
  humidity('Humidity', '%');

  final String label;
  final String unit;

  const MetricThreshold(this.label, this.unit);

  String get apiName => name.toUpperCase();

  static MetricThreshold? fromString(String value) {
    try {
      final upper = value.toUpperCase();
      return MetricThreshold.values.firstWhere(
        (e) => e.name.toUpperCase() == upper || e.label == value,
      );
    } catch (_) {
      return null;
    }
  }
}