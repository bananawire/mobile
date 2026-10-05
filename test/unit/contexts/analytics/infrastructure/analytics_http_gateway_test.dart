import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/infrastructure/api/gateways/analytics_http.gateway.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:mocktail/mocktail.dart';

import '../analytics_fixtures.dart';
import 'fake_analytics_http_adapter.dart';

class MockTokenLocalStorage extends Mock implements TokenLocalStorage {}

void main() {
  const baseUrl = 'https://clair.test';

  late Dio dio;
  late MockTokenLocalStorage tokenStorage;
  late AnalyticsHttpGateway gateway;
  late FakeAnalyticsHttpAdapter adapter;

  /// Builds the gateway on top of a real [Dio] whose transport only replies
  /// with [responder]; the class under test is never mocked.
  void buildGateway(FakeAnalyticsHttpAdapter Function() createAdapter) {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    adapter = createAdapter();
    dio.httpClientAdapter = adapter;
    tokenStorage = MockTokenLocalStorage();
    gateway = AnalyticsHttpGateway(dio, tokenStorage);
  }

  tearDown(() {
    dio.close(force: true);
  });

  group('AnalyticsHttpGateway.getDashboardMetrics', () {
    test('should issue a GET on the live path without query parameters when '
        'no period is requested', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(dashboardMetricsJson()),
        ),
      );

      // Act
      await gateway.getDashboardMetrics(deviceId: 'device-1');

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(
        adapter.singleRequest.path,
        '/api/v1/analytics/devices/device-1/live',
      );
      expect(adapter.singleRequest.queryParameters, isEmpty);
      expect(adapter.singleRequest.baseUrl, baseUrl);
      expect(adapter.singleRequest.data, isNull);
    });

    test('should route an explicit LIVE period to the live path and drop the '
        'redundant period parameter', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(dashboardMetricsJson()),
        ),
      );

      // Act
      await gateway.getDashboardMetrics(deviceId: 'device-1', period: 'LIVE');

      // Assert
      expect(
        adapter.singleRequest.path,
        '/api/v1/analytics/devices/device-1/live',
      );
      expect(adapter.singleRequest.queryParameters, isEmpty);
    });

    test('should treat a lowercase live period as live because the comparison '
        'is case insensitive', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(dashboardMetricsJson()),
        ),
      );

      // Act
      await gateway.getDashboardMetrics(deviceId: 'device-1', period: 'live');

      // Assert
      expect(
        adapter.singleRequest.path,
        '/api/v1/analytics/devices/device-1/live',
      );
      expect(adapter.singleRequest.queryParameters, isEmpty);
    });

    test('should route a historical period to the historical path with the '
        'period parameter', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(dashboardMetricsJson()),
        ),
      );

      // Act
      await gateway.getDashboardMetrics(deviceId: 'device-1', period: 'DAY');

      // Assert
      expect(
        adapter.singleRequest.path,
        '/api/v1/analytics/devices/device-1/historical',
      );
      expect(
        adapter.singleRequest.queryParameters,
        <String, dynamic>{'period': 'DAY'},
      );
    });

    test('should send the date range as ISO encoded query parameters', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(dashboardMetricsJson()),
        ),
      );

      // Act
      await gateway.getDashboardMetrics(
        deviceId: 'device-1',
        period: 'WEEK',
        startDate: '2024-05-01T00:00:00Z',
        endDate: '2024-05-08T00:00:00Z',
      );

      // Assert
      expect(
        adapter.singleRequest.path,
        '/api/v1/analytics/devices/device-1/historical',
      );
      expect(adapter.singleRequest.queryParameters, <String, dynamic>{
        'period': 'WEEK',
        'startDate': '2024-05-01T00:00:00Z',
        'endDate': '2024-05-08T00:00:00Z',
      });

      final rawQuery = adapter.singleRequest.uri.query;
      expect(rawQuery, contains('startDate=2024-05-01T00%3A00%3A00Z'));
      expect(rawQuery, contains('endDate=2024-05-08T00%3A00%3A00Z'));
      expect(
        Uri.decodeQueryComponent(rawQuery),
        contains('startDate=2024-05-01T00:00:00Z'),
      );
    });

    test('should send a date range even when no period is given so the '
        'gateway can serve a custom range', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(dashboardMetricsJson()),
        ),
      );

      // Act
      await gateway.getDashboardMetrics(
        deviceId: 'device-1',
        startDate: '2024-05-01T00:00:00Z',
        endDate: '2024-05-08T00:00:00Z',
      );

      // Assert
      expect(
        adapter.singleRequest.path,
        '/api/v1/analytics/devices/device-1/live',
      );
      expect(adapter.singleRequest.queryParameters, <String, dynamic>{
        'startDate': '2024-05-01T00:00:00Z',
        'endDate': '2024-05-08T00:00:00Z',
      });
    });

    test('should deserialize the response into a populated resource', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(
            dashboardMetricsJson(
              aqiValue: 128.5,
              aqiCategory: 'Unhealthy for Sensitive',
              averageCo2: 812.25,
              averagePm2_5: 47.9,
              averageTemperature: 24.75,
              averageHumidity: 63,
              co2DeltaPercentage: 4.25,
              pm2_5DeltaPercentage: -18.5,
              temperatureDeltaPercentage: 1.5,
              humidityDeltaPercentage: -0.75,
              calculatedAt: '2024-05-01T10:15:30Z',
            ),
          ),
        ),
      );

      // Act
      final resource = await gateway.getDashboardMetrics(deviceId: 'device-1');

      // Assert
      expect(resource.aqiValue, 128.5);
      expect(resource.aqiCategory, 'Unhealthy for Sensitive');
      expect(resource.averageCo2, 812.25);
      expect(resource.averagePm2_5, 47.9);
      expect(resource.averageTemperature, 24.75);
      expect(resource.averageHumidity, 63.0);
      expect(resource.co2DeltaPercentage, 4.25);
      expect(resource.pm2_5DeltaPercentage, -18.5);
      expect(resource.temperatureDeltaPercentage, 1.5);
      expect(resource.humidityDeltaPercentage, -0.75);
      expect(resource.calculatedAt, '2024-05-01T10:15:30Z');
    });

    test('should deserialize an empty payload into a zeroed resource', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(emptyDashboardMetricsJson),
        ),
      );

      // Act
      final resource = await gateway.getDashboardMetrics(deviceId: 'device-1');

      // Assert
      expect(resource.aqiValue, 0);
      expect(resource.aqiCategory, kFallbackAqiCategory);
      expect(resource.averageCo2, 0);
      expect(resource.calculatedAt, '');
    });

    test('should throw a type error when the body is a JSON array because the '
        'gateway casts it to a map', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(<int>[1, 2, 3]),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getDashboardMetrics(deviceId: 'device-1'),
        throwsA(isA<TypeError>()),
      );
    });

    test('should surface a non-JSON body as a DioException from the decoder',
        () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.malformedBody(),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getDashboardMetrics(deviceId: 'device-1'),
        throwsA(
          isA<DioException>().having((e) => e.type, 'type', DioExceptionType.unknown),
        ),
      );
    });

    test('should throw a type error on a 204 No Content answer because there '
        'is no map to deserialize', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.emptyBody(204),
        ),
      );

      // Act
      Object? thrown;
      try {
        await gateway.getDashboardMetrics(deviceId: 'device-1');
      } catch (error) {
        thrown = error;
      }

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(thrown, isNotNull);
      expect(thrown, isA<TypeError>());
    });

    test('should not read the access token for a REST read because only the '
        'SSE stream authenticates', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(dashboardMetricsJson()),
        ),
      );

      // Act
      await gateway.getDashboardMetrics(deviceId: 'device-1', period: 'DAY');

      // Assert
      verifyNever(() => tokenStorage.getAccessToken());
      expect(
        adapter.singleRequest.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('authorization')),
      );
      expect(
        adapter.singleRequest.headers[Headers.acceptHeader],
        isNot(contains('text/event-stream')),
      );
    });

    group('error propagation', () {
      const statusCases = <int, String>{
        400: 'Bad Request',
        401: 'Unauthorized',
        403: 'Forbidden',
        404: 'Not Found',
        409: 'Conflict',
        500: 'Internal Server Error',
        503: 'Service Unavailable',
      };

      statusCases.forEach((statusCode, label) {
        test('should surface a $statusCode $label as a DioException carrying '
            'the server body', () async {
          // Arrange
          buildGateway(
            () => FakeAnalyticsHttpAdapter(
              (_) => FakeAnalyticsHttpAdapter.jsonBody(
                <String, dynamic>{'message': label},
                statusCode: statusCode,
              ),
            ),
          );

          // Act
          final future = gateway.getDashboardMetrics(deviceId: 'device-1');

          // Assert
          await expectLater(
            future,
            throwsA(
              isA<DioException>()
                  .having((e) => e.type, 'type', DioExceptionType.badResponse)
                  .having((e) => e.response?.statusCode, 'statusCode', statusCode)
                  .having(
                    (e) => (e.response?.data as Map<String, dynamic>)['message'],
                    'body message',
                    label,
                  ),
            ),
          );
        });
      });

      test('should surface a connection timeout as a DioException of type '
          'connectionTimeout', () async {
        // Arrange
        buildGateway(
          () => FakeAnalyticsHttpAdapter(
            (_) => throw DioException.connectionTimeout(
              timeout: const Duration(seconds: 5),
              requestOptions: RequestOptions(path: '/api/v1/analytics'),
            ),
          ),
        );

        // Act / Assert
        await expectLater(
          gateway.getDashboardMetrics(deviceId: 'device-1'),
          throwsA(
            isA<DioException>()
                .having((e) => e.type, 'type', DioExceptionType.connectionTimeout),
          ),
        );
      });
    });
  });

  group('AnalyticsHttpGateway.getTrends', () {
    test('should issue a GET on the trends path without query parameters when '
        'no filters are given', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(
            trendsJson(dataPoints: <dynamic>[]),
          ),
        ),
      );

      // Act
      await gateway.getTrends(deviceId: 'device-1');

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(
        adapter.singleRequest.path,
        '/api/v1/analytics/devices/device-1/trends',
      );
      expect(adapter.singleRequest.queryParameters, isEmpty);
      expect(adapter.singleRequest.data, isNull);
    });

    test('should send the trend period and date range as query parameters', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(
            trendsJson(dataPoints: <dynamic>[]),
          ),
        ),
      );

      // Act
      await gateway.getTrends(
        deviceId: 'device-1',
        period: 'DAY',
        startDate: '2024-05-01T00:00:00Z',
        endDate: '2024-05-02T00:00:00Z',
      );

      // Assert
      expect(
        adapter.singleRequest.queryParameters,
        <String, dynamic>{
          'period': 'DAY',
          'startDate': '2024-05-01T00:00:00Z',
          'endDate': '2024-05-02T00:00:00Z',
        },
      );
      expect(
        adapter.singleRequest.uri.query,
        contains('endDate=2024-05-02T00%3A00%3A00Z'),
      );
    });

    test('should forward a LIVE period for trends because the trends endpoint '
        'always declares it explicitly', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(
            trendsJson(dataPoints: <dynamic>[]),
          ),
        ),
      );

      // Act
      await gateway.getTrends(deviceId: 'device-1', period: 'LIVE');

      // Assert
      expect(
        adapter.singleRequest.path,
        '/api/v1/analytics/devices/device-1/trends',
      );
      expect(
        adapter.singleRequest.queryParameters,
        <String, dynamic>{'period': 'LIVE'},
      );
    });

    test('should deserialize the nested series in payload order', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(
            trendsJson(dataPoints: <dynamic>[
              trendPointJson(timestamp: '2024-05-01T09:00:00Z', aqiValue: 10),
              trendPointJson(timestamp: '2024-05-01T09:05:00Z', aqiValue: 20),
            ]),
          ),
        ),
      );

      // Act
      final resource = await gateway.getTrends(deviceId: 'device-1', period: 'DAY');

      // Assert
      expect(resource.dataPoints, hasLength(2));
      expect(resource.dataPoints.first.timestamp, '2024-05-01T09:00:00Z');
      expect(resource.dataPoints.first.aqiValue, 10);
      expect(resource.dataPoints.last.aqiValue, 20);
    });

    test('should deserialize a payload without a series into an empty list',
        () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(trendsJson()),
        ),
      );

      // Act
      final resource = await gateway.getTrends(deviceId: 'device-1', period: 'DAY');

      // Assert
      expect(resource.dataPoints, isEmpty);
    });

    test('should surface a 404 as a DioException so the query service can '
        'render the offline message', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(
            <String, dynamic>{'message': 'device-1 has no recent live telemetry'},
            statusCode: 404,
          ),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getTrends(deviceId: 'device-1', period: 'DAY'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    });

    test('should throw a type error when the trends body is not an object',
        () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody('nope'),
        ),
      );

      // Act / Assert
      await expectLater(
        gateway.getTrends(deviceId: 'device-1', period: 'DAY'),
        throwsA(isA<TypeError>()),
      );
    });

    test('should not read the access token for a trends read', () async {
      // Arrange
      buildGateway(
        () => FakeAnalyticsHttpAdapter(
          (_) => FakeAnalyticsHttpAdapter.jsonBody(
            trendsJson(dataPoints: <dynamic>[]),
          ),
        ),
      );

      // Act
      await gateway.getTrends(deviceId: 'device-1', period: 'DAY');

      // Assert
      verifyNever(() => tokenStorage.getAccessToken());
    });
  });
}