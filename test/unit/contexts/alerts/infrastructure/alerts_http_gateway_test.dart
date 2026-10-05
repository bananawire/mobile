import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/infrastructure/api/gateways/alerts_http.gateway.dart';

import '../alerts_fixtures.dart';
import 'fake_http_client_adapter.dart';

void main() {
  const baseUrl = 'https://clair.test';

  late Dio dio;
  late AlertsHttpGateway gateway;
  late FakeHttpClientAdapter adapter;

  /// Builds the gateway on top of a real [Dio] whose transport only replies
  /// with [responder]; the class under test is never mocked.
  void buildGateway(FakeHttpClientAdapter Function() createAdapter) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
      ),
    );
    adapter = createAdapter();
    dio.httpClientAdapter = adapter;
    gateway = AlertsHttpGateway(dio);
  }

  tearDown(() async {
    dio.close(force: true);
  });

  group('AlertsHttpGateway.getAlerts', () {
    test('should issue a GET on the alerts path with the pagination query '
        'parameters', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(emptyAlertPageJson),
        ),
      );

      // Act
      await gateway.getAlerts(page: 2, size: 50);

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, '/api/v1/alerts');
      expect(
        adapter.singleRequest.queryParameters,
        <String, dynamic>{'page': 2, 'size': 50},
      );
      expect(adapter.singleRequest.baseUrl, baseUrl);
    });

    test('should append the status filter to the query parameters when statuses '
        'are provided', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(emptyAlertPageJson),
        ),
      );

      // Act
      await gateway.getAlerts(
        page: 0,
        size: 20,
        status: const ['ACTIVE', 'ACKNOWLEDGED'],
      );

      // Assert
      expect(adapter.singleRequest.queryParameters, <String, dynamic>{
        'page': 0,
        'size': 20,
        'status': <String>['ACTIVE', 'ACKNOWLEDGED'],
      });
    });

    test('should omit the status query parameter when no status is provided',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(emptyAlertPageJson),
        ),
      );

      // Act
      await gateway.getAlerts(page: 0, size: 20);

      // Assert
      expect(
        adapter.singleRequest.queryParameters.containsKey('status'),
        isFalse,
      );
    });

    test('should omit the status query parameter when the status list is empty',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(emptyAlertPageJson),
        ),
      );

      // Act
      await gateway.getAlerts(page: 0, size: 20, status: const []);

      // Assert
      expect(
        adapter.singleRequest.queryParameters.containsKey('status'),
        isFalse,
      );
    });

    test('should deserialize the content and the pagination metadata of the '
        'page', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            alertPageJson(
              content: [alertJson(), resolvedAlertJson()],
              totalElements: 41,
              totalPages: 3,
              size: 20,
              number: 1,
            ),
          ),
        ),
      );

      // Act
      final resource = await gateway.getAlerts(page: 1, size: 20);

      // Assert
      expect(resource.content, hasLength(2));
      expect(resource.content.first.id, 'alert-1');
      expect(resource.content.first.metric, 'PM25');
      expect(resource.content.last.resolvedAt, '2024-05-02T09:15:00Z');
      expect(resource.totalElements, 41);
      expect(resource.totalPages, 3);
      expect(resource.size, 20);
      expect(resource.number, 1);
    });

    test('should deserialize an empty page without failing', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(emptyAlertPageJson),
        ),
      );

      // Act
      final resource = await gateway.getAlerts(page: 0, size: 20);

      // Assert
      expect(resource.content, isEmpty);
      expect(resource.totalElements, 0);
    });

    test('should not attach an authorization header because auth is added by '
        'an interceptor', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(emptyAlertPageJson),
        ),
      );

      // Act
      await gateway.getAlerts(page: 0, size: 20);

      // Assert
      expect(
        adapter.singleRequest.headers.keys.map((key) => key.toLowerCase()),
        isNot(contains('authorization')),
      );
    });

    test('should not send a request body for the read only request', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(emptyAlertPageJson),
        ),
      );

      // Act
      await gateway.getAlerts(page: 0, size: 20);

      // Assert
      expect(adapter.singleRequest.data, isNull);
    });

    test('should surface a bad request failure when the backend answers 400',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            <String, dynamic>{'message': 'Invalid page'},
            statusCode: 400,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlerts(page: 0, size: 20),
        throwsA(
          isA<DioException>()
              .having(
                (error) => error.response?.statusCode,
                'statusCode',
                400,
              )
              .having(
                (error) => error.response?.data,
                'data',
                <String, dynamic>{'message': 'Invalid page'},
              ),
        ),
      );
    });

    test('should surface an unauthorized failure when the backend answers 401',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            <String, dynamic>{'message': 'Unauthorized'},
            statusCode: 401,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlerts(page: 0, size: 20),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
    });

    test('should surface a forbidden failure when the backend answers 403',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            <String, dynamic>{'message': 'Forbidden'},
            statusCode: 403,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlerts(page: 0, size: 20),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'statusCode',
            403,
          ),
        ),
      );
    });

    test('should surface a not found failure when the backend answers 404',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            <String, dynamic>{'message': 'Not found'},
            statusCode: 404,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlerts(page: 0, size: 20),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    });

    test('should surface a conflict failure when the backend answers 409',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            <String, dynamic>{'message': 'Conflict'},
            statusCode: 409,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlerts(page: 0, size: 20),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'statusCode',
            409,
          ),
        ),
      );
    });

    test('should surface a server error failure when the backend answers 500',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            <String, dynamic>{'message': 'Boom'},
            statusCode: 500,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlerts(page: 0, size: 20),
        throwsA(
          isA<DioException>()
              .having(
                (error) => error.response?.statusCode,
                'statusCode',
                500,
              )
              .having(
                (error) => error.type,
                'type',
                DioExceptionType.badResponse,
              ),
        ),
      );
    });

    test('should surface a service unavailable failure when the backend '
        'answers 503', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            <String, dynamic>{'message': 'Down'},
            statusCode: 503,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlerts(page: 0, size: 20),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'statusCode',
            503,
          ),
        ),
      );
    });

    test('should throw a cast error when the body is a JSON array instead of a '
        'page object', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(<dynamic>[1, 2, 3]),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlerts(page: 0, size: 20),
        throwsA(
          isA<TypeError>().having(
            (error) => error.toString(),
            'message',
            contains('Map<String, dynamic>'),
          ),
        ),
      );
    });

    test('should throw a cast error when the backend answers 204 without '
        'content', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.emptyBody(204),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlerts(page: 0, size: 20),
        throwsA(isA<TypeError>()),
        reason: 'The gateway always casts the body to Map<String, dynamic>, so '
            'a 204 response is not supported',
      );
    });

    test('should surface a connection timeout failure when the transport times '
        'out', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (options) => throw DioException.connectionTimeout(
            timeout: const Duration(seconds: 5),
            requestOptions: options,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlerts(page: 0, size: 20),
        throwsA(
          isA<DioException>().having(
            (error) => error.type,
            'type',
            DioExceptionType.connectionTimeout,
          ),
        ),
      );
    });

    test('should surface a receive timeout failure when the response never '
        'arrives', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (options) => throw DioException.receiveTimeout(
            timeout: const Duration(seconds: 5),
            requestOptions: options,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlerts(page: 0, size: 20),
        throwsA(
          isA<DioException>().having(
            (error) => error.type,
            'type',
            DioExceptionType.receiveTimeout,
          ),
        ),
      );
    });
  });

  group('AlertsHttpGateway.getAlertsByDevice', () {
    test('should issue a GET on the device scoped alerts path', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(emptyAlertPageJson),
        ),
      );

      // Act
      await gateway.getAlertsByDevice(deviceId: 'device-7', page: 0, size: 20);

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, '/api/v1/devices/device-7/alerts');
      expect(
        adapter.singleRequest.queryParameters,
        <String, dynamic>{'page': 0, 'size': 20},
      );
    });

    test('should append the status filter to the device scoped request',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(emptyAlertPageJson),
        ),
      );

      // Act
      await gateway.getAlertsByDevice(
        deviceId: 'device-7',
        page: 1,
        size: 5,
        status: const ['RESOLVED'],
      );

      // Assert
      expect(adapter.singleRequest.queryParameters, <String, dynamic>{
        'page': 1,
        'size': 5,
        'status': <String>['RESOLVED'],
      });
    });

    test('should deserialize the page returned for the device', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            alertPageJson(
              content: [alertJson(deviceId: 'device-7')],
              totalElements: 1,
              totalPages: 1,
            ),
          ),
        ),
      );

      // Act
      final resource = await gateway.getAlertsByDevice(
        deviceId: 'device-7',
        page: 0,
        size: 20,
      );

      // Assert
      expect(resource.content.single.deviceId, 'device-7');
      expect(resource.totalElements, 1);
    });

    test('should surface a not found failure when the device does not exist',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            <String, dynamic>{'message': 'Device not found'},
            statusCode: 404,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlertsByDevice(deviceId: 'ghost', page: 0, size: 20),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    });
  });

  group('AlertsHttpGateway.getAlertsBySpace', () {
    test('should issue a GET on the space scoped alerts path', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(emptyAlertPageJson),
        ),
      );

      // Act
      await gateway.getAlertsBySpace(spaceId: 'space-3', page: 2, size: 10);

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, '/api/v1/spaces/space-3/alerts');
      expect(
        adapter.singleRequest.queryParameters,
        <String, dynamic>{'page': 2, 'size': 10},
      );
    });

    test('should append the status filter to the space scoped request',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(emptyAlertPageJson),
        ),
      );

      // Act
      await gateway.getAlertsBySpace(
        spaceId: 'space-3',
        page: 0,
        size: 20,
        status: const ['ACTIVE'],
      );

      // Assert
      expect(adapter.singleRequest.queryParameters['status'], <String>['ACTIVE']);
    });

    test('should deserialize the page returned for the space', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            alertPageJson(
              content: [alertJson(spaceId: 'space-3', spaceName: 'Kitchen')],
              totalPages: 2,
              number: 1,
            ),
          ),
        ),
      );

      // Act
      final resource =
          await gateway.getAlertsBySpace(spaceId: 'space-3', page: 1, size: 20);

      // Assert
      expect(resource.content.single.spaceName, 'Kitchen');
      expect(resource.number, 1);
    });

    test('should surface a forbidden failure when the space is not visible',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            <String, dynamic>{'message': 'Space access denied'},
            statusCode: 403,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getAlertsBySpace(spaceId: 'space-3', page: 0, size: 20),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'statusCode',
            403,
          ),
        ),
      );
    });
  });

  group('AlertsHttpGateway.getCurrentUserDailyAlertSummary', () {
    test('should issue a GET on the daily summary path with the day window',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(<dynamic>[]),
        ),
      );

      // Act
      await gateway.getCurrentUserDailyAlertSummary(days: 30);

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, '/api/v1/alerts/daily-summary');
      expect(adapter.singleRequest.queryParameters, <String, dynamic>{
        'days': 30,
      });
    });

    test('should deserialize every day bucket of the summary', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(<dynamic>[
            <String, dynamic>{'date': '2024-05-01', 'count': 4},
            <String, dynamic>{'date': '2024-05-02', 'count': 0},
          ]),
        ),
      );

      // Act
      final resources = await gateway.getCurrentUserDailyAlertSummary(days: 30);

      // Assert
      expect(resources, hasLength(2));
      expect(resources.first.date, '2024-05-01');
      expect(resources.first.count, 4);
      expect(resources.last.count, 0);
    });

    test('should return an empty list when the summary has no data', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(<dynamic>[]),
        ),
      );

      // Act
      final resources = await gateway.getCurrentUserDailyAlertSummary(days: 7);

      // Assert
      expect(resources, isEmpty);
    });

    test('should throw a cast error when the summary body is an object instead '
        'of an array', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            <String, dynamic>{'count': 3},
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getCurrentUserDailyAlertSummary(days: 30),
        throwsA(isA<TypeError>()),
      );
    });

    test('should throw a cast error when a summary entry is not an object',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(<dynamic>['2024-05-01']),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getCurrentUserDailyAlertSummary(days: 30),
        throwsA(isA<TypeError>()),
      );
    });

    test('should surface a server error failure when the backend answers 500',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            <String, dynamic>{'message': 'Boom'},
            statusCode: 500,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getCurrentUserDailyAlertSummary(days: 30),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });
  });

  group('AlertsHttpGateway.getDailyAlertSummary', () {
    test('should issue a GET on the space scoped daily summary path', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(<dynamic>[]),
        ),
      );

      // Act
      await gateway.getDailyAlertSummary(spaceId: 'space-3', days: 14);

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(
        adapter.singleRequest.path,
        '/api/v1/spaces/space-3/alerts/daily-summary',
      );
      expect(adapter.singleRequest.queryParameters, <String, dynamic>{
        'days': 14,
      });
    });

    test('should deserialize every day bucket of the space summary', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(<dynamic>[
            <String, dynamic>{'date': '2024-05-03', 'count': 2},
          ]),
        ),
      );

      // Act
      final resources =
          await gateway.getDailyAlertSummary(spaceId: 'space-3', days: 30);

      // Assert
      expect(resources.single.date, '2024-05-03');
      expect(resources.single.count, 2);
    });

    test('should surface a not found failure when the space does not exist',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            <String, dynamic>{'message': 'Space not found'},
            statusCode: 404,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getDailyAlertSummary(spaceId: 'ghost', days: 30),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    });
  });

  group('AlertsHttpGateway json decoding', () {
    test('should decode a response whose content type declares json', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_) => FakeHttpClientAdapter.jsonBody(
            alertPageJson(content: [alertJson()]),
          ),
        ),
      );

      // Act
      final resource = await gateway.getAlerts(page: 0, size: 20);

      // Assert
      expect(resource.content.single.id, 'alert-1');
      expect(
        jsonEncode(resource.content.single.metric),
        '"PM25"',
        reason: 'The resource keeps the raw wire value until the transform runs',
      );
    });
  });
}