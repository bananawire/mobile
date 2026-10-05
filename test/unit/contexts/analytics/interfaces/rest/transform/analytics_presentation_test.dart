import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';

import '../../../analytics_fixtures.dart';

void main() {
  group('getAqiColor', () {
    test('should render a missing reading as muted', () {
      // Arrange / Act
      final color = getAqiColor(null);

      // Assert
      expect(color, kMutedColor);
    });

    test('should bucket the value at the top of the good range as good', () {
      // Arrange / Act
      final color = getAqiColor(50);

      // Assert
      expect(color, kGoodColor);
    });

    test('should bucket the value just above the good range as moderate', () {
      // Arrange / Act
      final color = getAqiColor(50.1);

      // Assert
      expect(color, kModerateColor);
    });

    test('should bucket the value at the top of the moderate range as moderate',
        () {
      // Arrange / Act
      final color = getAqiColor(100);

      // Assert
      expect(color, kModerateColor);
    });

    test('should bucket the value just above the moderate range as sensitive',
        () {
      // Arrange / Act
      final color = getAqiColor(100.1);

      // Assert
      expect(color, kSensitiveColor);
    });

    test('should bucket the value at the top of the sensitive range as '
        'sensitive', () {
      // Arrange / Act
      final color = getAqiColor(150);

      // Assert
      expect(color, kSensitiveColor);
    });

    test('should bucket any value above the sensitive range as unhealthy', () {
      // Arrange / Act
      final color = getAqiColor(150.1);

      // Assert
      expect(color, kUnhealthyColor);
    });

    test('should bucket a hazardous reading as unhealthy', () {
      // Arrange / Act
      final color = getAqiColor(500);

      // Assert
      expect(color, kUnhealthyColor);
    });
  });

  group('getPm25StatusColor', () {
    test('should render a missing reading as muted', () {
      // Arrange / Act
      final color = getPm25StatusColor(null);

      // Assert
      expect(color, kMutedColor);
    });

    test('should bucket the value at the top of the good range as good', () {
      // Arrange / Act
      final color = getPm25StatusColor(25);

      // Assert
      expect(color, kGoodColor);
    });

    test('should bucket the value just above the good range as moderate', () {
      // Arrange / Act
      final color = getPm25StatusColor(25.1);

      // Assert
      expect(color, kModerateColor);
    });

    test('should bucket the value at the WHO guideline limit as moderate', () {
      // Arrange / Act
      final color = getPm25StatusColor(35.4);

      // Assert
      expect(color, kModerateColor);
    });

    test('should bucket the value at the top of the moderate range as moderate',
        () {
      // Arrange / Act
      final color = getPm25StatusColor(60);

      // Assert
      expect(color, kModerateColor);
    });

    test('should bucket the value just above the moderate range as unhealthy',
        () {
      // Arrange / Act
      final color = getPm25StatusColor(60.1);

      // Assert
      expect(color, kUnhealthyColor);
    });
  });

  group('getCo2StatusColor', () {
    test('should render a missing reading as muted', () {
      // Arrange / Act
      final color = getCo2StatusColor(null);

      // Assert
      expect(color, kMutedColor);
    });

    test('should bucket the value at the top of the good range as good', () {
      // Arrange / Act
      final color = getCo2StatusColor(700);

      // Assert
      expect(color, kGoodColor);
    });

    test('should bucket the value just above the good range as moderate', () {
      // Arrange / Act
      final color = getCo2StatusColor(700.1);

      // Assert
      expect(color, kModerateColor);
    });

    test('should bucket the value at the top of the moderate range as moderate',
        () {
      // Arrange / Act
      final color = getCo2StatusColor(1000);

      // Assert
      expect(color, kModerateColor);
    });

    test('should bucket the value just above the moderate range as unhealthy',
        () {
      // Arrange / Act
      final color = getCo2StatusColor(1000.1);

      // Assert
      expect(color, kUnhealthyColor);
    });
  });

  group('getTempStatusColor', () {
    test('should render a missing reading as muted', () {
      // Arrange / Act
      final color = getTempStatusColor(null);

      // Assert
      expect(color, kMutedColor);
    });

    test('should bucket the value at the comfort threshold as good', () {
      // Arrange / Act
      final color = getTempStatusColor(26);

      // Assert
      expect(color, kGoodColor);
    });

    test('should bucket the value just above the comfort threshold as '
        'unhealthy', () {
      // Arrange / Act
      final color = getTempStatusColor(26.1);

      // Assert
      expect(color, kUnhealthyColor);
    });

    test('should bucket a sub-zero reading as good', () {
      // Arrange / Act
      final color = getTempStatusColor(-10);

      // Assert
      expect(color, kGoodColor);
    });
  });

  group('getHumidityStatusColor', () {
    test('should render a missing reading as muted', () {
      // Arrange / Act
      final color = getHumidityStatusColor(null);

      // Assert
      expect(color, kMutedColor);
    });

    test('should bucket the value at the top of the good range as good', () {
      // Arrange / Act
      final color = getHumidityStatusColor(60);

      // Assert
      expect(color, kGoodColor);
    });

    test('should bucket the value just above the good range as moderate', () {
      // Arrange / Act
      final color = getHumidityStatusColor(60.1);

      // Assert
      expect(color, kModerateColor);
    });

    test('should bucket the value at the top of the moderate range as moderate',
        () {
      // Arrange / Act
      final color = getHumidityStatusColor(85);

      // Assert
      expect(color, kModerateColor);
    });

    test('should bucket the value just above the moderate range as unhealthy',
        () {
      // Arrange / Act
      final color = getHumidityStatusColor(85.1);

      // Assert
      expect(color, kUnhealthyColor);
    });
  });

  group('formatDelta', () {
    test('should render a missing percentage as not available', () {
      // Arrange / Act
      final text = formatDelta(null);

      // Assert
      expect(text, 'N/A');
    });

    test('should render an infinite percentage as not available', () {
      // Arrange / Act
      final text = formatDelta(double.infinity);

      // Assert
      expect(text, 'N/A');
    });

    test('should render a NaN percentage as not available', () {
      // Arrange / Act
      final text = formatDelta(double.nan);

      // Assert
      expect(text, 'N/A');
    });

    test('should render a zero percentage with one decimal place', () {
      // Arrange / Act
      final text = formatDelta(0);

      // Assert
      expect(text, '0.0%');
    });

    test('should render a rising percentage with one decimal place', () {
      // Arrange / Act
      final text = formatDelta(12.34);

      // Assert
      expect(text, '12.3%');
    });

    test('should render a falling percentage as its absolute magnitude so the '
        'arrow carries the direction', () {
      // Arrange / Act
      final text = formatDelta(-12.34);

      // Assert
      expect(text, '12.3%');
    });

    test('should render a percentage above one hundred without clamping', () {
      // Arrange / Act
      final text = formatDelta(150);

      // Assert
      expect(text, '150.0%');
    });
  });

  group('formatValue', () {
    test('should render a missing value as a placeholder', () {
      // Arrange / Act
      final text = formatValue(null);

      // Assert
      expect(text, '--');
    });

    test('should render an infinite value as a placeholder', () {
      // Arrange / Act
      final text = formatValue(double.infinity);

      // Assert
      expect(text, '--');
    });

    test('should render a NaN value as a placeholder', () {
      // Arrange / Act
      final text = formatValue(double.nan);

      // Assert
      expect(text, '--');
    });

    test('should render a zero reading with two decimal places', () {
      // Arrange / Act
      final text = formatValue(0);

      // Assert
      expect(text, '0.00');
    });

    test('should round a reading to two decimal places', () {
      // Arrange / Act
      final text = formatValue(12.3456);

      // Assert
      expect(text, '12.35');
    });

    test('should render a large reading without a unit suffix', () {
      // Arrange / Act
      final text = formatValue(1234.5);

      // Assert
      expect(text, '1234.50');
    });
  });

  group('getMetricValue', () {
    test('should read the AQI field when the metric is aqiValue', () {
      // Arrange
      final point = buildTrendPoint(aqiValue: 42);

      // Act
      final value = getMetricValue(point, 'aqiValue');

      // Assert
      expect(value, 42);
    });

    test('should read the CO2 field when the metric is co2', () {
      // Arrange
      final point = buildTrendPoint(aqiValue: 42, co2: 612);

      // Act
      final value = getMetricValue(point, 'co2');

      // Assert
      expect(value, 612);
    });

    test('should read the PM2.5 field when the metric is pm2_5', () {
      // Arrange
      final point = buildTrendPoint(aqiValue: 42, pm2_5: 8.4);

      // Act
      final value = getMetricValue(point, 'pm2_5');

      // Assert
      expect(value, 8.4);
    });

    test('should read the temperature field when the metric is temperature',
        () {
      // Arrange
      final point = buildTrendPoint(temperature: 21.6);

      // Act
      final value = getMetricValue(point, 'temperature');

      // Assert
      expect(value, 21.6);
    });

    test('should read the humidity field when the metric is humidity', () {
      // Arrange
      final point = buildTrendPoint(humidity: 48.2);

      // Act
      final value = getMetricValue(point, 'humidity');

      // Assert
      expect(value, 48.2);
    });

    test('should fall back to the AQI field for an unknown metric so an '
        'unexpected selection still renders', () {
      // Arrange
      final point = buildTrendPoint(aqiValue: 42, co2: 612);

      // Act
      final value = getMetricValue(point, 'unknownMetric');

      // Assert
      expect(value, 42);
    });
  });

  group('calculateAqiFromPm25', () {
    test('should map a clean reading to the top of the good category', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(12.0);

      // Assert
      expect(result.value, 50);
      expect(result.category, 'Good');
    });

    test('should map a zero reading to a zero AQI', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(0);

      // Assert
      expect(result.value, 0);
      expect(result.category, 'Good');
    });

    test('should map the value just above the good breakpoint to moderate', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(12.1);

      // Assert
      expect(result.value, 51);
      expect(result.category, 'Moderate');
    });

    test('should map a mid-range reading to the middle of moderate', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(20);

      // Assert
      expect(result.value, 68);
      expect(result.category, 'Moderate');
    });

    test('should map the value at the top of the moderate breakpoint to '
        'moderate', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(35.4);

      // Assert
      expect(result.value, 100);
      expect(result.category, 'Moderate');
    });

    test('should map the value just above the moderate breakpoint to the '
        'sensitive category', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(35.5);

      // Assert
      expect(result.value, 101);
      expect(result.category, 'Unhealthy for Sensitive');
    });

    test('should map the value at the top of the sensitive breakpoint to the '
        'sensitive category', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(55.4);

      // Assert
      expect(result.value, 150);
      expect(result.category, 'Unhealthy for Sensitive');
    });

    test('should map the value just above the sensitive breakpoint to '
        'unhealthy', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(55.5);

      // Assert
      expect(result.value, 151);
      expect(result.category, 'Unhealthy');
    });

    test('should map the value at the top of the unhealthy breakpoint to '
        'unhealthy', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(150.4);

      // Assert
      expect(result.value, 200);
      expect(result.category, 'Unhealthy');
    });

    test('should map the value just above the unhealthy breakpoint to very '
        'unhealthy', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(150.5);

      // Assert
      expect(result.value, 201);
      expect(result.category, 'Very Unhealthy');
    });

    test('should map the value at the top of the very unhealthy breakpoint to '
        'very unhealthy', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(250.4);

      // Assert
      expect(result.value, 300);
      expect(result.category, 'Very Unhealthy');
    });

    test('should map the value just above the very unhealthy breakpoint to '
        'hazardous', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(250.5);

      // Assert
      expect(result.value, 301);
      expect(result.category, 'Hazardous');
    });

    test('should map the top of the hazardous breakpoint to hazardous', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(350.4);

      // Assert
      expect(result.value, 400);
      expect(result.category, 'Hazardous');
    });

    test('should keep scaling beyond the last breakpoint so an extreme sensor '
        'reading still produces a hazardous AQI', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(500.4);

      // Assert
      expect(result.value, 500);
      expect(result.category, 'Hazardous');
    });

    test('should pick the colour bucket matching the derived category', () {
      // Arrange
      final hazardous = calculateAqiFromPm25(300);

      // Act
      final color = getAqiColor(hazardous.value);

      // Assert
      expect(hazardous.category, 'Hazardous');
      expect(color, kUnhealthyColor);
    });

    test('should return a negative AQI for a negative reading because the '
        'conversion does not clamp its input', () {
      // Arrange / Act
      final result = calculateAqiFromPm25(-5);

      // Assert
      expect(result.value, lessThan(0));
      expect(result.category, 'Good');
    });
  });

  group('getActiveMetricDelta', () {
    test('should return null when there is no live snapshot yet', () {
      // Arrange / Act
      final delta = getActiveMetricDelta(null, 'aqiValue');

      // Assert
      expect(delta, isNull);
    });

    test('should surface the PM2.5 delta for the AQI selection as the web app '
        'does', () {
      // Arrange
      final metrics = buildDashboardMetrics();

      // Act
      final delta = getActiveMetricDelta(metrics, 'aqiValue');

      // Assert
      expect(delta, -12.25);
    });

    test('should surface the CO2 delta for the co2 selection', () {
      // Arrange
      final metrics = buildDashboardMetrics();

      // Act
      final delta = getActiveMetricDelta(metrics, 'co2');

      // Assert
      expect(delta, 3.5);
    });

    test('should surface the PM2.5 delta for the pm2_5 selection', () {
      // Arrange
      final metrics = buildDashboardMetrics();

      // Act
      final delta = getActiveMetricDelta(metrics, 'pm2_5');

      // Assert
      expect(delta, -12.25);
    });

    test('should surface a null temperature delta when the metric has no '
        'comparison period', () {
      // Arrange
      final metrics = buildDashboardMetrics();

      // Act
      final delta = getActiveMetricDelta(metrics, 'temperature');

      // Assert
      expect(delta, isNull);
    });

    test('should surface the humidity delta for the humidity selection', () {
      // Arrange
      final metrics = buildDashboardMetrics();

      // Act
      final delta = getActiveMetricDelta(metrics, 'humidity');

      // Assert
      expect(delta, 0);
    });

    test('should return null for an unknown metric selection', () {
      // Arrange
      final metrics = buildDashboardMetrics();

      // Act
      final delta = getActiveMetricDelta(metrics, 'unknownMetric');

      // Assert
      expect(delta, isNull);
    });
  });

  group('severity palette', () {
    test('should expose the distinct colours the cards rely on', () {
      // Assert
      expect(
        <Color>{kGoodColor, kModerateColor, kSensitiveColor, kUnhealthyColor},
        hasLength(4),
      );
      expect(kMutedColor, isNot(anyOf(kGoodColor, kUnhealthyColor)));
    });
  });

  group('getMetricValue with an unknown metric constant', () {
    test('should never throw for any metric string so a chart can always '
        'render', () {
      // Arrange
      final point = buildTrendPoint();

      // Act / Assert
      expect(() => getMetricValue(point, ''), returnsNormally);
      expect(getMetricValue(point, ''), 42);
    });
  });

  group('Color helper contract', () {
    test('should accept a nullable reading on every status helper', () {
      // Arrange / Act / Assert
      expect(getAqiColor(null), kMutedColor);
      expect(getPm25StatusColor(null), kMutedColor);
      expect(getCo2StatusColor(null), kMutedColor);
      expect(getTempStatusColor(null), kMutedColor);
      expect(getHumidityStatusColor(null), kMutedColor);
    });
  });
}