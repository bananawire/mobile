import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/evaluation/infrastructure/api/gateways/telemetry_evaluation_http.gateway.dart';

import '../helpers/evaluation_fixtures.dart';
import '../helpers/fake_http_client_adapter.dart';

/// The gateway converts any non-map body into this plain exception, so its
/// message is part of the observable contract. Meant to be wrapped in
/// [throwsA] by the caller.
Matcher throwsUnexpectedResponseFormat() {
  return predicate<Object>(
    (error) =>
        error is Exception &&
        error.toString() ==
            'Exception: Unexpected latest evaluation response format',
    'Exception: Unexpected latest evaluation response format',
  );
}

void main() {
  const baseUrl = 'https://clair.test';

  late Dio dio;
  late FakeHttpClientAdapter adapter;
  late TelemetryEvaluationHttpGateway gateway;

  /// Builds the gateway on top of a real [Dio] whose transport is the fake
  /// adapter, so the class under test is never mocked and no socket is opened.
  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    adapter = FakeHttpClientAdapter();
    dio.httpClientAdapter = adapter;
    gateway = TelemetryEvaluationHttpGateway(dio);
  });

  tearDown(() async {
    dio.close(force: true);
  });

  group('TelemetryEvaluationHttpGateway.getLatestByDeviceRaw', () {
    test(
      'should issue a GET on the latest-evaluation path of the device',
      () async {
        // Arrange
        adapter.enqueueJson(buildEvaluationJson());

        // Act
        await gateway.getLatestByDeviceRaw('device-1');

        // Assert
        expect(adapter.singleRequest.method, 'GET');
        expect(
          adapter.singleRequest.path,
          '/api/v1/evaluations/devices/device-1/latest',
        );
        expect(adapter.singleRequest.baseUrl, baseUrl);
        expect(
          adapter.singleRequest.uri.toString(),
          '$baseUrl/api/v1/evaluations/devices/device-1/latest',
        );
      },
    );

    test('should interpolate the device id verbatim into the path segment '
        'because it is not URI-encoded by the gateway', () async {
      // Arrange
      adapter.enqueueJson(buildEvaluationJson());

      // Act
      await gateway.getLatestByDeviceRaw('device 1/2');

      // Assert
      expect(
        adapter.singleRequest.path,
        '/api/v1/evaluations/devices/device 1/2/latest',
      );
    });

    test(
      'should send no query parameters and no body on the read request',
      () async {
        // Arrange
        adapter.enqueueJson(buildEvaluationJson());

        // Act
        await gateway.getLatestByDeviceRaw('device-1');

        // Assert
        expect(adapter.singleRequest.queryParameters, isEmpty);
        expect(adapter.singleRequest.data, isNull);
      },
    );

    test('should forward the authorization header configured on dio', () async {
      // Arrange
      dio.options.headers['Authorization'] = 'Bearer test-token';
      adapter.enqueueJson(buildEvaluationJson());

      // Act
      await gateway.getLatestByDeviceRaw('device-1');

      // Assert
      expect(
        adapter.singleRequest.headers['Authorization'],
        'Bearer test-token',
      );
    });

    test('should issue exactly one request per call', () async {
      // Arrange
      adapter.enqueueJson(buildEvaluationJson());

      // Act
      await gateway.getLatestByDeviceRaw('device-1');

      // Assert
      expect(adapter.requests, hasLength(1));
    });

    test('should deserialise the JSON body into the evaluation map', () async {
      // Arrange
      final payload = buildEvaluationJson(
        connectivity: buildConnectivityJson(signalStrength: -67),
      );
      adapter.enqueueJson(payload);

      // Act
      final result = await gateway.getLatestByDeviceRaw('device-1');

      // Assert
      expect(result, equals(payload));
      expect(result['connectivity'], isA<Map<String, dynamic>>());
      expect(result['recordedAt'], '2024-05-01T10:15:30Z');
    });

    test('should return an empty map when the backend answers with an empty '
        'JSON object', () async {
      // Arrange
      adapter.enqueueJson(<String, dynamic>{});

      // Act
      final result = await gateway.getLatestByDeviceRaw('device-1');

      // Assert
      expect(result, isEmpty);
    });

    test('should accept a 200 response with an empty body by failing with the '
        'unexpected-format exception', () async {
      // Arrange
      adapter.enqueueRawBody('', statusCode: 200);

      // Act / Assert
      await expectLater(
        gateway.getLatestByDeviceRaw('device-1'),
        throwsA(throwsUnexpectedResponseFormat()),
      );
    });

    test('should fail with the unexpected-format exception on a 204 no '
        'content response because no payload is returned', () async {
      // Arrange
      adapter.enqueueEmpty(statusCode: 204);

      // Act / Assert
      await expectLater(
        gateway.getLatestByDeviceRaw('device-1'),
        throwsA(throwsUnexpectedResponseFormat()),
      );
    });

    test('should fail with the unexpected-format exception when the body is a '
        'JSON list', () async {
      // Arrange
      adapter.enqueueRawBody('[{"id":"eval-1"}]', statusCode: 200);

      // Act / Assert
      await expectLater(
        gateway.getLatestByDeviceRaw('device-1'),
        throwsA(throwsUnexpectedResponseFormat()),
      );
    });

    test('should fail with the unexpected-format exception when the body is a '
        'JSON string', () async {
      // Arrange
      adapter.enqueueRawBody('"just-a-string"', statusCode: 200);

      // Act / Assert
      await expectLater(
        gateway.getLatestByDeviceRaw('device-1'),
        throwsA(throwsUnexpectedResponseFormat()),
      );
    });

    test('should fail with the unexpected-format exception when the body is '
        'the JSON literal null', () async {
      // Arrange
      adapter.enqueueRawBody('null', statusCode: 200);

      // Act / Assert
      await expectLater(
        gateway.getLatestByDeviceRaw('device-1'),
        throwsA(throwsUnexpectedResponseFormat()),
      );
    });

    test(
      'should surface a dio exception when the body is not valid JSON',
      () async {
        // Arrange
        adapter.enqueueRawBody('not-json', statusCode: 200);

        // Act / Assert
        await expectLater(
          gateway.getLatestByDeviceRaw('device-1'),
          throwsA(isA<DioException>()),
        );
      },
    );

    for (final statusCode in <int>[400, 401, 403, 404, 409, 500, 503]) {
      test('should propagate a $statusCode response as a bad-response dio '
          'exception', () async {
        // Arrange
        adapter.enqueueJson(<String, dynamic>{
          'message': 'error $statusCode',
        }, statusCode: statusCode);

        // Act / Assert
        await expectLater(
          gateway.getLatestByDeviceRaw('device-1'),
          throwsA(
            isA<DioException>()
                .having((e) => e.type, 'type', DioExceptionType.badResponse)
                .having((e) => e.response?.statusCode, 'statusCode', statusCode)
                .having(
                  (e) => e.response?.data,
                  'data',
                  equals(<String, dynamic>{'message': 'error $statusCode'}),
                ),
          ),
        );
      });
    }

    test('should propagate a 404 for an unknown device so the caller can tell '
        'a missing evaluation from an empty one', () async {
      // Arrange
      adapter.enqueueJson(<String, dynamic>{
        'message': 'Evaluation not found',
      }, statusCode: 404);

      // Act
      final options = <String, dynamic>{};
      try {
        await gateway.getLatestByDeviceRaw('device-missing');
      } on DioException catch (error) {
        options['type'] = error.type;
        options['statusCode'] = error.response?.statusCode;
        options['message'] = error.response?.data['message'];
      }

      // Assert
      expect(options['type'], DioExceptionType.badResponse);
      expect(options['statusCode'], 404);
      expect(options['message'], 'Evaluation not found');
    });

    test('should propagate a receive timeout raised by the transport without '
        'wrapping it', () async {
      // Arrange
      final options = RequestOptions(path: '/api/v1/evaluations');
      adapter.enqueueError(
        DioException.receiveTimeout(
          timeout: const Duration(milliseconds: 50),
          requestOptions: options,
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getLatestByDeviceRaw('device-1'),
        throwsA(
          isA<DioException>()
              .having((e) => e.type, 'type', DioExceptionType.receiveTimeout)
              .having(
                (e) => e.toString(),
                'toString',
                startsWith('DioException [receive timeout]: '),
              ),
        ),
      );
    });

    test('should propagate a connection error raised by the transport without '
        'wrapping it', () async {
      // Arrange
      final options = RequestOptions(path: '/api/v1/evaluations');
      adapter.enqueueError(
        DioException.connectionError(
          requestOptions: options,
          reason: 'Connection refused',
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getLatestByDeviceRaw('device-1'),
        throwsA(
          isA<DioException>()
              .having((e) => e.type, 'type', DioExceptionType.connectionError)
              .having(
                (e) => e.toString(),
                'toString',
                contains('Connection refused'),
              ),
        ),
      );
    });

    test('should propagate a cancel signal raised by the transport without '
        'wrapping it', () async {
      // Arrange
      final options = RequestOptions(path: '/api/v1/evaluations');
      adapter.enqueueError(
        DioException.requestCancelled(
          requestOptions: options,
          reason: 'cancelled by the caller',
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getLatestByDeviceRaw('device-1'),
        throwsA(
          isA<DioException>()
              .having((e) => e.type, 'type', DioExceptionType.cancel)
              .having(
                (e) => e.toString(),
                'toString',
                startsWith('DioException [request cancelled]: '),
              ),
        ),
      );
    });

    test('should surface the recorded request path for cross checking against '
        'the api prefix constant', () async {
      // Arrange
      adapter.enqueueJson(buildEvaluationJson());

      // Act
      await gateway.getLatestByDeviceRaw('device-9');

      // Assert
      expect(adapter.singleRequest.path, startsWith('/api/v1/'));
      expect(adapter.singleRequest.path, endsWith('/devices/device-9/latest'));
    });

    test('should keep the raw JSON of an evaluation intact when the backend '
        'adds unknown fields', () async {
      // Arrange
      adapter.enqueueRawBody(
        jsonEncode(<String, dynamic>{
          'id': 'eval-1',
          'deviceId': 'device-1',
          'uptime': 7200,
          'connectivity': <String, dynamic>{
            'status': 'ONLINE',
            'network': 'wifi',
            'signalStrength': -57,
            'unknownField': true,
          },
          'healthStatus': 92,
          'status': 'HEALTHY',
          'recordedAt': '2024-05-01T10:15:30Z',
          'traceId': 'abc-123',
        }),
      );

      // Act
      final result = await gateway.getLatestByDeviceRaw('device-1');

      // Assert
      expect(result['traceId'], 'abc-123');
      expect(
        (result['connectivity'] as Map<String, dynamic>)['unknownField'],
        isTrue,
      );
    });
  });
}
