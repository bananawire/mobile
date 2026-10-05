import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_space.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_daily_summary.query.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_page.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/daily_alert_count.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';
import 'package:mobile/alerts/domain/services/alerts.query-service.dart';
import 'package:mobile/alerts/interfaces/pages/alerts_cubit.dart';
import 'package:mobile/core/failure.dart';
import 'package:mocktail/mocktail.dart';

import '../alerts_fixtures.dart';

class MockAlertsQueryService extends Mock implements AlertsQueryService {}

void main() {
  late MockAlertsQueryService queryService;
  late AlertsCubit cubit;

  AlertPage pageWith(List<String> ids, {int totalPages = 1, int number = 0}) {
    return AlertPage(
      content: ids.map((id) => buildAlert(id: id)).toList(),
      totalElements: ids.length,
      totalPages: totalPages,
      size: 20,
      number: number,
    );
  }

  void stubCurrentUserFlow({
    required Either<Failure, AlertPage> alerts,
    Either<Failure, List<DailyAlertCount>>? summary,
  }) {
    when(
      () => queryService.handleGetAlerts(
        any(),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => alerts);
    when(
      () => queryService.handleGetDailySummary(any()),
    ).thenAnswer(
      (_) async =>
          summary ?? const Right<Failure, List<DailyAlertCount>>(<DailyAlertCount>[]),
    );
  }

  void stubSpaceFlow({
    required Either<Failure, AlertPage> alerts,
    Either<Failure, List<DailyAlertCount>>? summary,
  }) {
    when(
      () => queryService.handleGetAlertsBySpace(
        any(),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => alerts);
    when(
      () => queryService.handleGetDailySummaryBySpace(any(), any()),
    ).thenAnswer(
      (_) async =>
          summary ?? const Right<Failure, List<DailyAlertCount>>(<DailyAlertCount>[]),
    );
  }

  setUpAll(() {
    registerFallbackValue(GetAlertsQuery());
    registerFallbackValue(GetAlertsBySpaceQuery(spaceId: 'space-1'));
    registerFallbackValue(GetAlertDailySummaryQuery());
  });

  setUp(() {
    queryService = MockAlertsQueryService();
    cubit = AlertsCubit(queryService);
    stubCurrentUserFlow(
      alerts: Right<Failure, AlertPage>(pageWith(const <String>[])),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('AlertsCubit initial state', () {
    test('should start idle without data and with the default filters',
        () async {
      // Arrange / Act
      final state = cubit.state;

      // Assert
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.activeAlertsPage, isNull);
      expect(state.historyAlertsPage, isNull);
      expect(state.dailySummary, isEmpty);
      expect(state.selectedStatus, isNull);
      expect(state.selectedMetric, isNull);
      expect(state.viewMode, AlertViewMode.list);
      expect(state.tab, AlertTab.active);
      expect(state.currentPage, 0);
      expect(state.pageSize, 20);
      expect(state.currentAlerts, isEmpty);
      expect(state.totalPages, 1);
      expect(state.canGoPrevious, isFalse);
      expect(state.canGoNext, isFalse);
    });

    test('should not call the query service before an explicit load', () async {
      // Arrange / Act
      await Future<void>.delayed(Duration.zero);

      // Assert
      verifyNever(
        () => queryService.handleGetAlerts(
          any(),
          status: any(named: 'status'),
        ),
      );
    });
  });

  group('AlertsCubit.load', () {
    blocTest<AlertsCubit, AlertsState>(
      'should emit a loading state and then the loaded page when the query '
      'service answers right',
      build: () => AlertsCubit(queryService),
      setUp: () {
        stubCurrentUserFlow(
          alerts: Right<Failure, AlertPage>(
            pageWith(const <String>['alert-1', 'alert-2'], totalPages: 2),
          ),
        );
      },
      act: (AlertsCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<AlertsState>()
            .having((state) => state.isLoading, 'isLoading', true)
            .having((state) => state.activeAlertsPage, 'activeAlertsPage', isNull)
            .having((state) => state.errorMessage, 'errorMessage', isNull),
        isA<AlertsState>()
            .having((state) => state.isLoading, 'isLoading', true),
        isA<AlertsState>()
            .having((state) => state.isLoading, 'isLoading', false)
            .having((state) => state.errorMessage, 'errorMessage', isNull)
            .having(
              (state) => state.activeAlertsPage?.content.length,
              'content length',
              2,
            )
            .having((state) => state.currentAlerts.length, 'currentAlerts', 2)
            .having((state) => state.totalPages, 'totalPages', 2)
            .having((state) => state.canGoNext, 'canGoNext', true),
      ],
    );

    blocTest<AlertsCubit, AlertsState>(
      'should emit the failure message and stop loading when the query service '
      'answers left',
      build: () => AlertsCubit(queryService),
      setUp: () {
        stubCurrentUserFlow(
          alerts: const Left<Failure, AlertPage>(
            Failure('Alerts service is down', statusCode: 503),
          ),
        );
      },
      act: (AlertsCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<AlertsState>().having((state) => state.isLoading, 'isLoading', true),
        isA<AlertsState>().having((state) => state.isLoading, 'isLoading', true),
        isA<AlertsState>()
            .having((state) => state.isLoading, 'isLoading', false)
            .having(
              (state) => state.errorMessage,
              'errorMessage',
              'Alerts service is down',
            )
            .having(
              (state) => state.activeAlertsPage,
              'activeAlertsPage',
              isNull,
            )
            .having((state) => state.currentAlerts, 'currentAlerts', isEmpty),
      ],
    );

    blocTest<AlertsCubit, AlertsState>(
      'should expose the daily summary when the summary query answers right',
      build: () => AlertsCubit(queryService),
      setUp: () {
        stubCurrentUserFlow(
          alerts: Right<Failure, AlertPage>(pageWith(const <String>[])),
          summary: const Right<Failure, List<DailyAlertCount>>(<DailyAlertCount>[
            DailyAlertCount(date: '2024-05-01', count: 4),
            DailyAlertCount(date: '2024-05-02', count: 1),
          ]),
        );
      },
      act: (AlertsCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<AlertsState>(),
        isA<AlertsState>(),
        isA<AlertsState>()
            .having((state) => state.isLoading, 'isLoading', false)
            .having((state) => state.dailySummary.length, 'dailySummary', 2)
            .having(
              (state) => state.dailySummary.first.count,
              'first count',
              4,
            )
            .having((state) => state.errorMessage, 'errorMessage', isNull),
      ],
    );

    blocTest<AlertsCubit, AlertsState>(
      'should surface the summary failure message when only the summary query '
      'fails',
      build: () => AlertsCubit(queryService),
      setUp: () {
        stubCurrentUserFlow(
          alerts: Right<Failure, AlertPage>(pageWith(const <String>['alert-1'])),
          summary: const Left<Failure, List<DailyAlertCount>>(
            Failure('Summary unavailable'),
          ),
        );
      },
      act: (AlertsCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<AlertsState>(),
        isA<AlertsState>(),
        isA<AlertsState>()
            .having((state) => state.errorMessage, 'errorMessage', 'Summary unavailable')
            .having((state) => state.dailySummary, 'dailySummary', isEmpty)
            .having((state) => state.isLoading, 'isLoading', false)
            .having(
              (state) => state.currentAlerts.length,
              'alerts still loaded',
              1,
            ),
      ],
    );

    blocTest<AlertsCubit, AlertsState>(
      'should prefer the alerts failure message when both queries fail',
      build: () => AlertsCubit(queryService),
      setUp: () {
        stubCurrentUserFlow(
          alerts: const Left<Failure, AlertPage>(Failure('Alerts unavailable')),
          summary: const Left<Failure, List<DailyAlertCount>>(
            Failure('Summary unavailable'),
          ),
        );
      },
      act: (AlertsCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<AlertsState>(),
        isA<AlertsState>(),
        isA<AlertsState>().having(
          (state) => state.errorMessage,
          'errorMessage',
          'Alerts unavailable',
        ),
      ],
    );

    test('should request the first page with the default page size and the '
        'active tab status filter', () async {
      // Arrange
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(pageWith(const <String>[])),
      );

      // Act
      await cubit.load();

      // Assert
      final captured = verify(
        () => queryService.handleGetAlerts(
          captureAny(),
          status: captureAny(named: 'status'),
        ),
      ).captured;
      final query = captured[0] as GetAlertsQuery;
      expect(query.page, 0);
      expect(query.size, 20);
      expect(captured[1], const <AlertStatus>[
        AlertStatus.active,
        AlertStatus.acknowledged,
      ]);
    });

    test('should request the default day window for the daily summary',
        () async {
      // Arrange
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(pageWith(const <String>[])),
      );

      // Act
      await cubit.load();

      // Assert
      final captured = verify(
        () => queryService.handleGetDailySummary(captureAny()),
      ).captured;
      expect((captured.single as GetAlertDailySummaryQuery).days, 30);
    });

    test('should clear the previous pages and reset the page number before '
        'reloading', () async {
      // Arrange
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(
          pageWith(const <String>['alert-old'], totalPages: 4, number: 3),
        ),
      );
      await cubit.loadCurrentUserAlerts(page: 3);
      expect(cubit.state.currentPage, 3);
      reset(queryService);
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(
          pageWith(const <String>['alert-new'], totalPages: 1, number: 0),
        ),
      );

      // Act
      await cubit.load();

      // Assert
      expect(cubit.state.currentPage, 0);
      expect(
        cubit.state.activeAlertsPage?.content.single.id.value,
        'alert-new',
        reason: 'The stale page is dropped while the reload is in flight and '
            'replaced by the fresh one',
      );
      expect(cubit.state.historyAlertsPage, isNull);
    });
  });

  group('AlertsCubit.loadCurrentUserAlerts', () {
    blocTest<AlertsCubit, AlertsState>(
      'should keep the loading flag until both queries resolve',
      build: () => AlertsCubit(queryService),
      setUp: () {
        stubCurrentUserFlow(
          alerts: Right<Failure, AlertPage>(pageWith(const <String>['alert-1'])),
        );
      },
      act: (AlertsCubit cubit) => cubit.loadCurrentUserAlerts(page: 1, size: 5),
      expect: () => <Matcher>[
        isA<AlertsState>().having((state) => state.isLoading, 'isLoading', true),
        isA<AlertsState>()
            .having((state) => state.isLoading, 'isLoading', false)
            .having((state) => state.currentPage, 'currentPage', 1)
            .having((state) => state.pageSize, 'pageSize', 5),
      ],
    );

    test('should store the requested page and size on the state', () async {
      // Arrange
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(pageWith(const <String>[])),
      );

      // Act
      await cubit.loadCurrentUserAlerts(page: 2, size: 7);

      // Assert
      final captured = verify(
        () => queryService.handleGetAlerts(
          captureAny(),
          status: any(named: 'status'),
        ),
      ).captured;
      final query = captured[0] as GetAlertsQuery;
      expect(query.page, 2);
      expect(query.size, 7);
      expect(cubit.state.currentPage, 2);
      expect(cubit.state.pageSize, 7);
    });

    test('should keep the previous page number when no page is provided',
        () async {
      // Arrange
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(
          pageWith(const <String>['a'], totalPages: 5, number: 1),
        ),
      );
      await cubit.loadCurrentUserAlerts(page: 1);

      // Act
      await cubit.loadCurrentUserAlerts();

      // Assert
      expect(cubit.state.currentPage, 1);
    });

    test('should report the thrown error text when the query service throws',
        () async {
      // Arrange
      when(
        () => queryService.handleGetAlerts(
          any(),
          status: any(named: 'status'),
        ),
      ).thenThrow(StateError('network down'));
      when(
        () => queryService.handleGetDailySummary(any()),
      ).thenAnswer(
        (_) async => const Right<Failure, List<DailyAlertCount>>(
          <DailyAlertCount>[],
        ),
      );

      // Act
      await cubit.loadCurrentUserAlerts();

      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, contains('network down'));
      expect(cubit.state.activeAlertsPage, isNull);
      expect(cubit.state.dailySummary, isEmpty);
    });
  });

  group('AlertsCubit.loadAlerts', () {
    setUp(() {
      stubSpaceFlow(
        alerts: Right<Failure, AlertPage>(
          pageWith(const <String>['alert-space'], totalPages: 1),
        ),
      );
    });

    test('should request the alerts and the summary of the given space',
        () async {
      // Arrange / Act
      await cubit.loadAlerts(spaceId: 'space-3', days: 14);

      // Assert
      final captured = verify(
        () => queryService.handleGetAlertsBySpace(
          captureAny(),
          status: captureAny(named: 'status'),
        ),
      ).captured;
      final query = captured[0] as GetAlertsBySpaceQuery;
      expect(query.spaceId, 'space-3');
      expect(query.page, 0);
      expect(query.size, 20);
      expect(captured[1], const <AlertStatus>[
        AlertStatus.active,
        AlertStatus.acknowledged,
      ]);
      verify(
        () => queryService.handleGetDailySummaryBySpace('space-3', 14),
      ).called(1);
    });

    test('should store the alerts in the active page while the active tab is '
        'selected', () async {
      // Arrange / Act
      await cubit.loadAlerts(spaceId: 'space-3');

      // Assert
      expect(cubit.state.activeAlertsPage?.content.single.id.value, 'alert-space');
      expect(cubit.state.historyAlertsPage, isNull);
    });

    test('should store the alerts in the history page while the history tab is '
        'selected', () async {
      // Arrange
      cubit.setTab(AlertTab.history);
      reset(queryService);
      stubSpaceFlow(
        alerts: Right<Failure, AlertPage>(pageWith(const <String>['alert-history'])),
      );

      // Act
      await cubit.loadAlerts(spaceId: 'space-3');

      // Assert
      expect(
        cubit.state.historyAlertsPage?.content.single.id.value,
        'alert-history',
      );
      expect(cubit.state.activeAlertsPage, isNull);
    });

    test('should surface the failure message when the space alerts query fails',
        () async {
      // Arrange
      when(
        () => queryService.handleGetAlertsBySpace(
          any(),
          status: any(named: 'status'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, AlertPage>(Failure('Space not found')),
      );

      // Act
      await cubit.loadAlerts(spaceId: 'ghost');

      // Assert
      expect(cubit.state.errorMessage, 'Space not found');
      expect(cubit.state.isLoading, isFalse);
    });
  });

  group('AlertsCubit pagination', () {
    test('should not call the query service when next page is requested on a '
        'single page result', () async {
      // Arrange
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(pageWith(const <String>['alert-1'])),
      );
      await cubit.load();

      // Act
      await cubit.nextPage();

      // Assert
      expect(cubit.state.currentPage, 0);
      verify(
        () => queryService.handleGetAlerts(
          any(),
          status: any(named: 'status'),
        ),
      ).called(1);
    });

    test('should request the next page when more pages are available',
        () async {
      // Arrange
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(
          pageWith(const <String>['alert-1'], totalPages: 3, number: 0),
        ),
      );
      await cubit.load();

      // Act
      await cubit.nextPage();

      // Assert
      expect(cubit.state.currentPage, 1);
      verify(
        () => queryService.handleGetAlerts(
          any(
            that: isA<GetAlertsQuery>().having((query) => query.page, 'page', 1),
          ),
          status: any(named: 'status'),
        ),
      ).called(1);
    });

    test('should request the previous page when the cubit is past the first '
        'page', () async {
      // Arrange
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(
          pageWith(const <String>['alert-2'], totalPages: 3, number: 1),
        ),
      );
      await cubit.loadCurrentUserAlerts(page: 1);

      // Act
      await cubit.previousPage();

      // Assert
      expect(cubit.state.currentPage, 0);
    });

    test('should not call the query service when previous page is requested on '
        'the first page', () async {
      // Arrange
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(pageWith(const <String>['alert-1'])),
      );
      await cubit.load();

      // Act
      await cubit.previousPage();

      // Assert
      verify(
        () => queryService.handleGetAlerts(
          any(),
          status: any(named: 'status'),
        ),
      ).called(1);
    });

    test('should reload the first page when the alerts are refreshed',
        () async {
      // Arrange
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(
          pageWith(const <String>['alert-9'], totalPages: 5, number: 4),
        ),
      );
      await cubit.loadCurrentUserAlerts(page: 4);

      // Act
      await cubit.refreshAlerts();

      // Assert
      expect(cubit.state.currentPage, 0);
      final captured = verify(
        () => queryService.handleGetAlerts(
          captureAny(),
          status: any(named: 'status'),
        ),
      ).captured;
      expect((captured.last as GetAlertsQuery).page, 0);
    });

    test('should reset the page number and reload with the history filter when '
        'the tab changes', () async {
      // Arrange
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(
          pageWith(const <String>['alert-1'], totalPages: 3, number: 2),
        ),
      );
      await cubit.loadCurrentUserAlerts(page: 2);

      // Act
      cubit.setTab(AlertTab.history);
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(cubit.state.tab, AlertTab.history);
      expect(cubit.state.currentPage, 0);
      final captured = verify(
        () => queryService.handleGetAlerts(
          captureAny(),
          status: captureAny(named: 'status'),
        ),
      ).captured;
      expect(captured.last, const <AlertStatus>[AlertStatus.resolved]);
    });
  });

  group('AlertsCubit filters', () {
    test('should store the selected status filter', () {
      // Arrange / Act
      cubit.setStatusFilter(AlertStatus.resolved);

      // Assert
      expect(cubit.state.selectedStatus, AlertStatus.resolved);
    });

    test('should clear the selected status filter when null is given', () {
      // Arrange
      cubit.setStatusFilter(AlertStatus.resolved);

      // Act
      cubit.setStatusFilter(null);

      // Assert
      expect(cubit.state.selectedStatus, isNull);
    });

    test('should store the selected metric filter', () {
      // Arrange / Act
      cubit.setMetricFilter(MetricType.co2);

      // Assert
      expect(cubit.state.selectedMetric, MetricType.co2);
    });

    test('should store the requested view mode', () {
      // Arrange / Act
      cubit.setViewMode(AlertViewMode.grid);

      // Assert
      expect(cubit.state.viewMode, AlertViewMode.grid);
    });

    test('should expose the reloaded history alerts and keep the active page '
        'when the tab changes', () async {
      // Arrange
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(
          pageWith(const <String>['alert-1'], totalPages: 2, number: 0),
        ),
      );
      await cubit.load();
      reset(queryService);
      stubCurrentUserFlow(
        alerts: Right<Failure, AlertPage>(
          pageWith(const <String>['alert-resolved'], totalPages: 2, number: 0),
        ),
      );

      // Act
      cubit.setTab(AlertTab.history);
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(cubit.state.currentAlerts.single.id.value, 'alert-resolved');
      expect(
        cubit.state.activeAlertsPage?.content.single.id.value,
        'alert-1',
        reason: 'The active page is kept because the reload targets the history '
            'tab only',
      );
    });
  });

  group('AlertsCubit concurrent requests', () {
    test('should issue a second request when load is called while a previous '
        'request is still pending', () async {
      // Arrange
      final completer = Completer<Either<Failure, AlertPage>>();
      when(
        () => queryService.handleGetAlerts(
          any(),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) => completer.future);
      when(
        () => queryService.handleGetDailySummary(any()),
      ).thenAnswer(
        (_) async => const Right<Failure, List<DailyAlertCount>>(
          <DailyAlertCount>[],
        ),
      );

      // Act
      final firstLoad = cubit.load();
      final secondLoad = cubit.load();
      completer.complete(Right<Failure, AlertPage>(pageWith(const <String>['a'])));
      await Future.wait(<Future<void>>[firstLoad, secondLoad]);

      // Assert
      verify(
        () => queryService.handleGetAlerts(
          any(),
          status: any(named: 'status'),
        ),
      ).called(2);
      expect(cubit.state.isLoading, isFalse);
    });

    test('should keep the in flight request pending until the completer '
        'resolves', () async {
      // Arrange
      final completer = Completer<Either<Failure, AlertPage>>();
      when(
        () => queryService.handleGetAlerts(
          any(),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) => completer.future);
      when(
        () => queryService.handleGetDailySummary(any()),
      ).thenAnswer(
        (_) async => const Right<Failure, List<DailyAlertCount>>(
          <DailyAlertCount>[],
        ),
      );

      // Act
      final load = cubit.loadCurrentUserAlerts();
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(cubit.state.isLoading, isTrue);
      completer.complete(Right<Failure, AlertPage>(pageWith(const <String>['a'])));
      await load;
      expect(cubit.state.isLoading, isFalse);
    });
  });
}