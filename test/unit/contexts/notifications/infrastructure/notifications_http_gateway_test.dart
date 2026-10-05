import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notifications/infrastructure/api/gateways/notifications_http.gateway.dart';

import '../helpers/fake_http_client_adapter.dart';
import '../helpers/notifications_fixtures.dart';

void main() {
  const baseUrl = 'https://clair.test';

  late Dio dio;
  late NotificationsHttpGateway gateway;
  late FakeHttpClientAdapter adapter;

  /// Builds the gateway on a real [Dio] whose transport is only able to reply
  /// with the canned body; the class under test is never mocked.
  void buildGateway(FakeHttpClientAdapter Function() createAdapter) {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    adapter = createAdapter();
    dio.httpClientAdapter = adapter;
    gateway = NotificationsHttpGateway(dio);
  }

  tearDown(() {
    dio.close(force: true);
  });

  group('NotificationsHttpGateway.getNotifications', () {
    test('should issue a GET on the push notifications path with the '
        'pagination query parameters', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_, _) => FakeHttpClientAdapter.jsonBody(notificationPageJson),
        ),
      );

      // Act
      await gateway.getNotifications(page: 2, size: 50);

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, '/api/v1/notifications/push');
      expect(adapter.singleRequest.baseUrl, baseUrl);
      expect(adapter.singleRequest.queryParameters, <String, dynamic>{
        'page': 2,
        'size': 50,
      });
    });

    test('should send the first page with the default size when no pagination '
        'is requested', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_, _) => FakeHttpClientAdapter.jsonBody(emptyNotificationsPageJson),
        ),
      );

      // Act
      await gateway.getNotifications(page: 0, size: 20);

      // Assert
      expect(adapter.singleRequest.uri.toString(),
          'https://clair.test/api/v1/notifications/push?page=0&size=20');
    });

    test('should send no header of its own because authentication belongs to the '
        'dio interceptor chain', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_, _) => FakeHttpClientAdapter.jsonBody(emptyNotificationsPageJson),
        ),
      );

      // Act
      await gateway.getNotifications(page: 0, size: 20);

      // Assert: this read needs no payload, so dio sends no header at all.
      expect(adapter.singleRequest.headers, isEmpty);
      expect(
        adapter.singleRequest.headers.keys.map((key) => key.toLowerCase()),
        isNot(contains('authorization')),
      );
    });

    test('should send no request body because the call is a read', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_, _) => FakeHttpClientAdapter.jsonBody(emptyNotificationsPageJson),
        ),
      );

      // Act
      await gateway.getNotifications(page: 0, size: 20);

      // Assert
      expect(adapter.singleRequest.data, isNull);
    });

    test('should deserialize the backend page into a resource', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_, _) => FakeHttpClientAdapter.jsonBody(<String, Object?>{
            'content': <Object?>[
              <String, Object?>{
                ...notificationJson,
                'id': 'notification-1',
              },
              <String, Object?>{
                ...notificationJson,
                'id': 'notification-2',
                'sent': false,
                'errorMessage': 'Push token expired',
              },
            ],
            'totalElements': 2,
            'totalPages': 1,
            'size': 20,
            'number': 0,
          }),
        ),
      );

      // Act
      final page = await gateway.getNotifications(page: 0, size: 20);

      // Assert
      expect(page.content, hasLength(2));
      expect(page.content.first.id, 'notification-1');
      expect(page.content.first.userId, 'user-1');
      expect(page.content.first.createdAt, '2024-05-01T10:30:00Z');
      expect(page.content.last.sent, isFalse);
      expect(page.content.last.errorMessage, 'Push token expired');
      expect(page.totalElements, 2);
      expect(page.totalPages, 1);
      expect(page.size, 20);
      expect(page.number, 0);
    });

    test('should deserialize an empty backend page into an empty resource',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_, _) => FakeHttpClientAdapter.jsonBody(emptyNotificationsPageJson),
        ),
      );

      // Act
      final page = await gateway.getNotifications(page: 0, size: 20);

      // Assert
      expect(page.content, isEmpty);
      expect(page.totalElements, 0);
    });

    test('should surface the backend message on a 400 answer', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_, _) => FakeHttpClientAdapter.jsonBody(
            <String, Object?>{'message': 'Invalid page size'},
            statusCode: 400,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getNotifications(page: 0, size: 20),
        throwsA(
          isA<DioException>()
              .having(
                (error) => error.type,
                'type',
                DioExceptionType.badResponse,
              )
              .having(
                (error) => error.response?.statusCode,
                'statusCode',
                400,
              )
              .having(
                (error) {
                  final data = error.response?.data;
                  return data is Map<String, dynamic> ? data['message'] : null;
                },
                'message',
                'Invalid page size',
              ),
        ),
      );
    });

    for (final MapEntry<String, int> status in <MapEntry<String, int>>[
      const MapEntry<String, int>('401', 401),
      const MapEntry<String, int>('403', 403),
      const MapEntry<String, int>('404', 404),
      const MapEntry<String, int>('409', 409),
    ]) {
      test('should surface the status code on a ${status.key} answer', () async {
        // Arrange
        buildGateway(
          () => FakeHttpClientAdapter(
            (_, _) => FakeHttpClientAdapter.jsonBody(
              <String, Object?>{'message': 'Denied'},
              statusCode: status.value,
            ),
          ),
        );

        // Act / Assert
        await expectLater(
          gateway.getNotifications(page: 0, size: 20),
          throwsA(
            isA<DioException>().having(
              (error) => error.response?.statusCode,
              'statusCode',
              status.value,
            ),
          ),
        );
      });
    }

    for (final int serverError in <int>[500, 502, 503]) {
      test('should surface the status code on a $serverError answer', () async {
        // Arrange
        buildGateway(
          () => FakeHttpClientAdapter(
            (_, _) => FakeHttpClientAdapter.jsonBody(
              <String, Object?>{'message': 'Down for maintenance'},
              statusCode: serverError,
            ),
          ),
        );

        // Act / Assert
        await expectLater(
          gateway.getNotifications(page: 0, size: 20),
          throwsA(
            isA<DioException>()
                .having(
                  (error) => error.type,
                  'type',
                  DioExceptionType.badResponse,
                )
                .having(
                  (error) => error.response?.statusCode,
                  'statusCode',
                  serverError,
                ),
          ),
        );
      });
    }

    test('should throw a cast error when the backend answers 204 without '
        'content', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_, _) => FakeHttpClientAdapter.emptyBody(204),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getNotifications(page: 0, size: 20),
        throwsA(isA<TypeError>()),
        reason: 'the gateway always casts the body to Map<String, dynamic>, so '
            'a 204 answer is not supported',
      );
    });

    test('should throw a cast error when the backend answers a JSON array',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_, _) => FakeHttpClientAdapter.jsonBody(<Object?>[1, 2, 3]),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getNotifications(page: 0, size: 20),
        throwsA(isA<TypeError>()),
      );
    });

    test('should surface a deserialization failure when the backend answers '
        'malformed JSON', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_, _) => FakeHttpClientAdapter.rawBody('{not json'),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getNotifications(page: 0, size: 20),
        throwsA(isA<DioException>()),
      );
    });

    test('should surface a connection timeout when the transport never '
        'connects', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (options, _) => throw DioException.connectionTimeout(
            timeout: const Duration(seconds: 5),
            requestOptions: options,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getNotifications(page: 0, size: 20),
        throwsA(
          isA<DioException>()
              .having(
                (error) => error.type,
                'type',
                DioExceptionType.connectionTimeout,
              )
              .having((error) => error.response, 'response', isNull),
        ),
      );
    });

    test('should surface a receive timeout when the response never arrives',
        () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (options, _) => throw DioException.receiveTimeout(
            timeout: const Duration(seconds: 5),
            requestOptions: options,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getNotifications(page: 0, size: 20),
        throwsA(
          isA<DioException>().having(
            (error) => error.type,
            'type',
            DioExceptionType.receiveTimeout,
          ),
        ),
      );
    });

    test('should record one request per call so pagination reaches the '
        'transport once per page', () async {
      // Arrange
      buildGateway(
        () => FakeHttpClientAdapter(
          (_, _) => FakeHttpClientAdapter.jsonBody(emptyNotificationsPageJson),
        ),
      );

      // Act
      await gateway.getNotifications(page: 0, size: 20);
      await gateway.getNotifications(page: 1, size: 20);

      // Assert
      expect(adapter.requests, hasLength(2));
      expect(
        adapter.requests
            .map((options) => options.queryParameters['page'])
            .toList(),
        <int>[0, 1],
      );
    });
  });
}