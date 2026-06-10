class TrendDataPointResource {
  final String timestamp;
  final double aqiValue;
  final double co2;
  final double pm2_5;
  final double temperature;
  final double humidity;

  const TrendDataPointResource({
    required this.timestamp,
    required this.aqiValue,
    required this.co2,
    required this.pm2_5,
    required this.temperature,
    required this.humidity,
  });

  factory TrendDataPointResource.fromJson(Map<String, dynamic> json) {
    return TrendDataPointResource(
      timestamp: (json['timestamp'] ?? '').toString(),
      aqiValue: _asDouble(json['aqiValue']),
      co2: _asDouble(json['co2']),
      pm2_5: _asDouble(json['pm2_5']),
      temperature: _asDouble(json['temperature']),
      humidity: _asDouble(json['humidity']),
    );
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class TrendsResource {
  final List<TrendDataPointResource> dataPoints;

  const TrendsResource({required this.dataPoints});

  factory TrendsResource.fromJson(Map<String, dynamic> json) {
    final raw = json['dataPoints'];
    final points = <TrendDataPointResource>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          points.add(TrendDataPointResource.fromJson(item));
        }
      }
    }
    return TrendsResource(dataPoints: points);
  }
}
