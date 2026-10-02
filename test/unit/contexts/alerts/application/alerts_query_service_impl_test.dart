import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/alerts/application/internal/queryservices/alerts_query_service_impl.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_device.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_space.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_daily_summary.query.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';
import 'package:mobile/alerts/infrastructure/api/gateways/alerts.gateway.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_page.resource.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_response.resource.dart';
import 'package:mobile/alerts/interfaces/rest/resources/daily_alert_summary.resource.dart';

class MockAlertsGateway extends Mock implements AlertsGateway {}

void main() {
  group('AlertsQueryServiceImpl', () {
    late MockAlertsGateway mockGateway;
    late AlertsQueryServiceImpl service;

    setUp(() {
      mockGateway = MockAlertsGateway();
      service = AlertsQueryServiceImpl(mockGateway);
    });

    AlertResponseResource createResource(String id) {
      return AlertResponseResource(
        id: id,
        deviceId: 'dev-1',
        metric: 'PM25',
        metricLabel: 'PM2.5',
        metricUnit: 'µg/m³',
        thresholdValue: 25.0,
        actualValue: 40.0,
        message: 'PM2.5 high',
        status: 'ACTIVE',
        severity: 'CRITICAL',
        occurredAt: '2026-10-02T10:00:00Z',
        createdAt: '2026-10-02T10:00:00Z',
      );
    }

    group('handleGetAlerts', () {
      test('should return Right(AlertPage) when gateway successfully returns AlertPageResource', () async {
        // Arrange
        final pageResource = AlertPageResource(
          content: [createResource('alert-1')],
          totalElements: 1,
          totalPages: 1,
          size: 20,
          number: 0,
        );

        when(
          () => mockGateway.getAlerts(
            page: 0,
            size: 20,
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) async => pageResource);

        // Act
        final result = await service.handleGetAlerts(GetAlertsQuery(page: 0, size: 20));

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected Right, got $failure'),
          (page) {
            expect(page.content.length, equals(1));
            expect(page.content.first.id.value, equals('alert-1'));
            expect(page.content.first.metric, equals(MetricType.pm25));
            expect(page.content.first.status, equals(AlertStatus.active));
            expect(page.content.first.severity, equals(AlertSeverity.critical));
            expect(page.totalElements, equals(1));
          },
        );
      });

      test('should map status enum list to string api values when status filter is provided', () async {
        // Arrange
        final pageResource = AlertPageResource(
          content: [],
          totalElements: 0,
          totalPages: 0,
          size: 10,
          number: 1,
        );

        when(
          () => mockGateway.getAlerts(
            page: 1,
            size: 10,
            status: ['ACTIVE', 'ACKNOWLEDGED'],
          ),
        ).thenAnswer((_) async => pageResource);

        // Act
        final result = await service.handleGetAlerts(
          GetAlertsQuery(page: 1, size: 10),
          status: [AlertStatus.active, AlertStatus.acknowledged],
        );

        // Assert
        expect(result.isRight(), isTrue);
        verify(
          () => mockGateway.getAlerts(
            page: 1,
            size: 10,
            status: ['ACTIVE', 'ACKNOWLEDGED'],
          ),
        ).called(1);
      });

      test('should return Left(Failure) with server message and statusCode when gateway throws DioException with response data', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/alerts'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/alerts'),
            statusCode: 400,
            data: {'message': 'Bad request filter parameters'},
          ),
        );

        when(
          () => mockGateway.getAlerts(
            page: any(named: 'page'),
            size: any(named: 'size'),
            status: any(named: 'status'),
          ),
        ).thenThrow(dioException);

        // Act
        final result = await service.handleGetAlerts(GetAlertsQuery());

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure.message, equals('Bad request filter parameters'));
            expect(failure.statusCode, equals(400));
          },
          (_) => fail('Expected Left'),
        );
      });

      test('should fallback to error.message when response data does not have message', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/alerts'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/alerts'),
            statusCode: 502,
          ),
          message: 'Bad gateway connection',
        );

        when(
          () => mockGateway.getAlerts(
            page: any(named: 'page'),
            size: any(named: 'size'),
            status: any(named: 'status'),
          ),
        ).thenThrow(dioException);

        // Act
        final result = await service.handleGetAlerts(GetAlertsQuery());

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure.message, equals('Bad gateway connection'));
            expect(failure.statusCode, equals(502));
          },
          (_) => fail('Expected Left'),
        );
      });

      test('should return Left(Failure) with generic message when unexpected non-Dio exception is thrown', () async {
        // Arrange
        when(
          () => mockGateway.getAlerts(
            page: any(named: 'page'),
            size: any(named: 'size'),
            status: any(named: 'status'),
          ),
        ).thenThrow(Exception('Unexpected crash'));

        // Act
        final result = await service.handleGetAlerts(GetAlertsQuery());

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure.message, equals('An unexpected error occurred'));
            expect(failure.statusCode, isNull);
          },
          (_) => fail('Expected Left'),
        );
      });
    });

    group('handleGetAlertsByDevice', () {
      test('should return Right(AlertPage) when gateway successfully returns data for device', () async {
        // Arrange
        final pageResource = AlertPageResource(
          content: [createResource('alert-dev-1')],
          totalElements: 1,
          totalPages: 1,
          size: 20,
          number: 0,
        );

        when(
          () => mockGateway.getAlertsByDevice(
            deviceId: 'dev-1',
            page: 0,
            size: 20,
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) async => pageResource);

        // Act
        final result = await service.handleGetAlertsByDevice(
          GetAlertsByDeviceQuery(deviceId: 'dev-1'),
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected Right'),
          (page) {
            expect(page.content.first.id.value, equals('alert-dev-1'));
          },
        );
      });

      test('should return Left(Failure) when gateway throws DioException on device alerts', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/devices/dev-404/alerts'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/devices/dev-404/alerts'),
            statusCode: 404,
            data: {'message': 'Device not found'},
          ),
        );

        when(
          () => mockGateway.getAlertsByDevice(
            deviceId: 'dev-404',
            page: any(named: 'page'),
            size: any(named: 'size'),
            status: any(named: 'status'),
          ),
        ).thenThrow(dioException);

        // Act
        final result = await service.handleGetAlertsByDevice(
          GetAlertsByDeviceQuery(deviceId: 'dev-404'),
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure.message, equals('Device not found'));
            expect(failure.statusCode, equals(404));
          },
          (_) => fail('Expected Left'),
        );
      });

      test('should return Left(Failure) when unexpected exception occurs on getAlertsByDevice', () async {
        // Arrange
        when(
          () => mockGateway.getAlertsByDevice(
            deviceId: any(named: 'deviceId'),
            page: any(named: 'page'),
            size: any(named: 'size'),
            status: any(named: 'status'),
          ),
        ).thenThrow(StateError('Corrupt state'));

        // Act
        final result = await service.handleGetAlertsByDevice(
          GetAlertsByDeviceQuery(deviceId: 'dev-1'),
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('handleGetAlertsBySpace', () {
      test('should return Right(AlertPage) when gateway successfully returns space alerts', () async {
        // Arrange
        final pageResource = AlertPageResource(
          content: [createResource('alert-sp-1')],
          totalElements: 1,
          totalPages: 1,
          size: 20,
          number: 0,
        );

        when(
          () => mockGateway.getAlertsBySpace(
            spaceId: 'sp-1',
            page: 0,
            size: 20,
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) async => pageResource);

        // Act
        final result = await service.handleGetAlertsBySpace(
          GetAlertsBySpaceQuery(spaceId: 'sp-1'),
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected Right'),
          (page) {
            expect(page.content.first.id.value, equals('alert-sp-1'));
          },
        );
      });

      test('should return Left(Failure) when gateway throws DioException on space alerts', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/spaces/sp-forbidden/alerts'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/spaces/sp-forbidden/alerts'),
            statusCode: 403,
            data: {'message': 'Unauthorized space access'},
          ),
        );

        when(
          () => mockGateway.getAlertsBySpace(
            spaceId: 'sp-forbidden',
            page: any(named: 'page'),
            size: any(named: 'size'),
            status: any(named: 'status'),
          ),
        ).thenThrow(dioException);

        // Act
        final result = await service.handleGetAlertsBySpace(
          GetAlertsBySpaceQuery(spaceId: 'sp-forbidden'),
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure.message, equals('Unauthorized space access'));
            expect(failure.statusCode, equals(403));
          },
          (_) => fail('Expected Left'),
        );
      });

      test('should return Left(Failure) when unexpected exception occurs on getAlertsBySpace', () async {
        // Arrange
        when(
          () => mockGateway.getAlertsBySpace(
            spaceId: any(named: 'spaceId'),
            page: any(named: 'page'),
            size: any(named: 'size'),
            status: any(named: 'status'),
          ),
        ).thenThrow(Exception('Network glitch'));

        // Act
        final result = await service.handleGetAlertsBySpace(
          GetAlertsBySpaceQuery(spaceId: 'sp-1'),
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('handleGetDailySummary', () {
      test('should return Right(List<DailyAlertCount>) when gateway returns summary resources', () async {
        // Arrange
        final summaries = [
          const DailyAlertSummaryResource(date: '2026-10-01', count: 3),
          const DailyAlertSummaryResource(date: '2026-10-02', count: 8),
        ];

        when(() => mockGateway.getCurrentUserDailyAlertSummary(days: 30))
            .thenAnswer((_) async => summaries);

        // Act
        final result = await service.handleGetDailySummary(GetAlertDailySummaryQuery(days: 30));

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected Right'),
          (list) {
            expect(list.length, equals(2));
            expect(list[0].date, equals('2026-10-01'));
            expect(list[0].count, equals(3));
            expect(list[1].date, equals('2026-10-02'));
            expect(list[1].count, equals(8));
          },
        );
      });

      test('should return Left(Failure) on DioException when fetching daily summary', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/alerts/daily-summary'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/alerts/daily-summary'),
            statusCode: 500,
            data: {'message': 'Summary service down'},
          ),
        );

        when(() => mockGateway.getCurrentUserDailyAlertSummary(days: any(named: 'days')))
            .thenThrow(dioException);

        // Act
        final result = await service.handleGetDailySummary(GetAlertDailySummaryQuery());

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure.message, equals('Summary service down'));
            expect(failure.statusCode, equals(500));
          },
          (_) => fail('Expected Left'),
        );
      });

      test('should return Left(Failure) when unexpected exception occurs on getDailySummary', () async {
        // Arrange
        when(() => mockGateway.getCurrentUserDailyAlertSummary(days: any(named: 'days')))
            .thenThrow(Exception('Crash'));

        // Act
        final result = await service.handleGetDailySummary(GetAlertDailySummaryQuery());

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('handleGetDailySummaryBySpace', () {
      test('should return Right(List<DailyAlertCount>) when gateway returns space summaries', () async {
        // Arrange
        final summaries = [
          const DailyAlertSummaryResource(date: '2026-10-02', count: 5),
        ];

        when(() => mockGateway.getDailyAlertSummary(spaceId: 'sp-1', days: 7))
            .thenAnswer((_) async => summaries);

        // Act
        final result = await service.handleGetDailySummaryBySpace('sp-1', 7);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected Right'),
          (list) {
            expect(list.length, equals(1));
            expect(list.first.date, equals('2026-10-02'));
            expect(list.first.count, equals(5));
          },
        );
      });

      test('should return Left(Failure) on DioException when fetching space daily summary', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/spaces/sp-1/alerts/daily-summary'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/spaces/sp-1/alerts/daily-summary'),
            statusCode: 404,
            data: {'message': 'Space not found'},
          ),
        );

        when(() => mockGateway.getDailyAlertSummary(
          spaceId: any(named: 'spaceId'),
          days: any(named: 'days'),
        )).thenThrow(dioException);

        // Act
        final result = await service.handleGetDailySummaryBySpace('sp-1', 7);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure.message, equals('Space not found'));
            expect(failure.statusCode, equals(404));
          },
          (_) => fail('Expected Left'),
        );
      });

      test('should return Left(Failure) on unexpected exception for space daily summary', () async {
        // Arrange
        when(() => mockGateway.getDailyAlertSummary(
          spaceId: any(named: 'spaceId'),
          days: any(named: 'days'),
        )).thenThrow(Exception('Unknown'));

        // Act
        final result = await service.handleGetDailySummaryBySpace('sp-1', 7);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });
  });
}
