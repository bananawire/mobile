import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/devices/application/internal/commandservices/device_commands_command_service_impl.dart';
import 'package:mobile/devices/domain/model/commands/queue_device_command.command.dart';
import 'package:mobile/devices/domain/model/readmodels/device_command.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_command_type.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_commands.gateway.dart';

import '../helpers/device_fixtures.dart';

class _MockDeviceCommandsGateway extends Mock implements DeviceCommandsGateway {}

void main() {
  late DeviceCommandsGateway gateway;
  late DeviceCommandsCommandServiceImpl sut;

  setUp(() {
    gateway = _MockDeviceCommandsGateway();
    sut = DeviceCommandsCommandServiceImpl(gateway);
  });

  group('DeviceCommandsCommandServiceImpl.handleQueueDeviceCommand', () {
    test('should return the queued command read model when the gateway answers', () async {
      // Arrange
      when(
        () => gateway.createDeviceCommandRaw(
          deviceId: any(named: 'deviceId'),
          requestBody: any(named: 'requestBody'),
        ),
      ).thenAnswer(
        (_) async => deviceCommandJson(
          id: 'cmd-9',
          deviceId: 'dev-2',
          type: 'RESTART',
          status: 'SENT',
          payload: null,
          sentAt: '2024-03-01T10:00:00Z',
          executedAt: '2024-03-01T10:00:05Z',
          failureReason: null,
          createdAt: '2024-03-01T09:59:59Z',
        ),
      );
      final command = QueueDeviceCommandCommand(
        deviceId: DeviceId('dev-2'),
        type: DeviceCommandType.restart,
        payload: null,
      );

      // Act
      final result = await sut.handleQueueDeviceCommand(command);

      // Assert
      final queued = result.fold((_) => null, (value) => value);
      expect(queued, isA<DeviceCommandReadModel>());
      expect(queued!.id, 'cmd-9');
      expect(queued.deviceId, 'dev-2');
      expect(queued.type, DeviceCommandType.restart);
      expect(queued.status, 'SENT');
      expect(queued.payload, isNull);
      expect(queued.sentAt, DateTime.utc(2024, 3, 1, 10));
      expect(queued.executedAt, DateTime.utc(2024, 3, 1, 10, 0, 5));
      expect(queued.failureReason, isNull);
      expect(queued.createdAt, DateTime.utc(2024, 3, 1, 9, 59, 59));
    });

    test('should submit the api encoded command type and payload for the trimmed device id', () async {
      // Arrange
      when(
        () => gateway.createDeviceCommandRaw(
          deviceId: any(named: 'deviceId'),
          requestBody: any(named: 'requestBody'),
        ),
      ).thenAnswer((_) async => deviceCommandJson());
      final command = QueueDeviceCommandCommand(
        deviceId: DeviceId(' dev-2 '),
        type: DeviceCommandType.standby,
        payload: '{"deep":true}',
      );

      // Act
      await sut.handleQueueDeviceCommand(command);

      // Assert
      final captured = verify(
        () => gateway.createDeviceCommandRaw(
          deviceId: captureAny(named: 'deviceId'),
          requestBody: captureAny(named: 'requestBody'),
        ),
      ).captured;
      expect(captured[0], 'dev-2');
      expect(captured[1], <String, dynamic>{'type': 'STANDBY', 'payload': '{"deep":true}'});
    });

    test('should keep the requested command type when the gateway answers an unknown type', () async {
      // Arrange
      when(
        () => gateway.createDeviceCommandRaw(
          deviceId: any(named: 'deviceId'),
          requestBody: any(named: 'requestBody'),
        ),
      ).thenAnswer((_) async => deviceCommandJson(type: 'HIBERNATE'));
      final command = QueueDeviceCommandCommand(
        deviceId: DeviceId('dev-2'),
        type: DeviceCommandType.wake,
        payload: null,
      );

      // Act
      final result = await sut.handleQueueDeviceCommand(command);

      // Assert
      final queued = result.fold((_) => null, (value) => value);
      expect(queued!.type, DeviceCommandType.wake);
    });

    test('should decode a lower cased api command type', () async {
      // Arrange
      when(
        () => gateway.createDeviceCommandRaw(
          deviceId: any(named: 'deviceId'),
          requestBody: any(named: 'requestBody'),
        ),
      ).thenAnswer((_) async => deviceCommandJson(type: 'wake'));
      final command = QueueDeviceCommandCommand(
        deviceId: DeviceId('dev-2'),
        type: DeviceCommandType.standby,
        payload: null,
      );

      // Act
      final result = await sut.handleQueueDeviceCommand(command);

      // Assert
      final queued = result.fold((_) => null, (value) => value);
      expect(queued!.type, DeviceCommandType.wake);
    });

    test('should translate each mapped dio status code into its failure message', () async {
      // Arrange
      const expected = <int, String>{
        400: 'Invalid command request.',
        401: 'Session expired. Please sign in again.',
        403: 'Access denied.',
        404: 'Device not found.',
        409: 'Conflict.',
        418: 'Network error. Please check your connection.',
      };
      final command = QueueDeviceCommandCommand(
        deviceId: DeviceId('dev-2'),
        type: DeviceCommandType.wake,
        payload: null,
      );

      for (final entry in expected.entries) {
        when(
          () => gateway.createDeviceCommandRaw(
            deviceId: any(named: 'deviceId'),
            requestBody: any(named: 'requestBody'),
          ),
        ).thenThrow(dioError(entry.key));

        // Act
        final result = await sut.handleQueueDeviceCommand(command);

        // Assert
        final failure = result.fold((f) => f, (_) => null);
        expect(failure!.message, entry.value, reason: 'status ${entry.key}');
      }
    });

    test('should report a server failure as a network error because no 5xx case exists', () async {
      // Arrange
      when(
        () => gateway.createDeviceCommandRaw(
          deviceId: any(named: 'deviceId'),
          requestBody: any(named: 'requestBody'),
        ),
      ).thenThrow(dioError(500));
      final command = QueueDeviceCommandCommand(
        deviceId: DeviceId('dev-2'),
        type: DeviceCommandType.wake,
        payload: null,
      );

      // Act
      final result = await sut.handleQueueDeviceCommand(command);

      // Assert: documents the missing 5xx branch in _mapError.
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Network error. Please check your connection.');
    });

    test('should surface a gateway exception message when the payload format is unexpected', () async {
      // Arrange
      when(
        () => gateway.createDeviceCommandRaw(
          deviceId: any(named: 'deviceId'),
          requestBody: any(named: 'requestBody'),
        ),
      ).thenThrow(Exception('Unexpected device command response format'));
      final command = QueueDeviceCommandCommand(
        deviceId: DeviceId('dev-2'),
        type: DeviceCommandType.wake,
        payload: null,
      );

      // Act
      final result = await sut.handleQueueDeviceCommand(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Unexpected device command response format');
    });
  });
}