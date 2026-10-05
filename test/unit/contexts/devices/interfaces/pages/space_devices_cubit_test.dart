import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/claim_device_to_space.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_device.command.dart';
import 'package:mobile/devices/domain/model/commands/pair_device.command.dart';
import 'package:mobile/devices/domain/model/queries/get_devices_by_space.query.dart';
import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/device_page.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/device_pairing.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/claim_token.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/hardware_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';
import 'package:mobile/devices/domain/services/devices.command-service.dart';
import 'package:mobile/devices/domain/services/devices.query-service.dart';
import 'package:mobile/devices/interfaces/pages/space_devices/space_devices_cubit.dart';

class _MockDevicesQueryService extends Mock implements DevicesQueryService {}

class _MockDevicesCommandService extends Mock implements DevicesCommandService {}

DeviceReadModel _device({
  String id = 'dev-1',
  String name = 'Living Room Sensor',
}) {
  return DeviceReadModel(
    id: id,
    serialNumber: 'SN-$id',
    name: name,
    status: 'ONLINE',
    spaceId: 'space-1',
    ownerUserId: 'user-1',
    configuration: const {},
    thresholds: const [],
    hardwareId: 'HW-1',
    deviceType: 'AIR_QUALITY',
    activatedAt: null,
    lastSeenAt: null,
    createdAt: null,
    updatedAt: null,
  );
}

DevicePageReadModel _page(List<DeviceReadModel> content, int totalElements) {
  return DevicePageReadModel(
    content: content,
    totalElements: totalElements,
    number: 0,
    size: 20,
  );
}

