enum MetricType {
  pm25('PM2.5', 'µg/m³'),
  co2('CO2', 'ppm'),
  temperature('Temperature', '°C'),
  humidity('Humidity', '%');

  final String label;
  final String unit;

  const MetricType(this.label, this.unit);

  String get apiName => name.toUpperCase();

  static MetricType? fromString(String value) {
    try {
      final upper = value.toUpperCase();

      return MetricType.values.firstWhere(
            (e) => e.apiName == upper || e.label == value,
      );
    } catch (_) {
      return null;
    }
  }
}
