import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/domain/model/valueobjects/live_telemetry.valueobject.dart';

void main() {
  group('LiveTelemetry', () {
    test('should map a complete SSE frame onto the value object', () {
      // Arrange
      final json = <String, dynamic>{
        'deviceId': 'device-42',
        'co2': 700,
        'pm2_5': 12.5,
        'temperature': 22.5,
        'humidity': 55,
        'timestamp': '2024-05-01T10:00:00Z',
      };

      // Act
      final telemetry = LiveTelemetry.fromJson(json, 'fallback-device');

      // Assert
      expect(telemetry.deviceId, 'device-42');
      expect(telemetry.co2, 700);
      expect(telemetry.pm2_5, 12.5);
      expect(telemetry.temperature, 22.5);
      expect(telemetry.humidity, 55);
      expect(telemetry.timestamp, '2024-05-01T10:00:00Z');
    });

    test('should fall back to the subscribed device id when the frame omits '
        'it', () {
      // Arrange
      const fallback = 'device-from-stream';
      final json = <String, dynamic>{
        'co2': 700,
        'pm2_5': 12.5,
        'temperature': 22.5,
        'humidity': 55,
        'timestamp': '2024-05-01T10:00:00Z',
      };

      // Act
      final telemetry = LiveTelemetry.fromJson(json, fallback);

      // Assert
      expect(telemetry.deviceId, fallback);
    });

    test('should stringify a non-string device id instead of dropping it', () {
      // Arrange
      final json = <String, dynamic>{'deviceId': 42};

      // Act
      final telemetry = LiveTelemetry.fromJson(json, 'fallback');

      // Assert
      expect(telemetry.deviceId, '42');
    });

    test('should convert numeric strings to doubles', () {
      // Arrange
      final json = <String, dynamic>{
        'co2': '812.5',
        'pm2_5': '13',
        'temperature': '21.4',
        'humidity': '60',
      };

      // Act
      final telemetry = LiveTelemetry.fromJson(json, 'device-1');

      // Assert
      expect(telemetry.co2, 812.5);
      expect(telemetry.pm2_5, 13.0);
      expect(telemetry.temperature, 21.4);
      expect(telemetry.humidity, 60.0);
    });

    test('should coerce malformed readings to zero instead of breaking the '
        'live stream', () {
      // Arrange
      final json = <String, dynamic>{
        'co2': 'not-a-number',
        'pm2_5': null,
        'temperature': <String>[],
        'humidity': '',
      };

      // Act
      final telemetry = LiveTelemetry.fromJson(json, 'device-1');

      // Assert
      expect(telemetry.co2, 0);
      expect(telemetry.pm2_5, 0);
      expect(telemetry.temperature, 0);
      expect(telemetry.humidity, 0);
    });

    test('should default every reading to zero when the frame is empty', () {
      // Arrange
      const json = <String, dynamic>{};

      // Act
      final telemetry = LiveTelemetry.fromJson(json, 'device-1');

      // Assert
      expect(telemetry.co2, 0);
      expect(telemetry.pm2_5, 0);
      expect(telemetry.temperature, 0);
      expect(telemetry.humidity, 0);
    });

    test('should stamp a current UTC timestamp when the frame omits one', () {
      // Arrange
      const json = <String, dynamic>{};
      final before = DateTime.now().toUtc();

      // Act
      final telemetry = LiveTelemetry.fromJson(json, 'device-1');

      // Assert
      final stamped = DateTime.parse(telemetry.timestamp);
      expect(stamped.isUtc, isTrue);
      expect(
        stamped.isBefore(before.subtract(const Duration(minutes: 1))),
        isFalse,
      );
    });

    test('should preserve a negative reading for temperature deltas below '
        'zero', () {
      // Arrange
      final json = <String, dynamic>{'temperature': -8.5};

      // Act
      final telemetry = LiveTelemetry.fromJson(json, 'device-1');

      // Assert
      expect(telemetry.temperature, -8.5);
    });
  });
}