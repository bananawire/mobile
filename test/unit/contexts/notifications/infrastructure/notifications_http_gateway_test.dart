import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notifications/infrastructure/api/gateways/notifications_http.gateway.dart';
import '../../../../support/fake_http_client_adapter.dart';

void main() {
  late Dio dio;
  late NotificationsHttpGateway gateway;

  setUp(() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.clair.com',
        headers: {'Authorization': 'Bearer test-jwt-token'},
      ),
    );
    gateway = NotificationsHttpGateway(dio);
  });

  group('NotificationsHttpGateway', () {
    test(
      'should send GET request to correct path with pagination query parameters and headers',
      () async {
        // Arrange
        RequestOptions? capturedOptions;
        final fakeData = {
          'content': [
            {
              'id': 'notif-1',
              'userId': 'usr-1',
              'title': 'High CO2',
              'message': 'Living room CO2 exceeded 1000 ppm',
              'sent': true,
              'createdAt': '2026-10-02T10:00:00Z',
              'updatedAt': '2026-10-02T10:00:00Z',
            },
          ],
          'totalElements': 1,
          'totalPages': 1,
          'size': 10,
          'number': 0,
        };

        dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          capturedOptions = options;
          return FakeHttpClientAdapter.jsonResponse(fakeData, statusCode: 200);
        });

        // Act
        final result = await gateway.getNotifications(page: 0, size: 10);

        // Assert
        expect(capturedOptions, isNotNull);
        expect(capturedOptions!.method, equals('GET'));
        expect(capturedOptions!.path, contains('/notifications'));
        expect(capturedOptions!.path, equals('/api/v1/notifications/push'));
        expect(capturedOptions!.queryParameters['page'], equals(0));
        expect(capturedOptions!.queryParameters['size'], equals(10));
        expect(
          capturedOptions!.headers['Authorization'],
          equals('Bearer test-jwt-token'),
        );

        expect(result.content.length, equals(1));
        expect(result.content.first.id, equals('notif-1'));
        expect(result.content.first.title, equals('High CO2'));
        expect(result.totalElements, equals(1));
        expect(result.totalPages, equals(1));
        expect(result.size, equals(10));
        expect(result.number, equals(0));
      },
    );

    test(
      'should throw DioException when server responds with 401 Unauthorized',
      () async {
        // Arrange
        dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          return FakeHttpClientAdapter.jsonResponse({
            'message': 'Unauthorized',
          }, statusCode: 401);
        });

        // Act & Assert
        expect(
          () => gateway.getNotifications(page: 0, size: 20),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              equals(401),
            ),
          ),
        );
      },
    );

    test(
      'should throw DioException when server responds with 500 Internal Server Error',
      () async {
        // Arrange
        dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          return FakeHttpClientAdapter.jsonResponse({
            'message': 'Internal Server Error',
          }, statusCode: 500);
        });

        // Act & Assert
        expect(
          () => gateway.getNotifications(page: 0, size: 20),
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

    test('should throw DioException when network connection fails', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'No internet connection',
        );
      });

      // Act & Assert
      expect(
        () => gateway.getNotifications(page: 0, size: 20),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            equals(DioExceptionType.connectionError),
          ),
        ),
      );
    });
  });
}
