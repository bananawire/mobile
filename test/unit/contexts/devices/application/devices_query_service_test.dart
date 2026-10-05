import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/devices/application/internal/queryservices/devices_query_service_impl.dart';
import 'package:mobile/devices/domain/model/queries/get_device_by_id.query.dart';
import 'package:mobile/devices/domain/model/queries/get_device_status.query.dart';
import 'package:mobile/devices/domain/model/queries/get_devices_by_space.query.dart';
import 'package:mobile/devices/domain/model/readmodels/device_page.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/device_status.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';
import 'package:mobile/devices/infrastructure/api/gateways/devices.gateway.dart';

import '../helpers/device_fixtures.dart';

class _MockDevicesGateway extends Mock implements DevicesGateway {}

void main() {
  late DevicesGateway gateway;
  late DevicesQueryServiceImpl sut;

  setUp(() {
    gateway = _MockDevicesGateway();
    sut = DevicesQueryServiceImpl(gateway);
  });

  group('DevicesQueryServiceImpl.handleGetDevicesBySpace', () {
    test('should return a page read model with every device mapped when the gateway answers', () async {
      // Arrange
      when(
        () => gateway.getDevicesBySpaceRaw(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => devicePageJson(totalElements: 2, number: 0, size: 20));
      final query = GetDevicesBySpaceQuery(spaceId: SpaceId('space-1'));

      // Act
      final result = await sut.handleGetDevicesBySpace(query);

      // Assert
      final page = result.fold((_) => null, (value) => value);
      expect(page, isA<DevicePageReadModel>());
      expect(page!.totalElements, 2);
      expect(page.number, 0);
      expect(page.size, 20);
      expect(page.content.map((d) => d.id), ['dev-1', 'dev-2']);
      expect(page.content.first.name, 'Living Room Sensor');
      expect(page.content.last.status, 'OFFLINE');
    });

    test('should forward the space id and the requested paging to the gateway', () async {
      // Arrange
      when(
        () => gateway.getDevicesBySpaceRaw(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => devicePageJson(content: const []));
      final query = GetDevicesBySpaceQuery(spaceId: SpaceId('space-1'), page: 2, size: 5);

      // Act
      await sut.handleGetDevicesBySpace(query);

      // Assert
      final captured = verify(
        () => gateway.getDevicesBySpaceRaw(
          spaceId: captureAny(named: 'spaceId'),
          page: captureAny(named: 'page'),
          size: captureAny(named: 'size'),
        ),
      ).captured;
      expect(captured, ['space-1', 2, 5]);
    });

    test('should default the paging to zero and twenty when the query omits it', () async {
      // Arrange
      when(
        () => gateway.getDevicesBySpaceRaw(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => devicePageJson(content: const []));
      final query = GetDevicesBySpaceQuery(spaceId: SpaceId('space-1'));

      // Act
      await sut.handleGetDevicesBySpace(query);

      // Assert
      final captured = verify(
        () => gateway.getDevicesBySpaceRaw(
          spaceId: captureAny(named: 'spaceId'),
          page: captureAny(named: 'page'),
          size: captureAny(named: 'size'),
        ),
      ).captured;
      expect(captured, ['space-1', 0, 20]);
    });

    test('should return an empty page when the payload has no content list', () async {
      // Arrange
      when(
        () => gateway.getDevicesBySpaceRaw(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => <String, dynamic>{'totalElements': 0});
      final query = GetDevicesBySpaceQuery(spaceId: SpaceId('space-1'));

      // Act
      final result = await sut.handleGetDevicesBySpace(query);

      // Assert
      final page = result.fold((_) => null, (value) => value);
      expect(page!.content, isEmpty);
      expect(page.totalElements, 0);
    });

    test('should surface the exception message when the gateway throws', () async {
      // Arrange
      when(
        () => gateway.getDevicesBySpaceRaw(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenThrow(Exception('socket closed'));
      final query = GetDevicesBySpaceQuery(spaceId: SpaceId('space-1'));

      // Act
      final result = await sut.handleGetDevicesBySpace(query);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'socket closed');
    });

    test('should not translate dio status codes into human messages', () async {
      // Arrange
      when(
        () => gateway.getDevicesBySpaceRaw(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenThrow(dioError(404));
      final query = GetDevicesBySpaceQuery(spaceId: SpaceId('space-1'));

      // Act
      final result = await sut.handleGetDevicesBySpace(query);

      // Assert: documents that this query service has no status code mapping.
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, startsWith('DioException'));
      expect(failure.message, isNot(contains('Not found.')));
      expect(failure.statusCode, isNull);
    });

    test('should never perform a write while listing devices', () async {
      // Arrange
      when(
        () => gateway.getDevicesBySpaceRaw(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => devicePageJson(content: const []));
      final query = GetDevicesBySpaceQuery(spaceId: SpaceId('space-1'));

      // Act
      await sut.handleGetDevicesBySpace(query);

      // Assert
      verifyNever(() => gateway.deleteDeviceRaw(any()));
      verifyNever(() => gateway.updateDeviceNameRaw(any(), any()));
      verifyNever(() => gateway.pairDeviceRaw(requestBody: any(named: 'requestBody')));
      verifyNever(() => gateway.claimDeviceRaw(requestBody: any(named: 'requestBody')));
    });
  });

  group('DevicesQueryServiceImpl.handleGetDeviceById', () {
    test('should return the device read model when the gateway answers', () async {
      // Arrange
      when(() => gateway.getDeviceByIdRaw(any()))
          .thenAnswer((_) async => deviceResourceJson(id: 'dev-3', name: 'Office Sensor'));
      final query = GetDeviceByIdQuery(deviceId: DeviceId(' dev-3 '));

      // Act
      final result = await sut.handleGetDeviceById(query);

      // Assert
      final device = result.fold((_) => null, (value) => value);
      expect(device!.id, 'dev-3');
      expect(device.serialNumber, 'SN-dev-3');
      expect(device.name, 'Office Sensor');
      expect(device.thresholds, hasLength(1));
    });

    test('should ask the gateway for the trimmed device id', () async {
      // Arrange
      when(() => gateway.getDeviceByIdRaw(any())).thenAnswer((_) async => deviceResourceJson());
      final query = GetDeviceByIdQuery(deviceId: DeviceId(' dev-3 '));

      // Act
      await sut.handleGetDeviceById(query);

      // Assert
      final captured = verify(() => gateway.getDeviceByIdRaw(captureAny())).captured;
      expect(captured.single, 'dev-3');
    });

    test('should surface a gateway exception message as the failure', () async {
      // Arrange
      when(() => gateway.getDeviceByIdRaw(any())).thenThrow(Exception('Unexpected device response format'));
      final query = GetDeviceByIdQuery(deviceId: DeviceId('dev-3'));

      // Act
      final result = await sut.handleGetDeviceById(query);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Unexpected device response format');
    });
  });

  group('DevicesQueryServiceImpl.handleGetDeviceStatus', () {
    test('should return the status read model when the gateway answers', () async {
      // Arrange
      when(() => gateway.getDeviceStatusRaw(any())).thenAnswer(
        (_) async => deviceStatusJson(deviceId: 'dev-4', status: 'ONLINE'),
      );
      final query = GetDeviceStatusQuery(deviceId: DeviceId(' dev-4 '));

      // Act
      final result = await sut.handleGetDeviceStatus(query);

      // Assert
      final status = result.fold((_) => null, (value) => value);
      expect(status, isA<DeviceStatusReadModel>());
      expect(status!.deviceId, 'dev-4');
      expect(status.status, 'ONLINE');
      expect(status.lastSeenAt, DateTime.utc(2024, 2, 20, 8));
    });

    test('should ask the gateway for the trimmed device id', () async {
      // Arrange
      when(() => gateway.getDeviceStatusRaw(any())).thenAnswer(
        (_) async => deviceStatusJson(),
      );
      final query = GetDeviceStatusQuery(deviceId: DeviceId(' dev-4 '));

      // Act
      await sut.handleGetDeviceStatus(query);

      // Assert
      final captured = verify(() => gateway.getDeviceStatusRaw(captureAny())).captured;
      expect(captured.single, 'dev-4');
    });

    test('should return a null timestamp when the gateway omits last seen', () async {
      // Arrange
      when(() => gateway.getDeviceStatusRaw(any())).thenAnswer(
        (_) async => deviceStatusJson(lastSeenAt: null),
      );
      final query = GetDeviceStatusQuery(deviceId: DeviceId('dev-4'));

      // Act
      final result = await sut.handleGetDeviceStatus(query);

      // Assert
      final status = result.fold((_) => null, (value) => value);
      expect(status!.lastSeenAt, isNull);
    });
  });
}