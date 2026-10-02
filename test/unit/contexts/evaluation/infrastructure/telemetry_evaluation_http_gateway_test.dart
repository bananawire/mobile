import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/evaluation/infrastructure/api/gateways/telemetry_evaluation_http.gateway.dart';

import '../../../../support/fake_http_client_adapter.dart';

void main() {
  group('TelemetryEvaluationHttpGateway', () {
    late Dio dio;

    setUp(() {
      dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.test.com',
          headers: {'Authorization': 'Bearer test-token'},
        ),
      );
    });

    test(
      'should send GET request to correct path and return map data when response is successful',
      () async {
        // Arrange
        const deviceId = 'device-123';
        final expectedPath =
            '${ApiConstants.apiPrefix}/evaluations/devices/$deviceId/latest';
        final responsePayload = {
          'id': 'eval-789',
          'deviceId': deviceId,
          'uptime': 12000,
          'connectivity': {
            'status': 'ONLINE',
            'network': 'WIFI',
            'signalStrength': -55,
          },
          'healthStatus': 1,
          'status': 'HEALTHY',
          'recordedAt': '2026-10-02T16:00:00.000Z',
        };

        RequestOptions? capturedOptions;
        dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          capturedOptions = options;
          return FakeHttpClientAdapter.jsonResponse(
            responsePayload,
            statusCode: 200,
          );
        });

        final gateway = TelemetryEvaluationHttpGateway(dio);

        // Act
        final result = await gateway.getLatestByDeviceRaw(deviceId);

        // Assert
        expect(capturedOptions, isNotNull);
        expect(capturedOptions!.method, equals('GET'));
        expect(capturedOptions!.path, equals(expectedPath));
        expect(
          capturedOptions!.headers['Authorization'],
          equals('Bearer test-token'),
        );
        expect(result, equals(responsePayload));
        expect(result['id'], equals('eval-789'));
        expect(result['deviceId'], equals(deviceId));
      },
    );

    test(
      'should also support getLatestTelemetryEvaluationByDevice alias with matching response',
      () async {
        // Arrange
        const deviceId = 'device-456';
        final expectedPath =
            '${ApiConstants.apiPrefix}/evaluations/devices/$deviceId/latest';
        final responsePayload = {
          'id': 'eval-456',
          'deviceId': deviceId,
          'uptime': 3600,
          'connectivity': {
            'status': 'ONLINE',
            'network': 'CELLULAR',
            'signalStrength': 4,
          },
          'healthStatus': 1,
          'status': 'HEALTHY',
          'recordedAt': '2026-10-02T17:00:00.000Z',
        };

        RequestOptions? capturedOptions;
        dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          capturedOptions = options;
          return FakeHttpClientAdapter.jsonResponse(
            responsePayload,
            statusCode: 200,
          );
        });

        final gateway = TelemetryEvaluationHttpGateway(dio);

        // Act
        final result = await gateway.getLatestTelemetryEvaluationByDevice(
          deviceId,
        );

        // Assert
        expect(capturedOptions, isNotNull);
        expect(capturedOptions!.method, equals('GET'));
        expect(capturedOptions!.path, equals(expectedPath));
        expect(result, equals(responsePayload));
      },
    );

    test(
      'should throw DioException when HTTP response status is 404 Not Found',
      () async {
        // Arrange
        const deviceId = 'unknown-device';
        dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          return FakeHttpClientAdapter.jsonResponse({
            'message': 'Evaluation not found for this device',
          }, statusCode: 404);
        });

        final gateway = TelemetryEvaluationHttpGateway(dio);

        // Act & Assert
        expect(
          () => gateway.getLatestByDeviceRaw(deviceId),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              equals(404),
            ),
          ),
        );
      },
    );

    test(
      'should throw DioException when HTTP response status is 500 Internal Server Error',
      () async {
        // Arrange
        const deviceId = 'device-error';
        dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          return FakeHttpClientAdapter.jsonResponse({
            'message': 'Internal Server Error',
          }, statusCode: 500);
        });

        final gateway = TelemetryEvaluationHttpGateway(dio);

        // Act & Assert
        expect(
          () => gateway.getLatestByDeviceRaw(deviceId),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              equals(500),
            ),
          ),
        );
      },
    );

    test('should throw Exception when response data is not a Map', () async {
      // Arrange
      const deviceId = 'device-invalid-data';
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        return FakeHttpClientAdapter.jsonResponse([
          'unexpected',
          'list',
          'data',
        ], statusCode: 200);
      });

      final gateway = TelemetryEvaluationHttpGateway(dio);

      // Act & Assert
      expect(
        () => gateway.getLatestByDeviceRaw(deviceId),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Unexpected latest evaluation response format'),
          ),
        ),
      );
    });
  });
}
