import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_space.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_daily_summary.query.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_page.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/daily_alert_count.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';
import 'package:mobile/alerts/domain/services/alerts.query-service.dart';
import 'package:mobile/alerts/interfaces/pages/alerts_cubit.dart';
import 'package:mobile/core/failure.dart';

class MockAlertsQueryService extends Mock implements AlertsQueryService {}

class FakeGetAlertsQuery extends Fake implements GetAlertsQuery {}

class FakeGetAlertsBySpaceQuery extends Fake implements GetAlertsBySpaceQuery {}

class FakeGetAlertDailySummaryQuery extends Fake implements GetAlertDailySummaryQuery {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGetAlertsQuery());
    registerFallbackValue(FakeGetAlertsBySpaceQuery());
    registerFallbackValue(FakeGetAlertDailySummaryQuery());
  });

  group('AlertsCubit', () {
    late MockAlertsQueryService mockQueryService;
    late AlertsCubit cubit;

    Alert createDummyAlert(String id, {AlertStatus status = AlertStatus.active}) {
      return Alert(
        id: AlertId(id),
        deviceId: 'dev-1',
        metric: MetricType.pm25,
        metricLabel: 'PM2.5',
        metricUnit: 'µg/m³',
        thresholdValue: 25.0,
        actualValue: 35.0,
        message: 'High PM2.5',
        status: status,
        severity: AlertSeverity.warning,
        occurredAt: '2026-10-02T10:00:00Z',
        createdAt: '2026-10-02T10:00:00Z',
      );
    }

    AlertPage createDummyPage({
      int totalElements = 20,
      int totalPages = 2,
      int page = 0,
      int size = 10,
    }) {
      return AlertPage(
        content: [createDummyAlert('alert-1')],
        totalElements: totalElements,
        totalPages: totalPages,
        size: size,
        number: page,
      );
    }

    setUp(() {
      mockQueryService = MockAlertsQueryService();
      cubit = AlertsCubit(mockQueryService);
    });

    tearDown(() {
      cubit.close();
    });

    test('should have correct initial state', () {
      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.activeAlertsPage, isNull);
      expect(cubit.state.historyAlertsPage, isNull);
      expect(cubit.state.dailySummary, isEmpty);
      expect(cubit.state.selectedStatus, isNull);
      expect(cubit.state.selectedMetric, isNull);
      expect(cubit.state.viewMode, equals(AlertViewMode.list));
      expect(cubit.state.tab, equals(AlertTab.active));
      expect(cubit.state.currentPage, equals(0));
      expect(cubit.state.pageSize, equals(20));
      expect(cubit.state.currentAlerts, isEmpty);
      expect(cubit.state.totalPages, equals(1));
      expect(cubit.state.canGoPrevious, isFalse);
      expect(cubit.state.canGoNext, isFalse);
    });

    group('load() & loadCurrentUserAlerts()', () {
      blocTest<AlertsCubit, AlertsState>(
        'should emit loading and then success with activeAlertsPage and dailySummary on loadCurrentUserAlerts when tab is active',
        build: () {
          when(
            () => mockQueryService.handleGetAlerts(
              any(),
              status: any(named: 'status'),
            ),
          ).thenAnswer((_) async => Right(createDummyPage()));

          when(
            () => mockQueryService.handleGetDailySummary(any()),
          ).thenAnswer((_) async => const Right([DailyAlertCount(date: '2026-10-02', count: 3)]));

          return cubit;
        },
        act: (cubit) => cubit.loadCurrentUserAlerts(),
        expect: () => [
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isTrue)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isFalse)
              .having((s) => s.activeAlertsPage, 'activeAlertsPage', isNotNull)
              .having((s) => s.dailySummary.length, 'dailySummary length', equals(1))
              .having((s) => s.currentAlerts.length, 'currentAlerts length', equals(1))
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should emit historyAlertsPage on loadCurrentUserAlerts when tab is history',
        build: () {
          when(
            () => mockQueryService.handleGetAlerts(
              any(),
              status: any(named: 'status'),
            ),
          ).thenAnswer((_) async => Right(createDummyPage()));

          when(
            () => mockQueryService.handleGetDailySummary(any()),
          ).thenAnswer((_) async => const Right([]));

          return cubit;
        },
        seed: () => const AlertsState(tab: AlertTab.history),
        act: (cubit) => cubit.loadCurrentUserAlerts(),
        expect: () => [
          isA<AlertsState>().having((s) => s.isLoading, 'isLoading', isTrue),
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isFalse)
              .having((s) => s.historyAlertsPage, 'historyAlertsPage', isNotNull)
              .having((s) => s.activeAlertsPage, 'activeAlertsPage', isNull)
              .having((s) => s.currentAlerts.length, 'currentAlerts length', equals(1)),
        ],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should emit errorMessage when query service returns Failure',
        build: () {
          when(
            () => mockQueryService.handleGetAlerts(
              any(),
              status: any(named: 'status'),
            ),
          ).thenAnswer((_) async => const Left(Failure('Failed to load alerts', statusCode: 500)));

          when(
            () => mockQueryService.handleGetDailySummary(any()),
          ).thenAnswer((_) async => const Right([]));

          return cubit;
        },
        act: (cubit) => cubit.loadCurrentUserAlerts(),
        expect: () => [
          isA<AlertsState>().having((s) => s.isLoading, 'isLoading', isTrue),
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isFalse)
              .having((s) => s.errorMessage, 'errorMessage', equals('Failed to load alerts')),
        ],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should emit errorMessage when query service throws an unexpected exception',
        build: () {
          when(
            () => mockQueryService.handleGetAlerts(
              any(),
              status: any(named: 'status'),
            ),
          ).thenThrow(Exception('Network error'));

          return cubit;
        },
        act: (cubit) => cubit.loadCurrentUserAlerts(),
        expect: () => [
          isA<AlertsState>().having((s) => s.isLoading, 'isLoading', isTrue),
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isFalse)
              .having((s) => s.errorMessage, 'errorMessage', contains('Network error'))
              .having((s) => s.activeAlertsPage, 'activeAlertsPage', isNull)
              .having((s) => s.dailySummary, 'dailySummary', isEmpty),
        ],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should reset pagination and reload current user alerts on load()',
        build: () {
          when(
            () => mockQueryService.handleGetAlerts(
              any(),
              status: any(named: 'status'),
            ),
          ).thenAnswer((_) async => Right(createDummyPage()));

          when(
            () => mockQueryService.handleGetDailySummary(any()),
          ).thenAnswer((_) async => const Right([]));

          return cubit;
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isTrue)
              .having((s) => s.currentPage, 'currentPage', equals(0)),
          isA<AlertsState>().having((s) => s.isLoading, 'isLoading', isTrue),
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isFalse)
              .having((s) => s.activeAlertsPage, 'activeAlertsPage', isNotNull),
        ],
      );
    });

    group('loadAlerts(spaceId)', () {
      blocTest<AlertsCubit, AlertsState>(
        'should load alerts by space and daily summary by space successfully',
        build: () {
          when(
            () => mockQueryService.handleGetAlertsBySpace(
              any(),
              status: any(named: 'status'),
            ),
          ).thenAnswer((_) async => Right(createDummyPage()));

          when(
            () => mockQueryService.handleGetDailySummaryBySpace(any(), any()),
          ).thenAnswer((_) async => const Right([DailyAlertCount(date: '2026-10-02', count: 5)]));

          return cubit;
        },
        act: (cubit) => cubit.loadAlerts(spaceId: 'space-101'),
        expect: () => [
          isA<AlertsState>().having((s) => s.isLoading, 'isLoading', isTrue),
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isFalse)
              .having((s) => s.activeAlertsPage, 'activeAlertsPage', isNotNull)
              .having((s) => s.dailySummary.length, 'dailySummary', equals(1))
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should emit errorMessage when loading alerts by space fails',
        build: () {
          when(
            () => mockQueryService.handleGetAlertsBySpace(
              any(),
              status: any(named: 'status'),
            ),
          ).thenAnswer((_) async => const Left(Failure('Space alerts unavailable', statusCode: 403)));

          when(
            () => mockQueryService.handleGetDailySummaryBySpace(any(), any()),
          ).thenAnswer((_) async => const Right([]));

          return cubit;
        },
        act: (cubit) => cubit.loadAlerts(spaceId: 'space-forbidden'),
        expect: () => [
          isA<AlertsState>().having((s) => s.isLoading, 'isLoading', isTrue),
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isFalse)
              .having((s) => s.errorMessage, 'errorMessage', equals('Space alerts unavailable')),
        ],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should catch exception and set errorMessage when loadAlerts throws',
        build: () {
          when(
            () => mockQueryService.handleGetAlertsBySpace(
              any(),
              status: any(named: 'status'),
            ),
          ).thenThrow(Exception('Fatal error'));

          return cubit;
        },
        act: (cubit) => cubit.loadAlerts(spaceId: 'space-error'),
        expect: () => [
          isA<AlertsState>().having((s) => s.isLoading, 'isLoading', isTrue),
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isFalse)
              .having((s) => s.errorMessage, 'errorMessage', contains('Fatal error')),
        ],
      );
    });

    group('filter & view mode setters', () {
      blocTest<AlertsCubit, AlertsState>(
        'should update selectedStatus when setStatusFilter is called',
        build: () => cubit,
        act: (cubit) => cubit.setStatusFilter(AlertStatus.active),
        expect: () => [
          isA<AlertsState>().having((s) => s.selectedStatus, 'selectedStatus', equals(AlertStatus.active)),
        ],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should clear selectedStatus when setStatusFilter is called with null',
        build: () => cubit,
        seed: () => const AlertsState(selectedStatus: AlertStatus.active),
        act: (cubit) => cubit.setStatusFilter(null),
        expect: () => [
          isA<AlertsState>().having((s) => s.selectedStatus, 'selectedStatus', isNull),
        ],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should update selectedMetric when setMetricFilter is called',
        build: () => cubit,
        act: (cubit) => cubit.setMetricFilter(MetricType.co2),
        expect: () => [
          isA<AlertsState>().having((s) => s.selectedMetric, 'selectedMetric', equals(MetricType.co2)),
        ],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should update viewMode when setViewMode is called',
        build: () => cubit,
        act: (cubit) => cubit.setViewMode(AlertViewMode.grid),
        expect: () => [
          isA<AlertsState>().having((s) => s.viewMode, 'viewMode', equals(AlertViewMode.grid)),
        ],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should switch tab, reset currentPage to 0, and refresh alerts when setTab is called',
        build: () {
          when(
            () => mockQueryService.handleGetAlerts(
              any(),
              status: any(named: 'status'),
            ),
          ).thenAnswer((_) async => Right(createDummyPage()));

          when(
            () => mockQueryService.handleGetDailySummary(any()),
          ).thenAnswer((_) async => const Right([]));

          return cubit;
        },
        seed: () => const AlertsState(currentPage: 3, tab: AlertTab.active),
        act: (cubit) => cubit.setTab(AlertTab.history),
        expect: () => [
          isA<AlertsState>()
              .having((s) => s.tab, 'tab', equals(AlertTab.history))
              .having((s) => s.currentPage, 'currentPage', equals(0)),
          isA<AlertsState>().having((s) => s.isLoading, 'isLoading', isTrue),
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isFalse)
              .having((s) => s.tab, 'tab', equals(AlertTab.history)),
        ],
      );
    });

    group('pagination', () {
      blocTest<AlertsCubit, AlertsState>(
        'should advance to nextPage when canGoNext is true',
        build: () {
          when(
            () => mockQueryService.handleGetAlerts(
              any(),
              status: any(named: 'status'),
            ),
          ).thenAnswer((_) async => Right(createDummyPage(page: 1, totalPages: 3)));

          when(
            () => mockQueryService.handleGetDailySummary(any()),
          ).thenAnswer((_) async => const Right([]));

          return cubit;
        },
        seed: () => AlertsState(
          currentPage: 0,
          activeAlertsPage: createDummyPage(page: 0, totalPages: 3),
        ),
        act: (cubit) => cubit.nextPage(),
        expect: () => [
          isA<AlertsState>().having((s) => s.isLoading, 'isLoading', isTrue),
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isFalse)
              .having((s) => s.currentPage, 'currentPage', equals(1)),
        ],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should not advance when canGoNext is false',
        build: () => cubit,
        seed: () => AlertsState(
          currentPage: 2,
          activeAlertsPage: createDummyPage(page: 2, totalPages: 3),
        ),
        act: (cubit) => cubit.nextPage(),
        expect: () => [],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should go to previousPage when canGoPrevious is true',
        build: () {
          when(
            () => mockQueryService.handleGetAlerts(
              any(),
              status: any(named: 'status'),
            ),
          ).thenAnswer((_) async => Right(createDummyPage(page: 0, totalPages: 3)));

          when(
            () => mockQueryService.handleGetDailySummary(any()),
          ).thenAnswer((_) async => const Right([]));

          return cubit;
        },
        seed: () => AlertsState(
          currentPage: 1,
          activeAlertsPage: createDummyPage(page: 1, totalPages: 3),
        ),
        act: (cubit) => cubit.previousPage(),
        expect: () => [
          isA<AlertsState>().having((s) => s.isLoading, 'isLoading', isTrue),
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isFalse)
              .having((s) => s.currentPage, 'currentPage', equals(0)),
        ],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should not go previous when canGoPrevious is false',
        build: () => cubit,
        seed: () => const AlertsState(currentPage: 0),
        act: (cubit) => cubit.previousPage(),
        expect: () => [],
      );

      blocTest<AlertsCubit, AlertsState>(
        'should reload page 0 when refreshAlerts is called',
        build: () {
          when(
            () => mockQueryService.handleGetAlerts(
              any(),
              status: any(named: 'status'),
            ),
          ).thenAnswer((_) async => Right(createDummyPage(page: 0, totalPages: 2)));

          when(
            () => mockQueryService.handleGetDailySummary(any()),
          ).thenAnswer((_) async => const Right([]));

          return cubit;
        },
        seed: () => const AlertsState(currentPage: 1),
        act: (cubit) => cubit.refreshAlerts(),
        expect: () => [
          isA<AlertsState>().having((s) => s.isLoading, 'isLoading', isTrue),
          isA<AlertsState>()
              .having((s) => s.isLoading, 'isLoading', isFalse)
              .having((s) => s.currentPage, 'currentPage', equals(0)),
        ],
      );
    });
  });
}
