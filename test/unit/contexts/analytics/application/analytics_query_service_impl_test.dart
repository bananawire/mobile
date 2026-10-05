import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/application/internal/queryservices/analytics_query_service_impl.dart';
import 'package:mobile/analytics/domain/model/queries/get_dashboard_metrics.query.dart';
import 'package:mobile/analytics/domain/model/queries/get_trends.query.dart';
import 'package:mobile/analytics/domain/model/valueobjects/live_telemetry.valueobject.dart';
import 'package:mobile/analytics/infrastructure/api/gateways/analytics.gateway.dart';
import 'package:mobile/analytics/interfaces/rest/resources/dashboard_metrics.resource.dart';
import 'package:mobile/analytics/interfaces/rest/resources/trends.resource.dart';
import 'package:mobile/core/failure.dart';
import 'package:mocktail/mocktail.dart';

import '../analytics_fixtures.dart';

class MockAnalyticsGateway extends Mock implements AnalyticsGateway {}

void main() {
  late MockAnalyticsGateway gateway;
  late AnalyticsQueryServiceImpl service;

  /// Builds a `DioException` carrying an HTTP [statusCode] plus a JSON body so
  /// that `_mapError` is exercised through its real branches.
  DioException httpError(
    int statusCode, {
    Object? body,
    String? messageOverride,
  }) {
    final requestOptions = RequestOptions(path: '/api/v1/analytics');
    final response = Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: body,
    );
    return DioException.badResponse(
      statusCode: statusCode,
      requestOptions: requestOptions,
      response: response,
    ).copyWith(message: messageOverride);
  }

  void stubMetrics(DashboardMetricsResource resource) {
    when(
      () => gateway.getDashboardMetrics(
        deviceId: any(named: 'deviceId'),
        period: any(named: 'period'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => resource);
  }

  void stubTrends(TrendsResource resource) {
    when(
      () => gateway.getTrends(
        deviceId: any(named: 'deviceId'),
        period: any(named: 'period'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => resource);
  }

  void stubMetricsFailure(DioException error) {
    when(
      () => gateway.getDashboardMetrics(
        deviceId: any(named: 'deviceId'),
        period: any(named: 'period'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => throw error);
  }

  void stubTrendsFailure(DioException error) {
    when(
      () => gateway.getTrends(
        deviceId: any(named: 'deviceId'),
        period: any(named: 'period'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => throw error);
  }

  /// Reads the payload of a `Left` result, failing the test otherwise.
  Failure failureOf(dynamic either) {
    expect(either.isLeft(), isTrue, reason: 'expected a Left result');
    return either.fold((failure) => failure, (_) => fail('expected a Left'));
  }

  setUp(() {
    gateway = MockAnalyticsGateway();
    service = AnalyticsQueryServiceImpl(gateway);
  });

  group('AnalyticsQueryServiceImpl.handleGetDashboardMetrics', () {
    test('should return a right aggregate with the mapped domain data when '
        'the gateway succeeds', () async {
      // Arrange
      stubMetrics(
        DashboardMetricsResource.fromJson(
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
      );

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      expect(result.isRight(), isTrue);
      final metrics = result.fold(
        (_) => fail('expected a Right aggregate but got a Left'),
        (value) => value,
      );
      expect(metrics.aqi.value, 128.5);
      expect(metrics.aqi.category, 'Unhealthy for Sensitive');
      expect(metrics.co2.value, 812.25);
      expect(metrics.co2.deltaPercentage, 4.25);
      expect(metrics.pm2_5.value, 47.9);
      expect(metrics.pm2_5.deltaPercentage, -18.5);
      expect(metrics.temperature.value, 24.75);
      expect(metrics.temperature.deltaPercentage, 1.5);
      expect(metrics.humidity.value, 63.0);
      expect(metrics.humidity.deltaPercentage, -0.75);
      expect(metrics.calculatedAt, '2024-05-01T10:15:30Z');
    });

    test('should forward the live period to the gateway boundary', () async {
      // Arrange
      stubMetrics(buildDashboardMetricsResource());

      // Act
      await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-42', period: 'LIVE'),
      );

      // Assert
      final captured = verify(
        () => gateway.getDashboardMetrics(
          deviceId: captureAny(named: 'deviceId'),
          period: captureAny(named: 'period'),
          startDate: captureAny(named: 'startDate'),
          endDate: captureAny(named: 'endDate'),
        ),
      ).captured;

      expect(captured, hasLength(4));
      expect(captured[0], 'device-42');
      expect(captured[1], 'LIVE');
      expect(captured[2], isNull);
      expect(captured[3], isNull);
    });

    test('should forward a historical period with its date range to the '
        'gateway boundary', () async {
      // Arrange
      stubMetrics(buildDashboardMetricsResource());

      // Act
      await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(
          deviceId: 'device-42',
          period: 'DAY',
          startDate: '2024-05-01T00:00:00Z',
          endDate: '2024-05-02T00:00:00Z',
        ),
      );

      // Assert
      final captured = verify(
        () => gateway.getDashboardMetrics(
          deviceId: captureAny(named: 'deviceId'),
          period: captureAny(named: 'period'),
          startDate: captureAny(named: 'startDate'),
          endDate: captureAny(named: 'endDate'),
        ),
      ).captured;

      expect(captured, hasLength(4));
      expect(captured[0], 'device-42');
      expect(captured[1], 'DAY');
      expect(captured[2], '2024-05-01T00:00:00Z');
      expect(captured[3], '2024-05-02T00:00:00Z');
    });

    test('should leave the period null at the boundary when the query has '
        'none so the gateway can pick the live endpoint', () async {
      // Arrange
      stubMetrics(buildDashboardMetricsResource());

      // Act
      await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-42'),
      );

      // Assert
      final captured = verify(
        () => gateway.getDashboardMetrics(
          deviceId: any(named: 'deviceId'),
          period: captureAny(named: 'period'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).captured;

      expect(captured.single, isNull);
    });

    test('should return a right zeroed aggregate when the device has no '
        'measurements', () async {
      // Arrange
      stubMetrics(
        DashboardMetricsResource.fromJson(emptyDashboardMetricsJson),
      );

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      expect(result.isRight(), isTrue);
      final metrics = result.fold(
        (_) => fail('expected a Right aggregate but got a Left'),
        (value) => value,
      );
      expect(metrics.aqi.value, 0);
      expect(metrics.aqi.category, kFallbackAqiCategory);
      expect(metrics.co2.value, 0);
      expect(metrics.calculatedAt, '');
    });

    test('should translate a 400 response into a left failure carrying the '
        'server message', () async {
      // Arrange
      stubMetricsFailure(
        httpError(400, body: <String, dynamic>{'message': 'Invalid period'}),
      );

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'BOGUS'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'Invalid period');
      expect(failure.statusCode, 400);
    });

    test('should translate a 401 response into a left failure carrying the '
        'server message', () async {
      // Arrange
      stubMetricsFailure(
        httpError(401, body: <String, dynamic>{'message': 'Token expired'}),
      );

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'Token expired');
      expect(failure.statusCode, 401);
    });

    test('should translate a 403 response into a left failure carrying the '
        'server message', () async {
      // Arrange
      stubMetricsFailure(
        httpError(403, body: <String, dynamic>{'message': 'Not your device'}),
      );

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'Not your device');
      expect(failure.statusCode, 403);
    });

    test('should translate a 409 response into a left failure carrying the '
        'server message', () async {
      // Arrange
      stubMetricsFailure(
        httpError(409, body: <String, dynamic>{'message': 'Device in use'}),
      );

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'Device in use');
      expect(failure.statusCode, 409);
    });

    test('should translate a 500 response into a left failure carrying the '
        'server message', () async {
      // Arrange
      stubMetricsFailure(
        httpError(500, body: <String, dynamic>{'message': 'Boom'}),
      );

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'Boom');
      expect(failure.statusCode, 500);
    });

    test('should use the live-data fallback message for a 404 without a '
        'server message', () async {
      // Arrange
      stubMetricsFailure(httpError(404, body: <String, dynamic>{}));

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'Live data is not available right now.');
      expect(failure.statusCode, 404);
    });

    test('should prefer the server message for a 404 response', () async {
      // Arrange
      stubMetricsFailure(
        httpError(
          404,
          body: <String, dynamic>{'message': 'device-1 has no telemetry'},
        ),
      );

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'device-1 has no telemetry');
      expect(failure.statusCode, 404);
    });

    test('should fall back to the transport message when the error carries no '
        'response and no server message', () async {
      // Arrange
      stubMetricsFailure(
        DioException.connectionError(
          requestOptions: RequestOptions(path: '/api/v1/analytics'),
          reason: 'connection refused',
        ),
      );

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, contains('connection refused'));
      expect(failure.statusCode, isNull);
    });

    test('should fall back to a generic message when the transport error '
        'carries no message at all', () async {
      // Arrange
      stubMetricsFailure(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/analytics'),
        ),
      );

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'An unexpected error occurred');
      expect(failure.statusCode, isNull);
    });

    test('should translate a non-Dio gateway crash into a left generic '
        'failure', () async {
      // Arrange
      when(
        () => gateway.getDashboardMetrics(
          deviceId: any(named: 'deviceId'),
          period: any(named: 'period'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => throw StateError('boom'));

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'An unexpected error occurred');
      expect(failure.statusCode, isNull);
    });

    test('should translate an invalid resource into a left generic failure '
        'instead of leaking the mapping exception', () async {
      // Arrange — a blank category cannot become an Aqi value object.
      stubMetrics(buildDashboardMetricsResource(aqiCategory: '  '));

      // Act
      final result = await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'An unexpected error occurred');
      expect(failure.statusCode, isNull);
    });

    test('should never open a telemetry stream while serving a metrics query',
        () async {
      // Arrange
      stubMetrics(buildDashboardMetricsResource());

      // Act
      await service.handleGetDashboardMetrics(
        const GetDashboardMetricsQuery(deviceId: 'device-1', period: 'LIVE'),
      );

      // Assert
      verifyNever(() => gateway.streamLiveTelemetry(any()));
    });
  });

  group('AnalyticsQueryServiceImpl.handleGetTrends', () {
    test('should return a right list with every series point mapped', () async {
      // Arrange
      stubTrends(
        TrendsResource.fromJson(
          trendsJson(dataPoints: <dynamic>[
            trendPointJson(
              timestamp: '2024-05-01T09:00:00Z',
              aqiValue: 10,
              co2: 600,
              pm2_5: 5,
              temperature: 21,
              humidity: 40,
            ),
            trendPointJson(
              timestamp: '2024-05-01T09:05:00Z',
              aqiValue: 20,
              co2: 620,
              pm2_5: 6,
              temperature: 22,
              humidity: 42,
            ),
          ]),
        ),
      );

      // Act
      final result = await service.handleGetTrends(
        const GetTrendsQuery(deviceId: 'device-1', period: 'DAY'),
      );

      // Assert
      expect(result.isRight(), isTrue);
      final points = result.fold(
        (_) => fail('expected a Right list but got a Left'),
        (value) => value,
      );
      expect(points, hasLength(2));
      expect(points.first.timestamp, '2024-05-01T09:00:00Z');
      expect(points.first.aqiValue, 10);
      expect(points.first.co2, 600);
      expect(points.first.pm2_5, 5);
      expect(points.first.temperature, 21);
      expect(points.first.humidity, 40);
      expect(points.last.aqiValue, 20);
    });

    test('should forward the trend period and device filter to the gateway '
        'boundary', () async {
      // Arrange
      stubTrends(buildTrendsResource());

      // Act
      await service.handleGetTrends(
        const GetTrendsQuery(deviceId: 'device-42', period: 'DAY'),
      );

      // Assert
      final captured = verify(
        () => gateway.getTrends(
          deviceId: captureAny(named: 'deviceId'),
          period: captureAny(named: 'period'),
          startDate: captureAny(named: 'startDate'),
          endDate: captureAny(named: 'endDate'),
        ),
      ).captured;

      expect(captured, hasLength(4));
      expect(captured[0], 'device-42');
      expect(captured[1], 'DAY');
      expect(captured[2], isNull);
      expect(captured[3], isNull);
    });

    test('should forward an explicit date range to the gateway boundary', () async {
      // Arrange
      stubTrends(buildTrendsResource());

      // Act
      await service.handleGetTrends(
        const GetTrendsQuery(
          deviceId: 'device-42',
          startDate: '2024-05-01T00:00:00Z',
          endDate: '2024-05-08T00:00:00Z',
        ),
      );

      // Assert
      final captured = verify(
        () => gateway.getTrends(
          deviceId: any(named: 'deviceId'),
          period: captureAny(named: 'period'),
          startDate: captureAny(named: 'startDate'),
          endDate: captureAny(named: 'endDate'),
        ),
      ).captured;

      expect(captured[0], isNull);
      expect(captured[1], '2024-05-01T00:00:00Z');
      expect(captured[2], '2024-05-08T00:00:00Z');
    });

    test('should return a right empty list when the device has no trend data',
        () async {
      // Arrange
      stubTrends(TrendsResource.fromJson(trendsJson(dataPoints: <dynamic>[])));

      // Act
      final result = await service.handleGetTrends(
        const GetTrendsQuery(deviceId: 'device-1', period: 'DAY'),
      );

      // Assert
      expect(result.isRight(), isTrue);
      final points = result.fold(
        (_) => fail('expected a Right list but got a Left'),
        (value) => value,
      );
      expect(points, isEmpty);
    });

    test('should translate a 404 response into the live-data failure', () async {
      // Arrange
      stubTrendsFailure(httpError(404, body: <String, dynamic>{}));

      // Act
      final result = await service.handleGetTrends(
        const GetTrendsQuery(deviceId: 'device-1', period: 'DAY'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'Live data is not available right now.');
      expect(failure.statusCode, 404);
    });

    test('should translate a 503 response into a left failure carrying the '
        'server message', () async {
      // Arrange
      stubTrendsFailure(
        httpError(503, body: <String, dynamic>{'message': 'Service unavailable'}),
      );

      // Act
      final result = await service.handleGetTrends(
        const GetTrendsQuery(deviceId: 'device-1', period: 'DAY'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'Service unavailable');
      expect(failure.statusCode, 503);
    });

    test('should translate a non-Dio gateway crash into a left generic '
        'failure', () async {
      // Arrange
      when(
        () => gateway.getTrends(
          deviceId: any(named: 'deviceId'),
          period: any(named: 'period'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => throw StateError('boom'));

      // Act
      final result = await service.handleGetTrends(
        const GetTrendsQuery(deviceId: 'device-1', period: 'DAY'),
      );

      // Assert
      final failure = failureOf(result);
      expect(failure.message, 'An unexpected error occurred');
      expect(failure.statusCode, isNull);
    });

    test('should never open a telemetry stream while serving a trends query',
        () async {
      // Arrange
      stubTrends(buildTrendsResource());

      // Act
      await service.handleGetTrends(
        const GetTrendsQuery(deviceId: 'device-1', period: 'DAY'),
      );

      // Assert
      verifyNever(() => gateway.streamLiveTelemetry(any()));
    });
  });

  group('AnalyticsQueryServiceImpl.handleStreamLiveTelemetry', () {
    test('should delegate the live stream to the gateway for the given device',
        () async {
      // Arrange
      final telemetry = buildLiveTelemetry();
      when(() => gateway.streamLiveTelemetry(any()))
          .thenAnswer((_) => Stream<LiveTelemetry>.value(telemetry));
      final received = <LiveTelemetry>[];

      // Act
      final stream = service.handleStreamLiveTelemetry('device-1');
      final subscription = stream.listen(received.add);
      await subscription.asFuture<void>();

      // Assert
      final captured = verify(
        () => gateway.streamLiveTelemetry(captureAny()),
      ).captured;
      expect(captured.single, 'device-1');
      expect(received, hasLength(1));
      expect(received.single.deviceId, 'device-1');

      await subscription.cancel();
    });
  });
}