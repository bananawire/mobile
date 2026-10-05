import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/alerts/application/internal/queryservices/alerts_query_service_impl.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_device.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_space.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_daily_summary.query.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/services/alerts.command-service.dart';
import 'package:mobile/alerts/infrastructure/api/gateways/alerts.gateway.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_page.resource.dart';
import 'package:mobile/core/failure.dart';
import 'package:mocktail/mocktail.dart';

import '../alerts_fixtures.dart';

class MockAlertsGateway extends Mock implements AlertsGateway {}

void main() {
  late MockAlertsGateway gateway;
  late AlertsQueryServiceImpl service;

  /// Builds a `DioException` that carries an HTTP [statusCode] plus a JSON body
  /// so that `_mapError` can be exercised through its real branches.
  DioException httpError(
    int statusCode, {
    Object? body,
    String? messageOverride,
  }) {
    final requestOptions = RequestOptions(path: '/api/v1/alerts');
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

  void stubAlerts(AlertPageResource resource) {
    when(
      () => gateway.getAlerts(
        page: any(named: 'page'),
        size: any(named: 'size'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => resource);
  }

  setUpAll(() {
    registerFallbackValue(GetAlertsQuery());
  });

  setUp(() {
    gateway = MockAlertsGateway();
    service = AlertsQueryServiceImpl(gateway);
  });

  group('AlertsQueryServiceImpl.handleGetAlerts', () {
    test('should return a right page with the mapped alerts when the gateway '
        'succeeds', () async {
      // Arrange
      stubAlerts(
        buildAlertPageResource(
          content: [
            buildAlertResource(),
            buildAlertResource(
              id: 'alert-2',
              status: 'RESOLVED',
              severity: 'WARNING',
              resolvedAt: '2024-05-02T09:15:00Z',
            ),
          ],
          totalElements: 41,
          totalPages: 3,
          size: 20,
          number: 1,
        ),
      );

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      expect(result.isRight(), isTrue);
      final page = result.getOrElse((_) => fail('expected a Right page but got a Left'));
      expect(page.content, hasLength(2));
      expect(page.content.first.id.value, 'alert-1');
      expect(page.content.first.status, AlertStatus.active);
      expect(page.content.first.severity, AlertSeverity.critical);
      expect(page.content.last.status, AlertStatus.resolved);
      expect(page.content.last.resolvedAt, '2024-05-02T09:15:00Z');
      expect(page.totalElements, 41);
      expect(page.totalPages, 3);
      expect(page.size, 20);
      expect(page.number, 1);
    });

    test('should forward the query pagination to the gateway boundary',
        () async {
      // Arrange
      stubAlerts(buildAlertPageResource());

      // Act
      await service.handleGetAlerts(GetAlertsQuery(page: 2, size: 50));

      // Assert
      final captured = verify(
        () => gateway.getAlerts(
          page: captureAny(named: 'page'),
          size: captureAny(named: 'size'),
          status: any(named: 'status'),
        ),
      ).captured;
      expect(captured, hasLength(2));
      expect(captured[0], 2);
      expect(captured[1], 50);
    });

    test('should forward the requested statuses as upper case wire codes',
        () async {
      // Arrange
      stubAlerts(buildAlertPageResource());

      // Act
      await service.handleGetAlerts(
        GetAlertsQuery(),
        status: const [AlertStatus.active, AlertStatus.acknowledged],
      );

      // Assert
      final captured = verify(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: captureAny(named: 'status'),
        ),
      ).captured;
      expect(captured.single, ['ACTIVE', 'ACKNOWLEDGED']);
    });

    test('should forward a null status filter as null', () async {
      // Arrange
      stubAlerts(buildAlertPageResource());

      // Act
      await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      final captured = verify(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: captureAny(named: 'status'),
        ),
      ).captured;
      expect(captured.single, isNull);
    });

    test('should forward an empty status filter as null because no status is '
        'sent to the backend', () async {
      // Arrange
      stubAlerts(buildAlertPageResource());

      // Act
      await service.handleGetAlerts(GetAlertsQuery(), status: const []);

      // Assert
      final captured = verify(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: captureAny(named: 'status'),
        ),
      ).captured;
      expect(captured.single, isNull);
    });

    test('should return an empty page instead of an error when the gateway has '
        'no alerts', () async {
      // Arrange
      stubAlerts(buildAlertPageResource());

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      expect(result.isRight(), isTrue);
      final page = result.getOrElse((_) => fail('expected a Right page but got a Left'));
      expect(page.content, isEmpty);
      expect(page.totalElements, 0);
    });

    test('should never call the device or space gateway variants', () async {
      // Arrange
      stubAlerts(buildAlertPageResource());

      // Act
      await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      verifyNever(
        () => gateway.getAlertsByDevice(
          deviceId: any(named: 'deviceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      );
      verifyNever(
        () => gateway.getAlertsBySpace(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      );
    });

    test('should translate a bad request failure when the backend answers 400',
        () async {
      // Arrange
      when(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenThrow(httpError(400, body: <String, dynamic>{
        'message': 'size must be between 1 and 100',
      }));

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.message, 'size must be between 1 and 100');
      expect(failure.statusCode, 400);
    });

    test('should translate an unauthorized failure when the backend answers '
        '401', () async {
      // Arrange
      when(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenThrow(httpError(401, body: <String, dynamic>{
        'message': 'Unauthorized',
      }));

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.message, 'Unauthorized');
      expect(failure.statusCode, 401);
    });

    test('should translate a forbidden failure when the backend answers 403',
        () async {
      // Arrange
      when(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenThrow(httpError(403, body: <String, dynamic>{
        'message': 'You cannot read alerts of this space',
      }));

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.message, 'You cannot read alerts of this space');
      expect(failure.statusCode, 403);
    });

    test('should translate a not found failure when the backend answers 404',
        () async {
      // Arrange
      when(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenThrow(httpError(404, body: <String, dynamic>{
        'message': 'Alerts endpoint not found',
      }));

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.message, 'Alerts endpoint not found');
      expect(failure.statusCode, 404);
    });

    test('should translate a conflict failure when the backend answers 409',
        () async {
      // Arrange
      when(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenThrow(httpError(409, body: <String, dynamic>{
        'message': 'Alert was already acknowledged',
      }));

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.message, 'Alert was already acknowledged');
      expect(failure.statusCode, 409);
    });

    test('should translate a server error failure when the backend answers '
        '500', () async {
      // Arrange
      when(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenThrow(httpError(500, body: <String, dynamic>{
        'message': 'Internal server error',
      }));

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.message, 'Internal server error');
      expect(failure.statusCode, 500);
    });

    test('should translate a service unavailable failure when the backend '
        'answers 503', () async {
      // Arrange
      when(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenThrow(httpError(503, body: <String, dynamic>{
        'message': 'Alerts service is down',
      }));

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.message, 'Alerts service is down');
      expect(failure.statusCode, 503);
    });

    test('should fall back to the dio message when the error body carries no '
        'message field', () async {
      // Arrange
      when(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenThrow(
        httpError(
          400,
          body: <String, dynamic>{'detail': 'nothing useful here'},
        ),
      );

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(
        failure.message,
        contains('the response has a status code of 400'),
        reason: 'The dio message is surfaced when the body has no message field',
      );
      expect(failure.statusCode, 400);
    });

    test('should keep a null status code when the transport fails without a '
        'response', () async {
      // Arrange
      when(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenThrow(
        DioException.connectionTimeout(
          timeout: const Duration(seconds: 5),
          requestOptions: RequestOptions(path: '/api/v1/alerts'),
        ),
      );

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.statusCode, isNull);
      expect(failure.message, contains('connection took longer'));
    });

    test('should translate an unexpected error when the gateway throws a non '
        'dio exception', () async {
      // Arrange
      when(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenThrow(StateError('boom'));

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.message, 'An unexpected error occurred');
      expect(failure.statusCode, isNull);
    });

    test('should translate an unexpected error when the payload cannot be '
        'mapped to the domain', () async {
      // Arrange
      stubAlerts(
        buildAlertPageResource(content: [buildAlertResource(id: '   ')]),
      );

      // Act
      final result = await service.handleGetAlerts(GetAlertsQuery());

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(
        failure.message,
        'An unexpected error occurred',
        reason: 'A blank alert id is rejected by the AlertId value object '
            'inside the try block',
      );
    });
  });

  group('AlertsQueryServiceImpl.handleGetAlertsByDevice', () {
    test('should return a right page with the mapped alerts when the gateway '
        'succeeds', () async {
      // Arrange
      when(
        () => gateway.getAlertsByDevice(
          deviceId: any(named: 'deviceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenAnswer(
        (_) async => buildAlertPageResource(
          content: [buildAlertResource(deviceId: 'device-7')],
        ),
      );

      // Act
      final result = await service.handleGetAlertsByDevice(
        GetAlertsByDeviceQuery(deviceId: 'device-7'),
      );

      // Assert
      final page = result.getOrElse((_) => fail('expected a Right page but got a Left'));
      expect(page.content.single.deviceId, 'device-7');
    });

    test('should forward the device identifier, pagination and status filter to '
        'the gateway boundary', () async {
      // Arrange
      when(
        () => gateway.getAlertsByDevice(
          deviceId: any(named: 'deviceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => buildAlertPageResource());

      // Act
      await service.handleGetAlertsByDevice(
        GetAlertsByDeviceQuery(deviceId: 'device-7', page: 1, size: 10),
        status: const [AlertStatus.resolved],
      );

      // Assert
      final captured = verify(
        () => gateway.getAlertsByDevice(
          deviceId: captureAny(named: 'deviceId'),
          page: captureAny(named: 'page'),
          size: captureAny(named: 'size'),
          status: captureAny(named: 'status'),
        ),
      ).captured;
      expect(captured[0], 'device-7');
      expect(captured[1], 1);
      expect(captured[2], 10);
      expect(captured[3], ['RESOLVED']);
    });

    test('should translate a not found failure when the device does not exist',
        () async {
      // Arrange
      when(
        () => gateway.getAlertsByDevice(
          deviceId: any(named: 'deviceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenThrow(httpError(404, body: <String, dynamic>{
        'message': 'Device not found',
      }));

      // Act
      final result = await service.handleGetAlertsByDevice(
        GetAlertsByDeviceQuery(deviceId: 'ghost'),
      );

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.message, 'Device not found');
      expect(failure.statusCode, 404);
    });

    test('should never call the global and space gateway variants', () async {
      // Arrange
      when(
        () => gateway.getAlertsByDevice(
          deviceId: any(named: 'deviceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => buildAlertPageResource());

      // Act
      await service.handleGetAlertsByDevice(
        GetAlertsByDeviceQuery(deviceId: 'device-7'),
      );

      // Assert
      verifyNever(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      );
      verifyNever(
        () => gateway.getAlertsBySpace(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      );
    });
  });

  group('AlertsQueryServiceImpl.handleGetAlertsBySpace', () {
    test('should return a right page with the mapped alerts when the gateway '
        'succeeds', () async {
      // Arrange
      when(
        () => gateway.getAlertsBySpace(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenAnswer(
        (_) async => buildAlertPageResource(
          content: [buildAlertResource(spaceId: 'space-3')],
          totalElements: 1,
        ),
      );

      // Act
      final result = await service.handleGetAlertsBySpace(
        GetAlertsBySpaceQuery(spaceId: 'space-3'),
      );

      // Assert
      final page = result.getOrElse((_) => fail('expected a Right page but got a Left'));
      expect(page.content.single.spaceId, 'space-3');
      expect(page.totalElements, 1);
    });

    test('should forward the space identifier, pagination and status filter to '
        'the gateway boundary', () async {
      // Arrange
      when(
        () => gateway.getAlertsBySpace(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => buildAlertPageResource());

      // Act
      await service.handleGetAlertsBySpace(
        GetAlertsBySpaceQuery(spaceId: 'space-3', page: 2, size: 5),
        status: const [AlertStatus.active, AlertStatus.resolved],
      );

      // Assert
      final captured = verify(
        () => gateway.getAlertsBySpace(
          spaceId: captureAny(named: 'spaceId'),
          page: captureAny(named: 'page'),
          size: captureAny(named: 'size'),
          status: captureAny(named: 'status'),
        ),
      ).captured;
      expect(captured[0], 'space-3');
      expect(captured[1], 2);
      expect(captured[2], 5);
      expect(captured[3], ['ACTIVE', 'RESOLVED']);
    });

    test('should translate a forbidden failure when the space is not visible',
        () async {
      // Arrange
      when(
        () => gateway.getAlertsBySpace(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenThrow(httpError(403, body: <String, dynamic>{
        'message': 'Space access denied',
      }));

      // Act
      final result = await service.handleGetAlertsBySpace(
        GetAlertsBySpaceQuery(spaceId: 'space-3'),
      );

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.message, 'Space access denied');
      expect(failure.statusCode, 403);
    });

    test('should never call the global and device gateway variants', () async {
      // Arrange
      when(
        () => gateway.getAlertsBySpace(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => buildAlertPageResource());

      // Act
      await service.handleGetAlertsBySpace(
        GetAlertsBySpaceQuery(spaceId: 'space-3'),
      );

      // Assert
      verifyNever(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      );
      verifyNever(
        () => gateway.getAlertsByDevice(
          deviceId: any(named: 'deviceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      );
    });
  });

  group('AlertsQueryServiceImpl.handleGetDailySummary', () {
    test('should return a right list of day buckets when the gateway succeeds',
        () async {
      // Arrange
      when(
        () => gateway.getCurrentUserDailyAlertSummary(days: any(named: 'days')),
      ).thenAnswer(
        (_) async => [
          buildDailySummaryResource(date: '2024-05-01', count: 4),
          buildDailySummaryResource(date: '2024-05-02', count: 0),
        ],
      );

      // Act
      final result = await service.handleGetDailySummary(
        GetAlertDailySummaryQuery(days: 30),
      );

      // Assert
      final summary = result.getOrElse((_) => fail('expected a Right summary but got a Left'));
      expect(summary, hasLength(2));
      expect(summary.first.date, '2024-05-01');
      expect(summary.first.count, 4);
      expect(summary.last.count, 0);
    });

    test('should forward the requested day window to the gateway boundary',
        () async {
      // Arrange
      when(
        () => gateway.getCurrentUserDailyAlertSummary(days: any(named: 'days')),
      ).thenAnswer((_) async => const []);

      // Act
      await service.handleGetDailySummary(
        GetAlertDailySummaryQuery(days: 90),
      );

      // Assert
      final captured = verify(
        () => gateway.getCurrentUserDailyAlertSummary(
          days: captureAny(named: 'days'),
        ),
      ).captured;
      expect(captured.single, 90);
    });

    test('should truncate a fractional bucket count to an integer', () async {
      // Arrange
      when(
        () => gateway.getCurrentUserDailyAlertSummary(days: any(named: 'days')),
      ).thenAnswer(
        (_) async => [buildDailySummaryResource(count: 3.7)],
      );

      // Act
      final result = await service.handleGetDailySummary(
        GetAlertDailySummaryQuery(),
      );

      // Assert
      final summary = result.getOrElse((_) => fail('expected a Right summary but got a Left'));
      expect(summary.single.count, 3);
    });

    test('should return an empty list instead of an error when there is no '
        'history yet', () async {
      // Arrange
      when(
        () => gateway.getCurrentUserDailyAlertSummary(days: any(named: 'days')),
      ).thenAnswer((_) async => const []);

      // Act
      final result = await service.handleGetDailySummary(
        GetAlertDailySummaryQuery(),
      );

      // Assert
      expect(result.isRight(), isTrue);
      expect(result.getOrElse((_) => fail('expected a Right summary but got a Left')), isEmpty);
    });

    test('should translate a server error failure when the backend answers 500',
        () async {
      // Arrange
      when(
        () => gateway.getCurrentUserDailyAlertSummary(days: any(named: 'days')),
      ).thenThrow(httpError(500, body: <String, dynamic>{
        'message': 'Summary unavailable',
      }));

      // Act
      final result = await service.handleGetDailySummary(
        GetAlertDailySummaryQuery(),
      );

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.message, 'Summary unavailable');
      expect(failure.statusCode, 500);
    });

    test('should never call any alert page gateway variant', () async {
      // Arrange
      when(
        () => gateway.getCurrentUserDailyAlertSummary(days: any(named: 'days')),
      ).thenAnswer((_) async => const []);

      // Act
      await service.handleGetDailySummary(GetAlertDailySummaryQuery());

      // Assert
      verifyNever(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      );
      verifyNever(
        () => gateway.getAlertsBySpace(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      );
    });
  });

  group('AlertsQueryServiceImpl.handleGetDailySummaryBySpace', () {
    test('should return a right list of day buckets when the gateway succeeds',
        () async {
      // Arrange
      when(
        () => gateway.getDailyAlertSummary(
          spaceId: any(named: 'spaceId'),
          days: any(named: 'days'),
        ),
      ).thenAnswer(
        (_) async => [buildDailySummaryResource(date: '2024-05-03', count: 2)],
      );

      // Act
      final result = await service.handleGetDailySummaryBySpace('space-3', 7);

      // Assert
      final summary = result.getOrElse((_) => fail('expected a Right summary but got a Left'));
      expect(summary.single.date, '2024-05-03');
      expect(summary.single.count, 2);
    });

    test('should forward the space identifier and the day window to the gateway '
        'boundary', () async {
      // Arrange
      when(
        () => gateway.getDailyAlertSummary(
          spaceId: any(named: 'spaceId'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => const []);

      // Act
      await service.handleGetDailySummaryBySpace('space-9', 14);

      // Assert
      final captured = verify(
        () => gateway.getDailyAlertSummary(
          spaceId: captureAny(named: 'spaceId'),
          days: captureAny(named: 'days'),
        ),
      ).captured;
      expect(captured[0], 'space-9');
      expect(captured[1], 14);
    });

    test('should translate a not found failure when the space does not exist',
        () async {
      // Arrange
      when(
        () => gateway.getDailyAlertSummary(
          spaceId: any(named: 'spaceId'),
          days: any(named: 'days'),
        ),
      ).thenThrow(httpError(404, body: <String, dynamic>{
        'message': 'Space not found',
      }));

      // Act
      final result = await service.handleGetDailySummaryBySpace('ghost', 30);

      // Assert
      final failure = result.getLeft().getOrElse(
        () => const Failure('expected a failure'),
      );
      expect(failure.message, 'Space not found');
      expect(failure.statusCode, 404);
    });

    test('should never call the current user summary gateway variant',
        () async {
      // Arrange
      when(
        () => gateway.getDailyAlertSummary(
          spaceId: any(named: 'spaceId'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => const []);

      // Act
      await service.handleGetDailySummaryBySpace('space-3', 30);

      // Assert
      verifyNever(
        () => gateway.getCurrentUserDailyAlertSummary(days: any(named: 'days')),
      );
    });
  });

  group('AlertsQueryServiceImpl invalid input', () {
    test('should reject a negative page at query construction before the gateway '
        'is reached', () async {
      // Arrange / Act
      GetAlertsQuery query() => GetAlertsQuery(page: -1);

      // Assert
      expect(query, throwsArgumentError);
      verifyNever(
        () => gateway.getAlerts(
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      );
    });

    test('should reject a blank space identifier at query construction before '
        'the gateway is reached', () async {
      // Arrange / Act
      GetAlertsBySpaceQuery query() => GetAlertsBySpaceQuery(spaceId: '  ');

      // Assert
      expect(query, throwsArgumentError);
      verifyNever(
        () => gateway.getAlertsBySpace(
          spaceId: any(named: 'spaceId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          status: any(named: 'status'),
        ),
      );
    });

    test('should reject a day window out of range at query construction before '
        'the gateway is reached', () async {
      // Arrange / Act
      GetAlertDailySummaryQuery query() => GetAlertDailySummaryQuery(days: 400);

      // Assert
      expect(query, throwsArgumentError);
      verifyNever(
        () => gateway.getCurrentUserDailyAlertSummary(days: any(named: 'days')),
      );
    });

    test('should not implement the command service so no acknowledge or '
        'refresh mutation is reachable from this class', () {
      // Arrange / Act
      final isCommandService = service is AlertsCommandService;

      // Assert
      expect(
        isCommandService,
        isFalse,
        reason: 'AlertsQueryServiceImpl only implements the query contract, so '
            'handleAcknowledgeAlert and handleRefreshAlerts are not exposed',
      );
    });
  });
}

/// Placeholder type used only to keep the empty list `getOrElse` call typed.
typedef DailyAlertSummaryResourceStub = Never;