void main() {
  late DevicesQueryService queryService;
  late DevicesCommandService commandService;
  late SpaceDevicesCubit cubit;
  late List<SpaceDevicesState> emitted;

  setUpAll(() {
    registerFallbackValue(GetDevicesBySpaceQuery(spaceId: SpaceId('space-1')));
    registerFallbackValue(PairDeviceCommand(hardwareId: HardwareId('HW-1')));
    registerFallbackValue(ClaimDeviceToSpaceCommand(
      claimToken: ClaimToken('token'),
      spaceId: SpaceId('space-1'),
    ));
    registerFallbackValue(DeleteDeviceCommand(deviceId: DeviceId('dev-1')));
  });

  setUp(() {
    queryService = _MockDevicesQueryService();
    commandService = _MockDevicesCommandService();
    cubit = SpaceDevicesCubit(queryService, commandService);
    emitted = <SpaceDevicesState>[];
    cubit.stream.listen(emitted.add);
  });

  tearDown(() {
    cubit.close();
  });

  group('SpaceDevicesCubit initial state', () {
    test('should start idle on the grid layout with no devices', () {
      // Arrange / Act
      final state = cubit.state;

      // Assert
      expect(state.isLoading, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.isGrid, isTrue);
      expect(state.devices, isEmpty);
      expect(state.totalDevices, 0);
      expect(state.currentPage, 0);
      expect(state.hasMore, isFalse);
    });
  });

  group('SpaceDevicesCubit.loadDevices', () {
    test('should emit loading then the first page of devices on success', () async {
      // Arrange
      when(() => queryService.handleGetDevicesBySpace(any())).thenAnswer(
        (_) async => Right(_page([_device(), _device(id: 'dev-2')], 2)),
      );

      // Act
      await cubit.loadDevices(spaceId: 'space-1');

      // Assert
      expect(emitted.first.isLoading, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.devices.map((d) => d.id), ['dev-1', 'dev-2']);
      expect(cubit.state.totalDevices, 2);
      expect(cubit.state.currentPage, 0);
      expect(cubit.state.hasMore, isFalse);
    });

    test('should query the first page of twenty devices for the given space', () async {
      // Arrange
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) async => Right(_page(const [], 0)));

      // Act
      await cubit.loadDevices(spaceId: 'space-1');

      // Assert
      final captured =
          verify(() => queryService.handleGetDevicesBySpace(captureAny())).captured;
      final query = captured.single as GetDevicesBySpaceQuery;
      expect(query.spaceId.value, 'space-1');
      expect(query.page, 0);
      expect(query.size, 20);
    });

    test('should report more pages when the page is not the whole collection', () async {
      // Arrange
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) async => Right(_page([_device()], 30)));

      // Act
      await cubit.loadDevices(spaceId: 'space-1');

      // Assert
      expect(cubit.state.hasMore, isTrue);
      expect(cubit.state.totalDevices, 30);
    });

    test('should emit the failure message and no devices when the query fails', () async {
      // Arrange
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) async => const Left(Failure('Not found.')));

      // Act
      await cubit.loadDevices(spaceId: 'space-1');

      // Assert
      expect(emitted.first.isLoading, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, 'Not found.');
      expect(cubit.state.devices, isEmpty);
    });

    test('should emit the validation message and never query for a blank space id', () async {
      // Arrange / Act
      await cubit.loadDevices(spaceId: '  ');
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, 'Space id is required');
      verifyNever(() => queryService.handleGetDevicesBySpace(any()));
    });
  });

  group('SpaceDevicesCubit.loadMoreDevices', () {
    test('should append the next page and advance the page counter', () async {
      // Arrange
      final completer = Completer<Either<Failure, DevicePageReadModel>>();
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) async => Right(_page([_device()], 30)));
      await cubit.loadDevices(spaceId: 'space-1');
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) => completer.future);

      // Act
      final pending = cubit.loadMoreDevices();
      await Future<void>.delayed(Duration.zero);

      // Assert: the cubit flags the incremental load while it is in flight.
      expect(cubit.state.isLoadingMore, isTrue);

      completer.complete(Right(_page([_device(id: 'dev-9')], 30)));
      await pending;

      expect(cubit.state.isLoadingMore, isFalse);
      expect(cubit.state.currentPage, 1);
      expect(cubit.state.devices.map((d) => d.id), ['dev-1', 'dev-9']);
      final captured =
          verify(() => queryService.handleGetDevicesBySpace(captureAny())).captured;
      final query = captured.last as GetDevicesBySpaceQuery;
      expect(query.page, 1);
    });

    test('should ignore the request when there are no more pages', () async {
      // Arrange
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) async => Right(_page([_device()], 1)));
      await cubit.loadDevices(spaceId: 'space-1');

      // Act
      await cubit.loadMoreDevices();

      // Assert: only the initial load reached the query service.
      expect(cubit.state.isLoadingMore, isFalse);
      expect(
        verify(() => queryService.handleGetDevicesBySpace(any())).callCount,
        1,
      );
    });

    test('should ignore the request before any space has been loaded', () async {
      // Arrange / Act
      await cubit.loadMoreDevices();

      // Assert
      expect(cubit.state.isLoadingMore, isFalse);
      verifyNever(() => queryService.handleGetDevicesBySpace(any()));
    });

    test('should ignore a second request while the first one is still pending', () async {
      // Arrange
      final completer = Completer<Either<Failure, DevicePageReadModel>>();
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) async => Right(_page([_device()], 30)));
      await cubit.loadDevices(spaceId: 'space-1');
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) => completer.future);

      // Act
      final pending = cubit.loadMoreDevices();
      await cubit.loadMoreDevices();
      await Future<void>.delayed(Duration.zero);

      // Assert: the duplicate request was dropped by the isLoadingMore guard.
      expect(verify(() => queryService.handleGetDevicesBySpace(any())).callCount, 2);

      completer.complete(Right(_page([_device(id: 'dev-9')], 30)));
      await pending;
    });

    test('should emit the failure message when the next page cannot be loaded', () async {
      // Arrange
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) async => Right(_page([_device()], 30)));
      await cubit.loadDevices(spaceId: 'space-1');
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) async => const Left(Failure('Network error. Please check your connection.')));

      // Act
      await cubit.loadMoreDevices();

      // Assert
      expect(cubit.state.isLoadingMore, isFalse);
      expect(cubit.state.errorMessage, 'Network error. Please check your connection.');
      expect(cubit.state.devices.map((d) => d.id), ['dev-1']);
    });
  });

  group('SpaceDevicesCubit.setLayoutGrid', () {
    test('should switch to the list layout', () {
      // Arrange / Act
      cubit.setLayoutGrid(false);

      // Assert
      expect(cubit.state.isGrid, isFalse);
    });

    test('should not emit when the layout already matches', () {
      // Arrange / Act
      cubit.setLayoutGrid(true);
      final count = emitted.length;

      // Assert
      expect(cubit.state.isGrid, isTrue);
      expect(emitted.length, count);
    });
  });

  group('SpaceDevicesCubit.pairDevice', () {
    test('should return the pairing read model on success', () async {
      // Arrange
      when(() => commandService.handlePairDevice(any())).thenAnswer(
        (_) async => const Right(DevicePairingReadModel(deviceId: 'dev-9', claimToken: 'token-1')),
      );

      // Act
      final pairing = await cubit.pairDevice(hardwareId: '  HW-77  ');

      // Assert
      expect(pairing, isNotNull);
      expect(pairing!.deviceId, 'dev-9');
      expect(pairing.claimToken, 'token-1');
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.isLoading, isFalse);
      final captured = verify(() => commandService.handlePairDevice(captureAny())).captured;
      expect((captured.single as PairDeviceCommand).hardwareId.value, 'HW-77');
    });

    test('should return null and show the failure message when pairing is rejected', () async {
      // Arrange
      when(() => commandService.handlePairDevice(any()))
          .thenAnswer((_) async => const Left(Failure('Access denied.')));

      // Act
      final pairing = await cubit.pairDevice(hardwareId: 'HW-77');

      // Assert
      expect(pairing, isNull);
      expect(cubit.state.errorMessage, 'Access denied.');
      expect(cubit.state.isLoading, isFalse);
    });

    test('should return null and show the validation message for a blank hardware id', () async {
      // Arrange / Act
      final pairing = await cubit.pairDevice(hardwareId: '   ');

      // Assert
      expect(pairing, isNull);
      expect(cubit.state.errorMessage, 'Hardware ID is required');
      verifyNever(() => commandService.handlePairDevice(any()));
    });
  });

  group('SpaceDevicesCubit.claimDeviceToSpace', () {
    test('should return the claimed device and reload the device list', () async {
      // Arrange
      when(() => commandService.handleClaimDeviceToSpace(any()))
          .thenAnswer((_) async => Right(_device(id: 'dev-7', name: 'Claimed Sensor')));
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) async => Right(_page([_device(id: 'dev-7', name: 'Claimed Sensor')], 1)));

      // Act
      final device = await cubit.claimDeviceToSpace(claimToken: '  token-1  ', spaceId: 'space-1');

      // Assert
      expect(device!.id, 'dev-7');
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.devices.map((d) => d.id), ['dev-7']);
      final captured =
          verify(() => commandService.handleClaimDeviceToSpace(captureAny())).captured;
      final command = captured.single as ClaimDeviceToSpaceCommand;
      expect(command.claimToken.value, 'token-1');
      expect(command.spaceId.value, 'space-1');
      verify(() => queryService.handleGetDevicesBySpace(any())).called(1);
    });

    test('should return null and show the failure message without reloading when the claim fails', () async {
      // Arrange
      when(() => commandService.handleClaimDeviceToSpace(any()))
          .thenAnswer((_) async => const Left(Failure('Device not found.')));

      // Act
      final device = await cubit.claimDeviceToSpace(claimToken: 'token-1', spaceId: 'space-1');

      // Assert
      expect(device, isNull);
      expect(cubit.state.errorMessage, 'Device not found.');
      verifyNever(() => queryService.handleGetDevicesBySpace(any()));
    });

    test('should return null and show the validation message for a blank claim token', () async {
      // Arrange / Act
      final device = await cubit.claimDeviceToSpace(claimToken: '   ', spaceId: 'space-1');

      // Assert
      expect(device, isNull);
      expect(cubit.state.errorMessage, 'Claim token is required');
      verifyNever(() => commandService.handleClaimDeviceToSpace(any()));
    });
  });

  group('SpaceDevicesCubit.deleteDevice', () {
    test('should reload the device list after a successful deletion', () async {
      // Arrange
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) async => Right(_page([_device(), _device(id: 'dev-2')], 2)));
      await cubit.loadDevices(spaceId: 'space-1');
      when(() => commandService.handleDeleteDevice(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await cubit.deleteDevice('dev-1');

      // Assert: the initial load plus the post delete reload.
      expect(verify(() => queryService.handleGetDevicesBySpace(any())).callCount, 2);
      final captured = verify(() => commandService.handleDeleteDevice(captureAny())).captured;
      expect((captured.single as DeleteDeviceCommand).deviceId.value, 'dev-1');
    });

    test('should show the failure message and not reload when the deletion is rejected', () async {
      // Arrange
      when(() => queryService.handleGetDevicesBySpace(any()))
          .thenAnswer((_) async => Right(_page([_device()], 1)));
      await cubit.loadDevices(spaceId: 'space-1');
      when(() => commandService.handleDeleteDevice(any()))
          .thenAnswer((_) async => const Left(Failure('Access denied.')));

      // Act
      await cubit.deleteDevice('dev-1');

      // Assert: only the initial load happened, the list was not refreshed.
      expect(cubit.state.errorMessage, 'Access denied.');
      expect(verify(() => queryService.handleGetDevicesBySpace(any())).callCount, 1);
    });

    test('should show the validation message and never call the service for a blank id', () async {
      // Arrange / Act
      await cubit.deleteDevice('  ');

      // Assert
      expect(cubit.state.errorMessage, 'Device id is required');
      verifyNever(() => commandService.handleDeleteDevice(any()));
    });
  });
}