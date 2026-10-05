import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/commands/write_device_threshold.command.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';
import 'package:mobile/devices/interfaces/rest/transform/device_thresholds_transform.dart';

void main() {
  group('toUpdateDeviceThresholdResource', () {
    test('should serialize the metric as its upper cased api name with value and enabled', () {
      // Arrange
      final command = WriteDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.pm25,
        value: 60.5,
        enabled: true,
        intent: DeviceThresholdWriteIntent.create,
      );

      // Act
      final resource = toUpdateDeviceThresholdResource(command);

      // Assert
      expect(resource.metric, MetricThreshold.pm25);
      expect(resource.value, 60.5);
      expect(resource.enabled, isTrue);
      expect(resource.toJson(), <String, dynamic>{
        'metric': 'PM25',
        'value': 60.5,
        'enabled': true,
      });
    });

    test('should encode every metric with its own api name', () {
      // Arrange
      final expected = <MetricThreshold, String>{
        MetricThreshold.pm25: 'PM25',
        MetricThreshold.co2: 'CO2',
        MetricThreshold.temperature: 'TEMPERATURE',
        MetricThreshold.humidity: 'HUMIDITY',
      };

      for (final entry in expected.entries) {
        final command = WriteDeviceThresholdCommand(
          deviceId: 'dev-1',
          metric: entry.key,
          value: 1,
          enabled: false,
          intent: DeviceThresholdWriteIntent.update,
        );

        // Act
        final body = toUpdateDeviceThresholdResource(command).toJson();

        // Assert
        expect(body['metric'], entry.value);
        expect(body['enabled'], isFalse);
        expect(body.keys, ['metric', 'value', 'enabled']);
      }
    });

    test('should not leak the device id or the write intent into the threshold body', () {
      // Arrange
      final command = WriteDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.co2,
        value: 900,
        enabled: true,
        intent: DeviceThresholdWriteIntent.create,
      );

      // Act
      final body = toUpdateDeviceThresholdResource(command).toJson();

      // Assert
      expect(body.containsKey('deviceId'), isFalse);
      expect(body.containsKey('intent'), isFalse);
    });
  });

  group('toWriteDeviceThresholdCommand', () {
    test('should carry every provided field into the command', () {
      // Arrange
      const deviceId = 'dev-1';

      // Act
      final command = toWriteDeviceThresholdCommand(
        deviceId: deviceId,
        metric: MetricThreshold.temperature,
        value: 28.7,
        enabled: true,
        intent: DeviceThresholdWriteIntent.update,
      );

      // Assert
      expect(command.deviceId, deviceId);
      expect(command.metric, MetricThreshold.temperature);
      expect(command.value, 28.7);
      expect(command.enabled, isTrue);
      expect(command.intent, DeviceThresholdWriteIntent.update);
    });

    test('should build a command the write service can serialize for the api', () {
      // Arrange
      final command = toWriteDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.humidity,
        value: 80,
        enabled: false,
        intent: DeviceThresholdWriteIntent.create,
      );

      // Act
      final body = toUpdateDeviceThresholdResource(command).toJson();

      // Assert
      expect(body, <String, dynamic>{'metric': 'HUMIDITY', 'value': 80.0, 'enabled': false});
    });

    test('should reject a non positive value before the command reaches a gateway', () {
      // Arrange
      const value = 0.0;

      // Act / Assert
      expect(
        () => toWriteDeviceThresholdCommand(
          deviceId: 'dev-1',
          metric: MetricThreshold.pm25,
          value: value,
          enabled: true,
          intent: DeviceThresholdWriteIntent.create,
        ),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', 'value must be greater than 0'),
        ),
      );
    });

    test('should reject a blank device id before the command reaches a gateway', () {
      // Arrange
      const deviceId = '   ';

      // Act / Assert
      expect(
        () => toWriteDeviceThresholdCommand(
          deviceId: deviceId,
          metric: MetricThreshold.pm25,
          value: 10,
          enabled: true,
          intent: DeviceThresholdWriteIntent.create,
        ),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'deviceId cannot be empty')),
      );
    });
  });
}