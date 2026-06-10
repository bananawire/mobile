class DashboardMetricsResource {
  final double aqiValue;
  final String aqiCategory;
  final double averageCo2;
  final double averagePm2_5;
  final double averageTemperature;
  final double averageHumidity;
  final double? co2DeltaPercentage;
  final double? pm2_5DeltaPercentage;
  final double? temperatureDeltaPercentage;
  final double? humidityDeltaPercentage;
  final String calculatedAt;

  const DashboardMetricsResource({
    required this.aqiValue,
    required this.aqiCategory,
    required this.averageCo2,
    required this.averagePm2_5,
    required this.averageTemperature,
    required this.averageHumidity,
    required this.co2DeltaPercentage,
    required this.pm2_5DeltaPercentage,
    required this.temperatureDeltaPercentage,
    required this.humidityDeltaPercentage,
    required this.calculatedAt,
  });

  factory DashboardMetricsResource.fromJson(Map<String, dynamic> json) {
    return DashboardMetricsResource(
      aqiValue: _asDouble(json['aqiValue']),
      aqiCategory: (json['aqiCategory'] ?? 'No measurements').toString(),
      averageCo2: _asDouble(json['averageCo2']),
      averagePm2_5: _asDouble(json['averagePm2_5']),
      averageTemperature: _asDouble(json['averageTemperature']),
      averageHumidity: _asDouble(json['averageHumidity']),
      co2DeltaPercentage: _asNullableDouble(json['co2DeltaPercentage']),
      pm2_5DeltaPercentage: _asNullableDouble(json['pm2_5DeltaPercentage']),
      temperatureDeltaPercentage: _asNullableDouble(json['temperatureDeltaPercentage']),
      humidityDeltaPercentage: _asNullableDouble(json['humidityDeltaPercentage']),
      calculatedAt: (json['calculatedAt'] ?? '').toString(),
    );
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _asNullableDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
