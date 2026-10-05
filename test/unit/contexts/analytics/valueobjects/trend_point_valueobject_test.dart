import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';

void main() {
  group('TrendPoint', () {
    test('should keep every reading and the timestamp as provided', () {
      // Arrange
      const timestamp = '2024-05-01T09:00:00Z';

      // Act
      final point = TrendPoint(
        timestamp: timestamp,
        aqiValue: 42,
        co2: 612,
        pm2_5: 8.4,
        temperature: 21.6,
        humidity: 48.2,
      );

      // Assert
      expect(point.timestamp, timestamp);
      expect(point.aqiValue, 42);
      expect(point.co2, 612);
      expect(point.pm2_5, 8.4);
      expect(point.temperature, 21.6);
      expect(point.humidity, 48.2);
    });

    test('should trim surrounding whitespace from the timestamp', () {
      // Arrange
      const raw = '  2024-05-01T09:00:00Z  ';

      // Act
      final point = TrendPoint(
        timestamp: raw,
        aqiValue: 0,
        co2: 0,
        pm2_5: 0,
        temperature: 0,
        humidity: 0,
      );

      // Assert
      expect(point.timestamp, '2024-05-01T09:00:00Z');
    });

    test('should keep the stored timestamp as an opaque string so points can '
        'be sorted by the caller', () {
      // Arrange
      final points = <TrendPoint>[
        TrendPoint(
          timestamp: '2024-05-03T09:00:00Z',
          aqiValue: 3,
          co2: 0,
          pm2_5: 0,
          temperature: 0,
          humidity: 0,
        ),
        TrendPoint(
          timestamp: '2024-05-01T09:00:00Z',
          aqiValue: 1,
          co2: 0,
          pm2_5: 0,
          temperature: 0,
          humidity: 0,
        ),
      ];

      // Act
      final byTimestamp = [...points]
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Assert
      expect(byTimestamp.first.aqiValue, 1);
      expect(byTimestamp.last.aqiValue, 3);
    });

    test('should accept negative readings for metrics that allow them', () {
      // Arrange / Act
      final point = TrendPoint(
        timestamp: '2024-05-01T09:00:00Z',
        aqiValue: -1,
        co2: -5,
        pm2_5: 0,
        temperature: -12.5,
        humidity: 0,
      );

      // Assert
      expect(point.aqiValue, -1);
      expect(point.co2, -5);
      expect(point.temperature, -12.5);
    });

    test('should accept a non-ISO timestamp verbatim because it is only '
        'validated for emptiness', () {
      // Arrange
      const opaque = 'not-a-date';

      // Act
      final point = TrendPoint(
        timestamp: opaque,
        aqiValue: 1,
        co2: 1,
        pm2_5: 1,
        temperature: 1,
        humidity: 1,
      );

      // Assert
      expect(point.timestamp, opaque);
    });

    test('should throw an ArgumentError when the timestamp is empty', () {
      // Act / Assert
      expect(
        () => TrendPoint(
          timestamp: '',
          aqiValue: 1,
          co2: 1,
          pm2_5: 1,
          temperature: 1,
          humidity: 1,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Timestamp cannot be empty',
          ),
        ),
      );
    });

    test('should throw an ArgumentError when the timestamp is only whitespace',
        () {
      // Act / Assert
      expect(
        () => TrendPoint(
          timestamp: '   ',
          aqiValue: 1,
          co2: 1,
          pm2_5: 1,
          temperature: 1,
          humidity: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw an ArgumentError when aqiValue is not finite', () {
      // Act / Assert
      expect(
        () => TrendPoint(
          timestamp: '2024-05-01T09:00:00Z',
          aqiValue: double.nan,
          co2: 1,
          pm2_5: 1,
          temperature: 1,
          humidity: 1,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'aqiValue must be a finite number',
          ),
        ),
      );
    });

    test('should throw an ArgumentError when co2 is not finite', () {
      // Act / Assert
      expect(
        () => TrendPoint(
          timestamp: '2024-05-01T09:00:00Z',
          aqiValue: 1,
          co2: double.infinity,
          pm2_5: 1,
          temperature: 1,
          humidity: 1,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'co2 must be a finite number',
          ),
        ),
      );
    });

    test('should throw an ArgumentError when pm2_5 is not finite', () {
      // Act / Assert
      expect(
        () => TrendPoint(
          timestamp: '2024-05-01T09:00:00Z',
          aqiValue: 1,
          co2: 1,
          pm2_5: double.nan,
          temperature: 1,
          humidity: 1,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'pm2_5 must be a finite number',
          ),
        ),
      );
    });

    test('should throw an ArgumentError when temperature is not finite', () {
      // Act / Assert
      expect(
        () => TrendPoint(
          timestamp: '2024-05-01T09:00:00Z',
          aqiValue: 1,
          co2: 1,
          pm2_5: 1,
          temperature: double.nan,
          humidity: 1,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'temperature must be a finite number',
          ),
        ),
      );
    });

    test('should throw an ArgumentError when humidity is not finite', () {
      // Act / Assert
      expect(
        () => TrendPoint(
          timestamp: '2024-05-01T09:00:00Z',
          aqiValue: 1,
          co2: 1,
          pm2_5: 1,
          temperature: 1,
          humidity: double.nan,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'humidity must be a finite number',
          ),
        ),
      );
    });
  });
}