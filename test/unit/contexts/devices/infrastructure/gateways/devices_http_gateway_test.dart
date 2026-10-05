import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/infrastructure/api/gateways/devices_http.gateway.dart';

import '../../helpers/device_fixtures.dart';
import '../../helpers/fake_http_client_adapter.dart';

void main() {
  late Dio dio;
  late FakeHttpClientAdapter adapter;
  late DevicesHttpGateway sut;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://clair.test'));
    dio.httpClientAdapter = adapter;
    sut = DevicesHttpGateway(dio);
  });

  tearDown(() {
    dio.close(force: true);
  });

  group('DevicesHttpGateway.getDeviceCountBySpace', () {
    test('should query the devices collection for one element and read the total', () async {
      // Arrange
      adapter.enqueueJson(devicePageJson(totalElements: 42, content: const []));

      // Act
      final count = await sut.getDeviceCountBySpace('space-1');

      // Assert
      expect(count, 42);
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, '/api/v1/devices');
      expect(adapter.singleRequest.queryParameters, {
        'spaceId': 'space-1',
        'page': 0,
        'size': 1,
      });
    });

    test('should coerce a double encoded total into an int', () async {
      // Arrange
      adapter.enqueueJson(devicePageJson(totalElements: 7.0, content: const []));

      // Act
      final count = await sut.getDeviceCountBySpace('space-1');

      // Assert
      expect(count, 7);
    });

    test('should return zero when the total is absent or not numeric', () async {
      // Arrange
      adapter.enqueueJson(<String, dynamic>{'content': <dynamic>[]});

      // Act
      final count = await sut.getDeviceCountBySpace('space-1');

      // Assert
      expect(count, 0);
    });
  });

  group('DevicesHttpGateway.getDevicesBySpaceRaw', () {
    test('should send a GET with the space and paging as query parameters', () async {
      // Arrange
      adapter.enqueueJson(devicePageJson());

      // Act
      await sut.getDevicesBySpaceRaw(spaceId: 'space-1', page: 2, size: 50);

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'GET');
      expect(request.path, '/api/v1/devices');
      expect(request.queryParameters, {'spaceId': 'space-1', 'page': 2, 'size': 50});
      expect(request.data, isNull);
    });

    test('should default the paging to the first page of twenty items', () async {
      // Arrange
      adapter.enqueueJson(devicePageJson());

      // Act
      await sut.getDevicesBySpaceRaw(spaceId: 'space-1');

      // Assert
      expect(adapter.singleRequest.queryParameters, {'spaceId': 'space-1', 'page': 0, 'size': 20});
    });

    test('should return the raw response map untouched', () async {
      // Arrange
      final payload = devicePageJson(totalElements: 1);
      adapter.enqueueJson(payload);

      // Act
      final raw = await sut.getDevicesBySpaceRaw(spaceId: 'space-1');

      // Assert
      expect(raw['totalElements'], 1);
      expect(raw['content'], hasLength(2));
    });

    test('should throw when the response body is not a json object', () async {
      // Arrange
      adapter.enqueueJson(<dynamic>[1, 2, 3]);

      // Act / Assert
      await expectLater(
        sut.getDevicesBySpaceRaw(spaceId: 'space-1'),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw a dio bad response exception for a server error', () async {
      // Arrange
      adapter.enqueueJson({'message': 'boom'}, statusCode: 500);

      // Act / Assert
      await expectLater(
        sut.getDevicesBySpaceRaw(spaceId: 'space-1'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });

    test('should throw a timeout exception when the adapter times out', () async {
      // Arrange
      adapter.enqueueError(
        DioException.connectionTimeout(
          timeout: const Duration(seconds: 5),
          requestOptions: RequestOptions(path: '/api/v1/devices'),
        ),
      );

      // Act / Assert
      await expectLater(
        sut.getDevicesBySpaceRaw(spaceId: 'space-1'),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.connectionTimeout,
          ),
        ),
      );
    });
  });

  group('DevicesHttpGateway.getDeviceByIdRaw', () {
    test('should send a GET to the single device collection', () async {
      // Arrange
      adapter.enqueueJson(deviceResourceJson(id: 'dev-1'));

      // Act
      final raw = await sut.getDeviceByIdRaw('dev-1');

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, '/api/v1/devices/dev-1');
      expect(raw['id'], 'dev-1');
    });

    test('should surface a not found response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'not found'}, statusCode: 404);

      // Act / Assert
      await expectLater(
        sut.getDeviceByIdRaw('missing'),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('should throw when the body is a json array', () async {
      // Arrange
      adapter.enqueueJson(<dynamic>[]);

      // Act / Assert
      await expectLater(
        sut.getDeviceByIdRaw('dev-1'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('DevicesHttpGateway.getDeviceStatusRaw', () {
    test('should send a GET to the device status sub resource', () async {
      // Arrange
      adapter.enqueueJson(deviceStatusJson());

      // Act
      final raw = await sut.getDeviceStatusRaw('dev-1');

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, '/api/v1/devices/dev-1/status');
      expect(raw['status'], 'ONLINE');
    });
  });

  group('DevicesHttpGateway.deleteDeviceRaw', () {
    test('should send a DELETE to the device and accept an empty response', () async {
      // Arrange
      adapter.enqueueEmpty();

      // Act
      await sut.deleteDeviceRaw('dev-1');

      // Assert
      expect(adapter.singleRequest.method, 'DELETE');
      expect(adapter.singleRequest.path, '/api/v1/devices/dev-1');
    });

    test('should send no request body when deleting', () async {
      // Arrange
      adapter.enqueueEmpty();

      // Act
      await sut.deleteDeviceRaw('dev-1');

      // Assert
      expect(adapter.singleRequest.data, isNull);
    });

    test('should surface a forbidden response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'forbidden'}, statusCode: 403);

      // Act / Assert
      await expectLater(
        sut.deleteDeviceRaw('dev-1'),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 403),
        ),
      );
    });
  });

  group('DevicesHttpGateway.updateDeviceNameRaw', () {
    test('should PATCH the device name sub resource with the json body', () async {
      // Arrange
      adapter.enqueueEmpty();

      // Act
      await sut.updateDeviceNameRaw('dev-1', <String, dynamic>{'name': 'Kitchen'});

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'PATCH');
      expect(request.path, '/api/v1/devices/dev-1/name');
      expect(request.data, <String, dynamic>{'name': 'Kitchen'});
    });

    test('should surface a conflict response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'conflict'}, statusCode: 409);

      // Act / Assert
      await expectLater(
        sut.updateDeviceNameRaw('dev-1', <String, dynamic>{'name': 'Kitchen'}),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 409),
        ),
      );
    });
  });

  group('DevicesHttpGateway.pairDeviceRaw', () {
    test('should POST the hardware id to the pair sub resource', () async {
      // Arrange
      adapter.enqueueJson(devicePairingJson());

      // Act
      final raw = await sut.pairDeviceRaw(
        requestBody: <String, dynamic>{'hardwareId': 'HW-77'},
      );

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'POST');
      expect(request.path, '/api/v1/devices/pair');
      expect(request.data, <String, dynamic>{'hardwareId': 'HW-77'});
      expect(raw['claimToken'], 'claim-token-1');
    });

    test('should surface an unauthorised response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'unauthorised'}, statusCode: 401);

      // Act / Assert
      await expectLater(
        sut.pairDeviceRaw(requestBody: <String, dynamic>{'hardwareId': 'HW-77'}),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('should throw when the pairing body is not a json object', () async {
      // Arrange
      adapter.enqueueJson('token');

      // Act / Assert
      await expectLater(
        sut.pairDeviceRaw(requestBody: <String, dynamic>{'hardwareId': 'HW-77'}),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('DevicesHttpGateway.claimDeviceRaw', () {
    test('should POST the claim token and space id to the claim sub resource', () async {
      // Arrange
      adapter.enqueueJson(deviceResourceJson());

      // Act
      final raw = await sut.claimDeviceRaw(
        requestBody: <String, dynamic>{'claimToken': 'token-1', 'spaceId': 'space-1'},
      );

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'POST');
      expect(request.path, '/api/v1/devices/claim');
      expect(request.data, <String, dynamic>{'claimToken': 'token-1', 'spaceId': 'space-1'});
      expect(raw['id'], 'dev-1');
    });

    test('should surface a bad request response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'invalid claim'}, statusCode: 400);

      // Act / Assert
      await expectLater(
        sut.claimDeviceRaw(requestBody: <String, dynamic>{'claimToken': 'x', 'spaceId': 'y'}),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('should surface a connection error thrown by the transport', () async {
      // Arrange
      adapter.enqueueError(
        DioException.connectionError(
          requestOptions: RequestOptions(path: '/api/v1/devices/claim'),
          reason: 'connection refused',
        ),
      );

      // Act / Assert
      await expectLater(
        sut.claimDeviceRaw(requestBody: <String, dynamic>{'claimToken': 'x', 'spaceId': 'y'}),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.connectionError,
          ),
        ),
      );
    });
  });
}