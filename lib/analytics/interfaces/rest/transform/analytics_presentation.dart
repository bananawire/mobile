import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/analytics/domain/model/valueobjects/dashboard_metrics.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';

const Color kMutedColor = Color(0xFF3A3A3C);
const Color kGoodColor = Color(0xFF10B981);
const Color kModerateColor = Color(0xFFF59E0B);
const Color kSensitiveColor = Color(0xFFF97316);
const Color kUnhealthyColor = Color(0xFFEF4444);

Color getAqiColor(double? value) {
  if (value == null) return kMutedColor;
  if (value <= 50) return kGoodColor;
  if (value <= 100) return kModerateColor;
  if (value <= 150) return kSensitiveColor;
  return kUnhealthyColor;
}

Color getPm25StatusColor(double? value) {
  if (value == null) return kMutedColor;
  if (value <= 25) return kGoodColor;
  if (value <= 60) return kModerateColor;
  return kUnhealthyColor;
}

Color getCo2StatusColor(double? value) {
  if (value == null) return kMutedColor;
  if (value <= 700) return kGoodColor;
  if (value <= 1000) return kModerateColor;
  return kUnhealthyColor;
}

Color getTempStatusColor(double? value) {
  if (value == null) return kMutedColor;
  if (value <= 26) return kGoodColor;
  return kUnhealthyColor;
}

Color getHumidityStatusColor(double? value) {
  if (value == null) return kMutedColor;
  if (value <= 60) return kGoodColor;
  if (value <= 85) return kModerateColor;
  return kUnhealthyColor;
}

/// Absolute delta as "X.X%" / "N/A".
String formatDelta(double? delta) {
  if (delta == null || !delta.isFinite) return 'N/A';
  return '${delta.abs().toStringAsFixed(1)}%';
}

/// Metric value as "X.XX" / "--".
String formatValue(double? value) {
  if (value == null || !value.isFinite) return '--';
  return value.toStringAsFixed(2);
}

String formatUpdateTime(BuildContext context, int secondsSinceUpdate) {
  final l10n = AppLocalizations.of(context)!;
  if (secondsSinceUpdate < 5) return l10n.time_just_now;
  return l10n.time_seconds_ago(secondsSinceUpdate);
}

double getMetricValue(TrendPoint point, String metric) {
  switch (metric) {
    case 'co2':
      return point.co2;
    case 'pm2_5':
      return point.pm2_5;
    case 'temperature':
      return point.temperature;
    case 'humidity':
      return point.humidity;
    case 'aqiValue':
    default:
      return point.aqiValue;
  }
}

/// US EPA AQI from a PM2.5 reading (µg/m³). Ported from the web app so the
/// SSE telemetry stream (which carries raw pollutants, not an AQI) can render.
({double value, String category}) calculateAqiFromPm25(double pm25) {
  double aqi;
  if (pm25 <= 12.0) {
    aqi = (50 / 12.0) * pm25;
  } else if (pm25 <= 35.4) {
    aqi = ((100 - 51) / (35.4 - 12.1)) * (pm25 - 12.1) + 51;
  } else if (pm25 <= 55.4) {
    aqi = ((150 - 101) / (55.4 - 35.5)) * (pm25 - 35.5) + 101;
  } else if (pm25 <= 150.4) {
    aqi = ((200 - 151) / (150.4 - 55.5)) * (pm25 - 55.5) + 151;
  } else if (pm25 <= 250.4) {
    aqi = ((300 - 201) / (250.4 - 150.5)) * (pm25 - 150.5) + 201;
  } else if (pm25 <= 350.4) {
    aqi = ((400 - 301) / (350.4 - 250.5)) * (pm25 - 250.5) + 301;
  } else {
    aqi = ((500 - 401) / (500.4 - 350.5)) * (pm25 - 350.5) + 401;
  }

  final value = aqi.roundToDouble();
  String category;
  if (value <= 50) {
    category = 'Good';
  } else if (value <= 100) {
    category = 'Moderate';
  } else if (value <= 150) {
    category = 'Unhealthy for Sensitive';
  } else if (value <= 200) {
    category = 'Unhealthy';
  } else if (value <= 300) {
    category = 'Very Unhealthy';
  } else {
    category = 'Hazardous';
  }
  return (value: value, category: category);
}

/// Mirrors the web app: aqiValue surfaces the pm2_5 delta.
double? getActiveMetricDelta(DashboardMetrics? liveData, String selectedMetric) {
  if (liveData == null) return null;
  switch (selectedMetric) {
    case 'aqiValue':
      return liveData.pm2_5.deltaPercentage;
    case 'co2':
      return liveData.co2.deltaPercentage;
    case 'pm2_5':
      return liveData.pm2_5.deltaPercentage;
    case 'temperature':
      return liveData.temperature.deltaPercentage;
    case 'humidity':
      return liveData.humidity.deltaPercentage;
    default:
      return null;
  }
}
