import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/infrastructure/api/gateways/alerts_http.gateway.dart';

import '../../../../support/fake_http_client_adapter.dart';

void main() {
  group('AlertsHttpGateway', () {
    late Dio dio;
    late AlertsHttpGateway gateway;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
    });

    group('getAlerts', () {
      test(
        'should request GET /api/v1/alerts with page and size query parameters',
        () async {
          // Arrange
          RequestOptions? capturedOptions;
          dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
            capturedOptions = options;
            return FakeHttpClientAdapter.jsonResponse({
              'content': [
                {
                  'id': 'al-1',
                  'deviceId': 'dev-1',
                  'metric': 'CO2',
                  'metricLabel': 'CO2',
                  'metricUnit': 'ppm',
                  'thresholdValue': 1000,
                  'actualValue': 1100,
                  'message': 'Alert 1',
                  'status': 'ACTIVE',
                  'severity': 'CRITICAL',
                  'occurredAt': '2026-10-02T10:00:00Z',
                  'createdAt': '2026-10-02T10:00:00Z',
                },
              ],
              'totalElements': 1,
              'totalPages': 1,
              'size': 20,
              'number': 0,
            });
          });
          gateway = AlertsHttpGateway(dio);

          // Act
          final result = await gateway.getAlerts(page: 0, size: 20);

          // Assert
          expect(capturedOptions, isNotNull);
          expect(capturedOptions!.method, equals('GET'));
          expect(capturedOptions!.path, equals('/api/v1/alerts'));
          expect(capturedOptions!.queryParameters['page'], equals(0));
          expect(capturedOptions!.queryParameters['size'], equals(20));
          expect(
            capturedOptions!.queryParameters.containsKey('status'),
            isFalse,
          );

          expect(result.content.length, equals(1));
          expect(result.content.first.id, equals('al-1'));
          expect(result.totalElements, equals(1));
        },
      );

      test(
        'should include status in query parameters when status filter is provided',
        () async {
          // Arrange
          RequestOptions? capturedOptions;
          dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
            capturedOptions = options;
            return FakeHttpClientAdapter.jsonResponse({
              'content': [],
              'totalElements': 0,
              'totalPages': 0,
              'size': 10,
              'number': 1,
            });
          });
          gateway = AlertsHttpGateway(dio);

          // Act
          final result = await gateway.getAlerts(
            page: 1,
            size: 10,
            status: ['ACTIVE', 'ACKNOWLEDGED'],
          );

          // Assert
          expect(capturedOptions!.queryParameters['page'], equals(1));
          expect(capturedOptions!.queryParameters['size'], equals(10));
          expect(
            capturedOptions!.queryParameters['status'],
            equals(['ACTIVE', 'ACKNOWLEDGED']),
          );
          expect(result.content, isEmpty);
        },
      );

      test('should throw DioException when server returns 500 error', () async {
        // Arrange
        dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          return FakeHttpClientAdapter.jsonResponse({
            'message': 'Internal Server Error',
          }, statusCode: 500);
        });
        gateway = AlertsHttpGateway(dio);

        // Act & Assert
        expect(
          () => gateway.getAlerts(page: 0, size: 20),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              500,
            ),
          ),
        );
      });
    });

    group('getAlertsByDevice', () {
      test(
        'should request GET /api/v1/devices/{deviceId}/alerts with correct parameters',
        () async {
          // Arrange
          RequestOptions? capturedOptions;
          dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
            capturedOptions = options;
            return FakeHttpClientAdapter.jsonResponse({
              'content': [],
              'totalElements': 0,
              'totalPages': 0,
              'size': 20,
              'number': 0,
            });
          });
          gateway = AlertsHttpGateway(dio);

          // Act
          await gateway.getAlertsByDevice(
            deviceId: 'device-999',
            page: 2,
            size: 15,
            status: ['RESOLVED'],
          );

          // Assert
          expect(capturedOptions!.method, equals('GET'));
          expect(
            capturedOptions!.path,
            equals('/api/v1/devices/device-999/alerts'),
          );
          expect(capturedOptions!.queryParameters['page'], equals(2));
          expect(capturedOptions!.queryParameters['size'], equals(15));
          expect(
            capturedOptions!.queryParameters['status'],
            equals(['RESOLVED']),
          );
        },
      );

      test(
        'should throw DioException when device is not found (404)',
        () async {
          // Arrange
          dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
            return FakeHttpClientAdapter.jsonResponse({
              'message': 'Device not found',
            }, statusCode: 404);
          });
          gateway = AlertsHttpGateway(dio);

          // Act & Assert
          expect(
            () => gateway.getAlertsByDevice(
              deviceId: 'invalid-device',
              page: 0,
              size: 20,
            ),
            throwsA(
              isA<DioException>().having(
                (e) => e.response?.statusCode,
                'statusCode',
                404,
              ),
            ),
          );
        },
      );
    });

    group('getAlertsBySpace', () {
      test(
        'should request GET /api/v1/spaces/{spaceId}/alerts with correct parameters',
        () async {
          // Arrange
          RequestOptions? capturedOptions;
          dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
            capturedOptions = options;
            return FakeHttpClientAdapter.jsonResponse({
              'content': [],
              'totalElements': 0,
              'totalPages': 0,
              'size': 20,
              'number': 0,
            });
          });
          gateway = AlertsHttpGateway(dio);

          // Act
          await gateway.getAlertsBySpace(
            spaceId: 'space-888',
            page: 0,
            size: 25,
            status: ['ACTIVE'],
          );

          // Assert
          expect(capturedOptions!.method, equals('GET'));
          expect(
            capturedOptions!.path,
            equals('/api/v1/spaces/space-888/alerts'),
          );
          expect(capturedOptions!.queryParameters['page'], equals(0));
          expect(capturedOptions!.queryParameters['size'], equals(25));
          expect(
            capturedOptions!.queryParameters['status'],
            equals(['ACTIVE']),
          );
        },
      );

      test(
        'should throw DioException when access to space is forbidden (403)',
        () async {
          // Arrange
          dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
            return FakeHttpClientAdapter.jsonResponse({
              'message': 'Forbidden',
            }, statusCode: 403);
          });
          gateway = AlertsHttpGateway(dio);

          // Act & Assert
          expect(
            () => gateway.getAlertsBySpace(
              spaceId: 'space-forbidden',
              page: 0,
              size: 20,
            ),
            throwsA(
              isA<DioException>().having(
                (e) => e.response?.statusCode,
                'statusCode',
                403,
              ),
            ),
          );
        },
      );
    });

    group('getCurrentUserDailyAlertSummary', () {
      test(
        'should request GET /api/v1/alerts/daily-summary with days parameter and parse response',
        () async {
          // Arrange
          RequestOptions? capturedOptions;
          dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
            capturedOptions = options;
            return FakeHttpClientAdapter.jsonResponse([
              {'date': '2026-10-01', 'count': 4},
              {'date': '2026-10-02', 'count': 9},
            ]);
          });
          gateway = AlertsHttpGateway(dio);

          // Act
          final results = await gateway.getCurrentUserDailyAlertSummary(
            days: 14,
          );

          // Assert
          expect(capturedOptions!.method, equals('GET'));
          expect(capturedOptions!.path, equals('/api/v1/alerts/daily-summary'));
          expect(capturedOptions!.queryParameters['days'], equals(14));
          expect(results.length, equals(2));
          expect(results[0].date, equals('2026-10-01'));
          expect(results[0].count, equals(4));
          expect(results[1].date, equals('2026-10-02'));
          expect(results[1].count, equals(9));
        },
      );

      test('should throw DioException on network failure', () async {
        // Arrange
        dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'Connection failed',
          );
        });
        gateway = AlertsHttpGateway(dio);

        // Act & Assert
        expect(
          () => gateway.getCurrentUserDailyAlertSummary(days: 30),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getDailyAlertSummary', () {
      test(
        'should request GET /api/v1/spaces/{spaceId}/alerts/daily-summary with days parameter',
        () async {
          // Arrange
          RequestOptions? capturedOptions;
          dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
            capturedOptions = options;
            return FakeHttpClientAdapter.jsonResponse([
              {'date': '2026-10-02', 'count': 3},
            ]);
          });
          gateway = AlertsHttpGateway(dio);

          // Act
          final results = await gateway.getDailyAlertSummary(
            spaceId: 'sp-1',
            days: 7,
          );

          // Assert
          expect(capturedOptions!.method, equals('GET'));
          expect(
            capturedOptions!.path,
            equals('/api/v1/spaces/sp-1/alerts/daily-summary'),
          );
          expect(capturedOptions!.queryParameters['days'], equals(7));
          expect(results.length, equals(1));
          expect(results.first.date, equals('2026-10-02'));
          expect(results.first.count, equals(3));
        },
      );

      test(
        'should throw DioException when space summary returns 500',
        () async {
          // Arrange
          dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
            return FakeHttpClientAdapter.jsonResponse({
              'message': 'Space summary failed',
            }, statusCode: 500);
          });
          gateway = AlertsHttpGateway(dio);

          // Act & Assert
          expect(
            () => gateway.getDailyAlertSummary(spaceId: 'sp-err', days: 30),
            throwsA(
              isA<DioException>().having(
                (e) => e.response?.statusCode,
                'statusCode',
                500,
              ),
            ),
          );
        },
      );
    });
  });
}
