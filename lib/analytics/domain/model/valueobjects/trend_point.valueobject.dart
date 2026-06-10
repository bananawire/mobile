class TrendPoint {
  final String timestamp;
  final double aqiValue;
  final double co2;
  final double pm2_5;
  final double temperature;
  final double humidity;

  const TrendPoint._(
    this.timestamp,
    this.aqiValue,
    this.co2,
    this.pm2_5,
    this.temperature,
    this.humidity,
  );

  factory TrendPoint({
    required String timestamp,
    required double aqiValue,
    required double co2,
    required double pm2_5,
    required double temperature,
    required double humidity,
  }) {
    if (timestamp.trim().isEmpty) {
      throw ArgumentError('Timestamp cannot be empty');
    }
    if (!aqiValue.isFinite) throw ArgumentError('aqiValue must be a finite number');
    if (!co2.isFinite) throw ArgumentError('co2 must be a finite number');
    if (!pm2_5.isFinite) throw ArgumentError('pm2_5 must be a finite number');
    if (!temperature.isFinite) throw ArgumentError('temperature must be a finite number');
    if (!humidity.isFinite) throw ArgumentError('humidity must be a finite number');

    return TrendPoint._(
      timestamp.trim(),
      aqiValue,
      co2,
      pm2_5,
      temperature,
      humidity,
    );
  }
}
