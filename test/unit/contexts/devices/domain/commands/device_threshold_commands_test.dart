import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/commands/remove_device_threshold.command.dart';
import 'package:mobile/devices/domain/model/commands/write_device_threshold.command.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';

void main() {
  group('WriteDeviceThresholdCommand', () {
    test('should keep every provided field when built with valid arguments', () {
      // Arrange
      const deviceId = 'dev-1';

      // Act
      final command = WriteDeviceThresholdCommand(
        deviceId: deviceId,
        metric: MetricThreshold.pm25,
        value: 75.5,
        enabled: true,
        intent: DeviceThresholdWriteIntent.create,
      );

      // Assert
      expect(command.deviceId, deviceId);
      expect(command.metric, MetricThreshold.pm25);
      expect(command.value, 75.5);
      expect(command.enabled, isTrue);
      expect(command.intent, DeviceThresholdWriteIntent.create);
    });

    test('should throw ArgumentError when the device id is blank', () {
      // Arrange
      const deviceId = '   ';

      // Act / Assert
      expect(
        () => WriteDeviceThresholdCommand(
          deviceId: deviceId,
          metric: MetricThreshold.co2,
          value: 900,
          enabled: true,
          intent: DeviceThresholdWriteIntent.update,
        ),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'deviceId cannot be empty')),
      );
    });

    test('should throw ArgumentError when the threshold value is zero', () {
      // Arrange
      const value = 0.0;

      // Act / Assert
      expect(
        () => WriteDeviceThresholdCommand(
          deviceId: 'dev-1',
          metric: MetricThreshold.co2,
          value: value,
          enabled: true,
          intent: DeviceThresholdWriteIntent.create,
        ),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', 'value must be greater than 0'),
        ),
      );
    });

    test('should throw ArgumentError when the threshold value is negative', () {
      // Arrange
      const value = -10.0;

      // Act / Assert
      expect(
        () => WriteDeviceThresholdCommand(
          deviceId: 'dev-1',
          metric: MetricThreshold.humidity,
          value: value,
          enabled: false,
          intent: DeviceThresholdWriteIntent.update,
        ),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', 'value must be greater than 0'),
        ),
      );
    });

    test('should reject the blank device id before the non positive value', () {
      // Arrange
      const deviceId = '';
      const value = -1.0;

      // Act / Assert
      expect(
        () => WriteDeviceThresholdCommand(
          deviceId: deviceId,
          metric: MetricThreshold.temperature,
          value: value,
          enabled: true,
          intent: DeviceThresholdWriteIntent.create,
        ),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'deviceId cannot be empty')),
      );
    });

    test('should accept any strictly positive value because no per metric bound is enforced', () {
      // Arrange
      const value = 1000000.0;

      // Act
      final command = WriteDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.co2,
        value: value,
        enabled: true,
        intent: DeviceThresholdWriteIntent.create,
      );

      // Assert
      expect(command.value, value);
    });

    test('should keep the device id untrimmed because only validation trims it', () {
      // Arrange
      const deviceId = ' dev-1 ';

      // Act
      final command = WriteDeviceThresholdCommand(
        deviceId: deviceId,
        metric: MetricThreshold.pm25,
        value: 1,
        enabled: true,
        intent: DeviceThresholdWriteIntent.create,
      );

      // Assert
      expect(command.deviceId, ' dev-1 ');
    });
  });

  group('RemoveDeviceThresholdCommand', () {
    test('should keep every provided field when built with valid arguments', () {
      // Arrange
      const deviceId = 'dev-1';

      // Act
      final command = RemoveDeviceThresholdCommand(
        deviceId: deviceId,
        metric: MetricThreshold.humidity,
      );

      // Assert
      expect(command.deviceId, deviceId);
      expect(command.metric, MetricThreshold.humidity);
    });

    test('should throw ArgumentError when the device id is blank', () {
      // Arrange
      const deviceId = '\t';

      // Act / Assert
      expect(
        () => RemoveDeviceThresholdCommand(
          deviceId: deviceId,
          metric: MetricThreshold.temperature,
        ),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'deviceId cannot be empty')),
      );
    });
  });
}