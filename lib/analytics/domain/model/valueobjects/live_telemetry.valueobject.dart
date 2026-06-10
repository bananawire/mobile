class LiveTelemetry {
  final String deviceId;
  final double co2;
  final double pm2_5;
  final double temperature;
  final double humidity;
  final String timestamp;

  const LiveTelemetry({
    required this.deviceId,
    required this.co2,
    required this.pm2_5,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  factory LiveTelemetry.fromJson(Map<String, dynamic> json, String fallbackDeviceId) {
    return LiveTelemetry(
      deviceId: (json['deviceId'] ?? fallbackDeviceId).toString(),
      co2: _asDouble(json['co2']),
      pm2_5: _asDouble(json['pm2_5']),
      temperature: _asDouble(json['temperature']),
      humidity: _asDouble(json['humidity']),
      timestamp: (json['timestamp'] ?? DateTime.now().toUtc().toIso8601String()).toString(),
    );
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
