import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/commands/queue_device_command.command.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_command_type.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/devices/interfaces/rest/transform/device_commands_transform.dart';

void main() {
  group('toCreateDeviceCommandRequestResource', () {
    test('should encode the command type as its upper cased api value', () {
      // Arrange
      final expected = <DeviceCommandType, String>{
        DeviceCommandType.standby: 'STANDBY',
        DeviceCommandType.wake: 'WAKE',
        DeviceCommandType.restart: 'RESTART',
      };

      for (final entry in expected.entries) {
        final command = QueueDeviceCommandCommand(
          deviceId: DeviceId('dev-1'),
          type: entry.key,
          payload: null,
        );

        // Act
        final resource = toCreateDeviceCommandRequestResource(command);

        // Assert
        expect(resource.type, entry.key);
        expect(resource.toJson()['type'], entry.value);
      }
    });

    test('should forward the command payload unchanged', () {
      // Arrange
      final command = QueueDeviceCommandCommand(
        deviceId: DeviceId('dev-1'),
        type: DeviceCommandType.restart,
        payload: '{"deep":true}',
      );

      // Act
      final resource = toCreateDeviceCommandRequestResource(command);

      // Assert
      expect(resource.payload, '{"deep":true}');
      expect(resource.toJson()['payload'], '{"deep":true}');
    });

    test('should keep a null payload as an explicit null json entry', () {
      // Arrange
      final command = QueueDeviceCommandCommand(
        deviceId: DeviceId('dev-1'),
        type: DeviceCommandType.wake,
        payload: null,
      );

      // Act
      final body = toCreateDeviceCommandRequestResource(command).toJson();

      // Assert
      expect(body.containsKey('payload'), isTrue);
      expect(body['payload'], isNull);
      expect(body.keys, ['type', 'payload']);
    });

    test('should not leak the device id into the command body', () {
      // Arrange
      final command = QueueDeviceCommandCommand(
        deviceId: DeviceId('dev-1'),
        type: DeviceCommandType.standby,
        payload: null,
      );

      // Act
      final body = toCreateDeviceCommandRequestResource(command).toJson();

      // Assert
      expect(body.containsKey('deviceId'), isFalse);
    });
  });
}