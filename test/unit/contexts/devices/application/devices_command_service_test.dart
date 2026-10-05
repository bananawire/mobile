import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/devices/application/internal/commandservices/devices_command_service_impl.dart';
import 'package:mobile/devices/domain/model/commands/claim_device_to_space.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_device.command.dart';
import 'package:mobile/devices/domain/model/commands/pair_device.command.dart';
import 'package:mobile/devices/domain/model/commands/update_device_name.command.dart';
import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/claim_token.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_name.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/hardware_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';
import 'package:mobile/devices/infrastructure/api/gateways/devices.gateway.dart';

import '../helpers/device_fixtures.dart';

class _MockDevicesGateway extends Mock implements DevicesGateway {}

void main() {
  late DevicesGateway gateway;
  late DevicesCommandServiceImpl sut;

  setUp(() {
    gateway = _MockDevicesGateway();
    sut = DevicesCommandServiceImpl(gateway);
  });

  group('DevicesCommandServiceImpl.handlePairDevice', () {
    test('should return the pairing read model when the gateway answers with a claim token', () async {
      // Arrange
      when(() => gateway.pairDeviceRaw(requestBody: any(named: 'requestBody'))).thenAnswer(
        (_) async => devicePairingJson(deviceId: 'dev-9', claimToken: 'token-xyz'),
      );
      final command = PairDeviceCommand(hardwareId: HardwareId(' HW-77 '));

      // Act
      final result = await sut.handlePairDevice(command);

      // Assert
      expect(result.isRight(), isTrue);
      final pairing = result.fold((_) => null, (value) => value);
      expect(pairing, isNotNull);
      expect(pairing!.deviceId, 'dev-9');
      expect(pairing.claimToken, 'token-xyz');
    });

    test('should submit the trimmed hardware id as the pair request body', () async {
      // Arrange
      when(() => gateway.pairDeviceRaw(requestBody: any(named: 'requestBody')))
          .thenAnswer((_) async => devicePairingJson());
      final command = PairDeviceCommand(hardwareId: HardwareId(' HW-77 '));

      // Act
      await sut.handlePairDevice(command);

      // Assert
      final captured = verify(
        () => gateway.pairDeviceRaw(requestBody: captureAny(named: 'requestBody')),
      ).captured;
      expect(captured.single, <String, dynamic>{'hardwareId': 'HW-77'});
    });

    test('should return a read model with a null token when the gateway omits it', () async {
      // Arrange
      when(() => gateway.pairDeviceRaw(requestBody: any(named: 'requestBody')))
          .thenAnswer((_) async => devicePairingJson(claimToken: null));
      final command = PairDeviceCommand(hardwareId: HardwareId('HW-77'));

      // Act
      final result = await sut.handlePairDevice(command);

      // Assert
      final pairing = result.fold((_) => null, (value) => value);
      expect(pairing!.claimToken, isNull);
    });

    test('should translate each dio status code into its documented failure message', () async {
      // Arrange
      const expected = <int, String>{
        400: 'Invalid request.',
        401: 'Session expired. Please sign in again.',
        403: 'Access denied.',
        404: 'Not found.',
        409: 'Conflict.',
        500: 'Server error. Please try again later.',
        502: 'Server error. Please try again later.',
        503: 'Server error. Please try again later.',
        418: 'Network error. Please check your connection.',
      };
      final command = PairDeviceCommand(hardwareId: HardwareId('HW-77'));

      for (final entry in expected.entries) {
        when(() => gateway.pairDeviceRaw(requestBody: any(named: 'requestBody')))
            .thenThrow(dioError(entry.key));

        // Act
        final result = await sut.handlePairDevice(command);

        // Assert
        expect(result.isLeft(), isTrue, reason: 'status ${entry.key}');
        final failure = result.fold((f) => f, (_) => null);
        expect(failure!.message, entry.value, reason: 'status ${entry.key}');
        expect(failure.statusCode, isNull);
      }
    });

    test('should report a connectivity failure as a network error', () async {
      // Arrange
      when(() => gateway.pairDeviceRaw(requestBody: any(named: 'requestBody')))
          .thenThrow(dioConnectionError());
      final command = PairDeviceCommand(hardwareId: HardwareId('HW-77'));

      // Act
      final result = await sut.handlePairDevice(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Network error. Please check your connection.');
    });

    test('should surface the message of a non dio exception without the exception prefix', () async {
      // Arrange
      when(() => gateway.pairDeviceRaw(requestBody: any(named: 'requestBody')))
          .thenThrow(Exception('Unexpected devices response format'));
      final command = PairDeviceCommand(hardwareId: HardwareId('HW-77'));

      // Act
      final result = await sut.handlePairDevice(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Unexpected devices response format');
    });

    test('should report a non exception error as an unexpected error', () async {
      // Arrange
      when(() => gateway.pairDeviceRaw(requestBody: any(named: 'requestBody')))
          .thenThrow('raw string failure');
      final command = PairDeviceCommand(hardwareId: HardwareId('HW-77'));

      // Act
      final result = await sut.handlePairDevice(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'An unexpected error occurred');
    });

    test('should never perform a read while pairing a device', () async {
      // Arrange
      when(() => gateway.pairDeviceRaw(requestBody: any(named: 'requestBody')))
          .thenAnswer((_) async => devicePairingJson());
      final command = PairDeviceCommand(hardwareId: HardwareId('HW-77'));

      // Act
      await sut.handlePairDevice(command);

      // Assert
      verifyNever(() => gateway.getDeviceByIdRaw(any()));
      verifyNever(() => gateway.getDeviceStatusRaw(any()));
      verifyNever(
        () => gateway.getDevicesBySpaceRaw(spaceId: any(named: 'spaceId'), page: any(named: 'page'), size: any(named: 'size')),
      );
    });
  });

  group('DevicesCommandServiceImpl.handleClaimDeviceToSpace', () {
    test('should return the claimed device read model when the gateway answers', () async {
      // Arrange
      when(() => gateway.claimDeviceRaw(requestBody: any(named: 'requestBody'))).thenAnswer(
        (_) async => deviceResourceJson(
          id: 'dev-5',
          name: 'Hallway Sensor',
          status: 'ONLINE',
          spaceId: 'space-42',
        ),
      );
      final command = ClaimDeviceToSpaceCommand(
        claimToken: ClaimToken(' token-1 '),
        spaceId: SpaceId('space-42'),
      );

      // Act
      final result = await sut.handleClaimDeviceToSpace(command);

      // Assert
      final device = result.fold((_) => null, (value) => value);
      expect(device, isA<DeviceReadModel>());
      expect(device!.id, 'dev-5');
      expect(device.serialNumber, 'SN-dev-5');
      expect(device.name, 'Hallway Sensor');
      expect(device.status, 'ONLINE');
      expect(device.spaceId, 'space-42');
      expect(device.ownerUserId, 'user-1');
      expect(device.configuration, <String, String>{'reportingInterval': '60'});
      expect(device.hardwareId, 'HW-1');
      expect(device.deviceType, 'AIR_QUALITY');
      expect(device.activatedAt, DateTime.utc(2024, 1, 15, 10, 30));
      expect(device.lastSeenAt, DateTime.utc(2024, 2, 20, 8));
      expect(device.createdAt, DateTime.utc(2024, 1, 15, 10));
      expect(device.updatedAt, DateTime.utc(2024, 2, 20, 8, 5));
    });

    test('should submit the trimmed claim token and the raw space id as the claim body', () async {
      // Arrange
      when(() => gateway.claimDeviceRaw(requestBody: any(named: 'requestBody')))
          .thenAnswer((_) async => deviceResourceJson());
      final command = ClaimDeviceToSpaceCommand(
        claimToken: ClaimToken(' token-1 '),
        spaceId: SpaceId(' space-42 '),
      );

      // Act
      await sut.handleClaimDeviceToSpace(command);

      // Assert
      final captured = verify(
        () => gateway.claimDeviceRaw(requestBody: captureAny(named: 'requestBody')),
      ).captured;
      expect(
        captured.single,
        <String, dynamic>{'claimToken': 'token-1', 'spaceId': ' space-42 '},
      );
    });

    test('should return a read model with null optional fields when they are absent', () async {
      // Arrange
      when(() => gateway.claimDeviceRaw(requestBody: any(named: 'requestBody'))).thenAnswer(
        (_) async => deviceResourceJson(
          spaceId: null,
          ownerUserId: null,
          activatedAt: null,
          lastSeenAt: null,
          createdAt: null,
          updatedAt: null,
          configuration: const {},
          thresholds: const [],
        ),
      );
      final command = ClaimDeviceToSpaceCommand(
        claimToken: ClaimToken('token-1'),
        spaceId: SpaceId('space-42'),
      );

      // Act
      final result = await sut.handleClaimDeviceToSpace(command);

      // Assert
      final device = result.fold((_) => null, (value) => value);
      expect(device!.spaceId, isNull);
      expect(device.ownerUserId, isNull);
      expect(device.activatedAt, isNull);
      expect(device.lastSeenAt, isNull);
      expect(device.createdAt, isNull);
      expect(device.updatedAt, isNull);
      expect(device.configuration, isEmpty);
      expect(device.thresholds, isEmpty);
    });

    test('should report a not found failure when the claim target space is gone', () async {
      // Arrange
      when(() => gateway.claimDeviceRaw(requestBody: any(named: 'requestBody')))
          .thenThrow(dioError(404));
      final command = ClaimDeviceToSpaceCommand(
        claimToken: ClaimToken('token-1'),
        spaceId: SpaceId('space-42'),
      );

      // Act
      final result = await sut.handleClaimDeviceToSpace(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Not found.');
    });
  });

  group('DevicesCommandServiceImpl.handleDeleteDevice', () {
    test('should return a successful right carrying no value when the device is deleted', () async {
      // Arrange
      when(() => gateway.deleteDeviceRaw(any())).thenAnswer((_) async {});
      final command = DeleteDeviceCommand(deviceId: DeviceId(' dev-7 '));

      // Act
      final result = await sut.handleDeleteDevice(command);

      // Assert
      expect(result.fold((_) => 'left', (_) => 'right'), 'right');
    });

    test('should delete the trimmed device id exactly once', () async {
      // Arrange
      when(() => gateway.deleteDeviceRaw(any())).thenAnswer((_) async {});
      final command = DeleteDeviceCommand(deviceId: DeviceId(' dev-7 '));

      // Act
      await sut.handleDeleteDevice(command);

      // Assert
      final captured = verify(() => gateway.deleteDeviceRaw(captureAny())).captured;
      expect(captured.single, 'dev-7');
    });

    test('should translate a forbidden deletion into an access denied failure', () async {
      // Arrange
      when(() => gateway.deleteDeviceRaw(any())).thenThrow(dioError(403));
      final command = DeleteDeviceCommand(deviceId: DeviceId('dev-7'));

      // Act
      final result = await sut.handleDeleteDevice(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Access denied.');
    });
  });

  group('DevicesCommandServiceImpl.handleUpdateDeviceName', () {
    test('should return a successful right carrying no value when the rename is accepted', () async {
      // Arrange
      when(() => gateway.updateDeviceNameRaw(any(), any())).thenAnswer((_) async {});
      final command = UpdateDeviceNameCommand(
        deviceId: DeviceId('dev-7'),
        name: DeviceName(' New Name '),
      );

      // Act
      final result = await sut.handleUpdateDeviceName(command);

      // Assert
      expect(result.fold((_) => 'left', (_) => 'right'), 'right');
    });

    test('should send the trimmed new name under the name key for the given device', () async {
      // Arrange
      when(() => gateway.updateDeviceNameRaw(any(), any())).thenAnswer((_) async {});
      final command = UpdateDeviceNameCommand(
        deviceId: DeviceId(' dev-7 '),
        name: DeviceName(' New Name '),
      );

      // Act
      await sut.handleUpdateDeviceName(command);

      // Assert
      final captured =
          verify(() => gateway.updateDeviceNameRaw(captureAny(), captureAny())).captured;
      expect(captured[0], 'dev-7');
      expect(captured[1], <String, dynamic>{'name': 'New Name'});
    });

    test('should report a conflict failure when the device name is already taken', () async {
      // Arrange
      when(() => gateway.updateDeviceNameRaw(any(), any())).thenThrow(dioError(409));
      final command = UpdateDeviceNameCommand(
        deviceId: DeviceId('dev-7'),
        name: DeviceName('New Name'),
      );

      // Act
      final result = await sut.handleUpdateDeviceName(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Conflict.');
    });

    test('should never call the gateway when the new device name cannot be built', () {
      // Arrange
      final deviceId = DeviceId('dev-7');

      // Act
      UpdateDeviceNameCommand buildCommand() =>
          UpdateDeviceNameCommand(deviceId: deviceId, name: DeviceName('   '));

      // Assert
      expect(buildCommand, throwsA(isA<ArgumentError>()));
      verifyNever(() => gateway.updateDeviceNameRaw(any(), any()));
    });
  });
}