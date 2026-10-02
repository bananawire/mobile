import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/analytics/application/internal/queryservices/analytics_query_service_impl.dart';
import 'package:mobile/analytics/domain/model/queries/get_dashboard_metrics.query.dart';
import 'package:mobile/analytics/domain/model/queries/get_trends.query.dart';
import 'package:mobile/analytics/domain/model/valueobjects/dashboard_metrics.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/live_telemetry.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';
import 'package:mobile/analytics/infrastructure/api/gateways/analytics.gateway.dart';
import 'package:mobile/analytics/interfaces/rest/resources/dashboard_metrics.resource.dart';
import 'package:mobile/analytics/interfaces/rest/resources/trends.resource.dart';

class MockAnalyticsGateway extends Mock implements AnalyticsGateway {}

void main() {
  late MockAnalyticsGateway mockGateway;
  late AnalyticsQueryServiceImpl service;

  final sampleMetricsResource = DashboardMetricsResource(
    aqiValue: 42.0,
    aqiCategory: 'Good',
    averageCo2: 500.0,
    averagePm2_5: 10.0,
    averageTemperature: 22.0,
    averageHumidity: 50.0,
    co2DeltaPercentage: 1.5,
    pm2_5DeltaPercentage: -0.8,
    temperatureDeltaPercentage: 0.2,
    humidityDeltaPercentage: -1.0,
    calculatedAt: '2026-10-02T12:00:00Z',
  );

  final sampleTrendsResource = TrendsResource(
    dataPoints: [
      TrendDataPointResource(
        timestamp: '2026-10-02T10:00:00Z',
        aqiValue: 40.0,
        co2: 480.0,
        pm2_5: 9.0,
        temperature: 21.0,
        humidity: 48.0,
      ),
      TrendDataPointResource(
        timestamp: '2026-10-02T11:00:00Z',
        aqiValue: 45.0,
        co2: 500.0,
        pm2_5: 10.5,
        temperature: 22.0,
        humidity: 50.0,
      ),
    ],
  );

  setUp(() {
    mockGateway = MockAnalyticsGateway();
    service = AnalyticsQueryServiceImpl(mockGateway);
  });

  group('handleGetDashboardMetrics', () {
    test(
      'should return Right with DashboardMetrics when gateway succeeds',
      () async {
        // Arrange
        const query = GetDashboardMetricsQuery(deviceId: 'dev-1');
        when(
          () => mockGateway.getDashboardMetrics(
            deviceId: 'dev-1',
            period: any(named: 'period'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => sampleMetricsResource);

        // Act
        final result = await service.handleGetDashboardMetrics(query);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Expected Right, got Left: $failure'), (
          metrics,
        ) {
          expect(metrics, isA<DashboardMetrics>());
          expect(metrics.aqi.value, equals(42.0));
          expect(metrics.aqi.category, equals('Good'));
          expect(metrics.co2.value, equals(500.0));
        });
        verify(
          () => mockGateway.getDashboardMetrics(
            deviceId: 'dev-1',
            period: null,
            startDate: null,
            endDate: null,
          ),
        ).called(1);
      },
    );

    test(
      'should return Left with 404 Failure and default message when 404 has no server message',
      () async {
        // Arrange
        const query = GetDashboardMetricsQuery(deviceId: 'dev-1');
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 404,
          ),
        );
        when(
          () => mockGateway.getDashboardMetrics(
            deviceId: any(named: 'deviceId'),
            period: any(named: 'period'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenThrow(dioException);

        // Act
        final result = await service.handleGetDashboardMetrics(query);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure.statusCode, equals(404));
          expect(
            failure.message,
            equals('Live data is not available right now.'),
          );
        }, (_) => fail('Expected Left, got Right'));
      },
    );

    test(
      'should return Left with server message when DioException contains error message',
      () async {
        // Arrange
        const query = GetDashboardMetricsQuery(deviceId: 'dev-1');
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 404,
            data: {'message': 'Device telemetry offline'},
          ),
        );
        when(
          () => mockGateway.getDashboardMetrics(
            deviceId: any(named: 'deviceId'),
            period: any(named: 'period'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenThrow(dioException);

        // Act
        final result = await service.handleGetDashboardMetrics(query);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure.statusCode, equals(404));
          expect(failure.message, equals('Device telemetry offline'));
        }, (_) => fail('Expected Left, got Right'));
      },
    );

    test(
      'should return Left with generic Failure when unexpected exception is thrown',
      () async {
        // Arrange
        const query = GetDashboardMetricsQuery(deviceId: 'dev-1');
        when(
          () => mockGateway.getDashboardMetrics(
            deviceId: any(named: 'deviceId'),
            period: any(named: 'period'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenThrow(Exception('Network socket crash'));

        // Act
        final result = await service.handleGetDashboardMetrics(query);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure.message, equals('An unexpected error occurred'));
        }, (_) => fail('Expected Left, got Right'));
      },
    );
  });

  group('handleGetTrends', () {
    test(
      'should return Right with List<TrendPoint> when gateway succeeds',
      () async {
        // Arrange
        const query = GetTrendsQuery(deviceId: 'dev-1', period: 'DAY');
        when(
          () => mockGateway.getTrends(
            deviceId: 'dev-1',
            period: 'DAY',
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => sampleTrendsResource);

        // Act
        final result = await service.handleGetTrends(query);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Expected Right, got Left: $failure'), (
          points,
        ) {
          expect(points.length, equals(2));
          expect(points.first, isA<TrendPoint>());
          expect(points.first.timestamp, equals('2026-10-02T10:00:00Z'));
          expect(points.last.aqiValue, equals(45.0));
        });
      },
    );

    test(
      'should return Left with Failure when gateway throws DioException with 500',
      () async {
        // Arrange
        const query = GetTrendsQuery(deviceId: 'dev-1');
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
            data: {'message': 'Database query failed'},
          ),
        );
        when(
          () => mockGateway.getTrends(
            deviceId: any(named: 'deviceId'),
            period: any(named: 'period'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenThrow(dioException);

        // Act
        final result = await service.handleGetTrends(query);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure.statusCode, equals(500));
          expect(failure.message, equals('Database query failed'));
        }, (_) => fail('Expected Left, got Right'));
      },
    );

    test(
      'should return Left with generic Failure when unexpected exception is thrown',
      () async {
        // Arrange
        const query = GetTrendsQuery(deviceId: 'dev-1');
        when(
          () => mockGateway.getTrends(
            deviceId: any(named: 'deviceId'),
            period: any(named: 'period'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenThrow(Exception('Unknown system fault'));

        // Act
        final result = await service.handleGetTrends(query);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) =>
              expect(failure.message, equals('An unexpected error occurred')),
          (_) => fail('Expected Left, got Right'),
        );
      },
    );
  });

  group('handleStreamLiveTelemetry', () {
    test('should forward live telemetry stream from gateway', () async {
      // Arrange
      final telemetryStream = Stream.fromIterable([
        const LiveTelemetry(
          deviceId: 'dev-1',
          co2: 500.0,
          pm2_5: 12.0,
          temperature: 23.0,
          humidity: 45.0,
          timestamp: '2026-10-02T12:00:00Z',
        ),
      ]);
      when(
        () => mockGateway.streamLiveTelemetry('dev-1'),
      ).thenAnswer((_) => telemetryStream);

      // Act
      final stream = service.handleStreamLiveTelemetry('dev-1');

      // Assert
      final events = await stream.toList();
      expect(events.length, equals(1));
      expect(events.first.deviceId, equals('dev-1'));
      expect(events.first.co2, equals(500.0));
      verify(() => mockGateway.streamLiveTelemetry('dev-1')).called(1);
    });
  });
}
