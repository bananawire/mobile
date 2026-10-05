import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/interfaces/rest/resources/trends.resource.dart';

import '../../../analytics_fixtures.dart';

void main() {
  group('TrendDataPointResource.fromJson', () {
    test('should map every field of a well-formed payload', () {
      // Arrange
      final json = trendPointJson(
        timestamp: '2024-05-01T09:15:00Z',
        aqiValue: 128.5,
        co2: 812.25,
        pm2_5: 47.9,
        temperature: 24.75,
        humidity: 63,
      );

      // Act
      final resource = TrendDataPointResource.fromJson(json);

      // Assert
      expect(resource.timestamp, '2024-05-01T09:15:00Z');
      expect(resource.aqiValue, 128.5);
      expect(resource.co2, 812.25);
      expect(resource.pm2_5, 47.9);
      expect(resource.temperature, 24.75);
      expect(resource.humidity, 63.0);
    });

    test('should convert integer readings to doubles', () {
      // Arrange
      final json = trendPointJson(
        aqiValue: 42,
        co2: 612,
        pm2_5: 8,
        temperature: 21,
        humidity: 48,
      );

      // Act
      final resource = TrendDataPointResource.fromJson(json);

      // Assert
      expect(resource.aqiValue, 42.0);
      expect(resource.co2, 612.0);
      expect(resource.pm2_5, 8.0);
      expect(resource.temperature, 21.0);
      expect(resource.humidity, 48.0);
    });

    test('should parse numeric strings sent by the backend', () {
      // Arrange
      final json = trendPointJson(aqiValue: '42.5', pm2_5: '8');

      // Act
      final resource = TrendDataPointResource.fromJson(json);

      // Assert
      expect(resource.aqiValue, 42.5);
      expect(resource.pm2_5, 8.0);
    });

    test('should fall back to zero for unparsable readings', () {
      // Arrange
      final json = trendPointJson(co2: 'n/a', temperature: null);

      // Act
      final resource = TrendDataPointResource.fromJson(json);

      // Assert
      expect(resource.co2, 0);
      expect(resource.temperature, 0);
    });

    test('should default the timestamp to an empty string when it is missing',
        () {
      // Arrange
      final json = trendPointJson(timestamp: null);

      // Act
      final resource = TrendDataPointResource.fromJson(json);

      // Assert
      expect(resource.timestamp, '');
    });
  });

  group('TrendsResource.fromJson', () {
    test('should map the nested data-point series in payload order', () {
      // Arrange
      final json = trendsJson(dataPoints: <dynamic>[
        trendPointJson(timestamp: '2024-05-01T09:00:00Z', aqiValue: 10),
        trendPointJson(timestamp: '2024-05-01T09:05:00Z', aqiValue: 20),
        trendPointJson(timestamp: '2024-05-01T09:10:00Z', aqiValue: 30),
      ]);

      // Act
      final resource = TrendsResource.fromJson(json);

      // Assert
      expect(resource.dataPoints, hasLength(3));
      expect(
        resource.dataPoints.map((p) => p.aqiValue).toList(),
        <double>[10, 20, 30],
      );
      expect(resource.dataPoints.first.timestamp, '2024-05-01T09:00:00Z');
    });

    test('should return an empty series when there are no data points', () {
      // Arrange
      final json = trendsJson(dataPoints: <dynamic>[]);

      // Act
      final resource = TrendsResource.fromJson(json);

      // Assert
      expect(resource.dataPoints, isEmpty);
    });

    test('should return an empty series when the payload omits the series',
        () {
      // Arrange
      final json = trendsJson();

      // Act
      final resource = TrendsResource.fromJson(json);

      // Assert
      expect(resource.dataPoints, isEmpty);
    });

    test('should return an empty series when the series is not a list', () {
      // Arrange
      final json = <String, dynamic>{'dataPoints': 'nope'};

      // Act
      final resource = TrendsResource.fromJson(json);

      // Assert
      expect(resource.dataPoints, isEmpty);
    });

    test('should skip series entries that are not JSON objects', () {
      // Arrange
      final json = trendsJson(dataPoints: <dynamic>[
        trendPointJson(aqiValue: 10),
        'garbage',
        42,
        <dynamic, dynamic>{'aqiValue': 99},
      ]);

      // Act
      final resource = TrendsResource.fromJson(json);

      // Assert
      expect(resource.dataPoints, hasLength(1));
      expect(resource.dataPoints.single.aqiValue, 10);
    });
  });
}