import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_page.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/daily_alert_count.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';
import 'package:mobile/alerts/interfaces/pages/alerts_cubit.dart';
import 'package:mobile/alerts/interfaces/pages/alerts_screen.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/notifications/domain/model/queries/get_notifications.query.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';
import 'package:mobile/notifications/domain/services/notifications.query-service.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';
import 'package:mocktail/mocktail.dart';

import 'alerts_widget_harness.dart';

/// `AlertsScreen` builds the shared `ClairAppBar`, which resolves
/// `NotificationsCubit` from the service locator. The locator is intentionally
/// not bootstrapped in tests, so a cubit double is registered for the duration
/// of the suite and the OneSignal platform channel it touches is stubbed.
class MockNotificationsQueryService extends Mock
    implements NotificationsQueryService {}

void main() {
  const oneSignalChannel = MethodChannel('OneSignal#notifications');

  late FakeAlertsQueryService service;
  late AlertsCubit cubit;
  late NotificationsCubit notificationsCubit;

  Future<void> pumpAlertsScreen(
    WidgetTester tester, {
    Size surface = const Size(1400, 2600),
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      alertsTestApp(
        child: BlocProvider<AlertsCubit>.value(
          value: cubit,
          child: const AlertsScreen(),
        ),
      ),
    );
    // The screen loads on the first post frame callback.
    await tester.pump();
    await tester.pump();
  }

  setUpAll(() {
    registerFallbackValue(GetNotificationsQuery());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      oneSignalChannel,
      (call) async => null,
    );
  });

  setUp(() {
    service = FakeAlertsQueryService();
    cubit = AlertsCubit(service);

    final notificationsService = MockNotificationsQueryService();
    when(
      () => notificationsService.handleGetNotifications(any()),
    ).thenAnswer(
      (_) async => const Left<Failure, NotificationPage>(
        Failure('notifications are not under test'),
      ),
    );
    notificationsCubit = NotificationsCubit(notificationsService);
    getIt.registerSingleton<NotificationsCubit>(notificationsCubit);
  });

  tearDown(() async {
    await cubit.close();
    await notificationsCubit.close();
    await getIt.reset();
  });

  group('AlertsScreen first load', () {
    testWidgets('should request the active alerts of the current user on the '
        'first frame', (WidgetTester tester) async {
      // Arrange / Act
      await pumpAlertsScreen(tester);

      // Assert
      expect(service.alertsCalls, 1);
      expect(service.summaryCalls, 1);
      expect(service.requestedQueries.single.page, 0);
      expect(service.requestedQueries.single.size, 20);
      expect(service.requestedStatusFilters.single, const <AlertStatus>[
        AlertStatus.active,
        AlertStatus.acknowledged,
      ]);
    });

    testWidgets('should render the screen title, update info, tabs and chart',
        (WidgetTester tester) async {
      // Arrange / Act
      await pumpAlertsScreen(tester);

      // Assert
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Updated just now'), findsOneWidget);
      expect(find.text('Active Alerts'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Last 30 days'), findsOneWidget);
    });

    testWidgets('should render the empty state when the backend has no alerts',
        (WidgetTester tester) async {
      // Arrange
      service.alertsResult = Right<Failure, AlertPage>(buildTestPage(const <Alert>[]));

      // Act
      await pumpAlertsScreen(tester);

      // Assert
      expect(find.text('No alerts found'), findsOneWidget);
      expect(find.text('DEVICE'), findsNothing);
    });

    testWidgets('should render one table row per alert with its severity and '
        'status', (WidgetTester tester) async {
      // Arrange
      service.alertsResult = Right<Failure, AlertPage>(
        buildTestPage(<Alert>[
          buildTestAlert(id: 'alert-1', deviceName: 'Sensor A'),
          buildTestAlert(
            id: 'alert-2',
            deviceName: 'Sensor B',
            severity: AlertSeverity.warning,
            status: AlertStatus.acknowledged,
            metric: MetricType.co2,
          ),
        ]),
      );

      // Act
      await pumpAlertsScreen(tester);

      // Assert
      expect(find.text('Sensor A'), findsOneWidget);
      expect(find.text('Sensor B'), findsOneWidget);
      expect(find.text('CRITICAL'), findsOneWidget);
      expect(find.text('WARNING'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('ACKNOWLEDGED'), findsOneWidget);
    });

    testWidgets('should render the error message when the query service fails',
        (WidgetTester tester) async {
      // Arrange
      service.alertsResult = const Left<Failure, AlertPage>(
        Failure('Alerts service is down'),
      );

      // Act
      await pumpAlertsScreen(tester);

      // Assert
      expect(find.text('Alerts service is down'), findsOneWidget);
      expect(find.text('No alerts found'), findsNothing);
    });

    testWidgets('should hide the generic unexpected error message because the '
        'screen swallows it', (WidgetTester tester) async {
      // Arrange
      service.alertsResult = const Left<Failure, AlertPage>(
        Failure('An unexpected error occurred'),
      );

      // Act
      await pumpAlertsScreen(tester);

      // Assert
      expect(find.text('An unexpected error occurred'), findsNothing);
      expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
    });

    testWidgets('should render the daily summary chart when the summary query '
        'answers', (WidgetTester tester) async {
      // Arrange
      final now = DateTime.now();
      final today = '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      service.summaryResult = Right<Failure, List<DailyAlertCount>>(<DailyAlertCount>[
        DailyAlertCount(date: today, count: 4),
      ]);

      // Act
      await pumpAlertsScreen(tester);

      // Assert
      expect(find.text('Last 30 days'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AlertsScreen metric filter', () {
    testWidgets('should keep only the alerts of the selected metric',
        (WidgetTester tester) async {
      // Arrange
      service.alertsResult = Right<Failure, AlertPage>(
        buildTestPage(<Alert>[
          buildTestAlert(id: 'alert-1', deviceName: 'PmSensor', metric: MetricType.pm25),
          buildTestAlert(id: 'alert-2', deviceName: 'Co2Sensor', metric: MetricType.co2),
        ]),
      );
      await pumpAlertsScreen(tester);

      // Act
      cubit.setMetricFilter(MetricType.co2);
      await tester.pump();
      await tester.pump();

      // Assert
      expect(find.text('Co2Sensor'), findsOneWidget);
      expect(find.text('PmSensor'), findsNothing);
    });

    testWidgets('should render every alert again when the metric filter is '
        'cleared', (WidgetTester tester) async {
      // Arrange
      service.alertsResult = Right<Failure, AlertPage>(
        buildTestPage(<Alert>[
          buildTestAlert(id: 'alert-1', deviceName: 'PmSensor'),
          buildTestAlert(id: 'alert-2', deviceName: 'Co2Sensor', metric: MetricType.co2),
        ]),
      );
      await pumpAlertsScreen(tester);
      cubit.setMetricFilter(MetricType.co2);
      await tester.pump();
      await tester.pump();

      // Act
      cubit.setMetricFilter(null);
      await tester.pump();
      await tester.pump();

      // Assert
      expect(find.text('Co2Sensor'), findsOneWidget);
      expect(find.text('PmSensor'), findsOneWidget);
    });
  });

  group('AlertsScreen tabs', () {
    testWidgets('should request the resolved alerts when the history tab is '
        'selected', (WidgetTester tester) async {
      // Arrange
      await pumpAlertsScreen(tester);

      // Act
      await tester.tap(find.text('History'));
      await tester.pump();
      await tester.pump();

      // Assert
      expect(service.alertsCalls, 2);
      expect(
        service.requestedStatusFilters.last,
        const <AlertStatus>[AlertStatus.resolved],
      );
    });

    testWidgets('should render the alerts of the history tab',
        (WidgetTester tester) async {
      // Arrange
      service.alertsResult = Right<Failure, AlertPage>(
        buildTestPage(<Alert>[buildTestAlert(id: 'alert-1')]),
      );
      await pumpAlertsScreen(tester);

      // Act
      await tester.tap(find.text('History'));
      await tester.pump();
      await tester.pump();

      // Assert
      expect(find.text('Sensor A'), findsOneWidget);
    });
  });

  group('AlertsScreen pagination', () {
    testWidgets('should hide the pagination bar when there is a single page',
        (WidgetTester tester) async {
      // Arrange
      service.alertsResult = Right<Failure, AlertPage>(
        buildTestPage(<Alert>[buildTestAlert()], totalPages: 1),
      );

      // Act
      await pumpAlertsScreen(tester);

      // Assert
      expect(find.text('Page 1 of 1'), findsNothing);
      expect(find.widgetWithText(TextButton, 'Next'), findsNothing);
    });

    testWidgets('should show the pagination bar when more pages are available',
        (WidgetTester tester) async {
      // Arrange
      service.alertsResult = Right<Failure, AlertPage>(
        buildTestPage(<Alert>[buildTestAlert()], totalPages: 3, number: 0),
      );

      // Act
      await pumpAlertsScreen(tester);

      // Assert
      expect(find.text('Page 1 of 3'), findsOneWidget);
      final next = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Next'),
      );
      final previous = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Previous'),
      );
      expect(next.onPressed, isNotNull);
      expect(previous.onPressed, isNull);
    });

    testWidgets('should request the next page when the next button is tapped',
        (WidgetTester tester) async {
      // Arrange
      service.alertsResult = Right<Failure, AlertPage>(
        buildTestPage(<Alert>[buildTestAlert()], totalPages: 3, number: 0),
      );
      await pumpAlertsScreen(tester);

      // Act
      await tester.tap(find.widgetWithText(TextButton, 'Next'));
      await tester.pump();
      await tester.pump();

      // Assert
      expect(service.requestedQueries.last.page, 1);
      expect(find.text('Page 2 of 3'), findsOneWidget);
    });

    testWidgets('should request the previous page when the previous button is '
        'tapped', (WidgetTester tester) async {
      // Arrange
      service.alertsResult = Right<Failure, AlertPage>(
        buildTestPage(<Alert>[buildTestAlert()], totalPages: 3, number: 0),
      );
      await pumpAlertsScreen(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Next'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Page 2 of 3'), findsOneWidget);

      // Act
      await tester.tap(find.widgetWithText(TextButton, 'Previous'));
      await tester.pump();
      await tester.pump();

      // Assert
      expect(service.requestedQueries.last.page, 0);
      expect(find.text('Page 1 of 3'), findsOneWidget);
    });
  });

  group('AlertsScreen pull to refresh', () {
    testWidgets('should reload the current user alerts when the list is pulled '
        'down', (WidgetTester tester) async {
      // Arrange
      service.alertsResult = Right<Failure, AlertPage>(
        buildTestPage(<Alert>[buildTestAlert()], totalPages: 1),
      );
      await pumpAlertsScreen(tester, surface: const Size(800, 600));
      expect(service.alertsCalls, 1);

      // Act
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Assert
      expect(service.alertsCalls, 2);
      expect(service.requestedQueries.last.page, 0);
    });

    testWidgets('should reload the current user alerts when the refresh control '
        'callback is invoked', (WidgetTester tester) async {
      // Arrange
      service.alertsResult = Right<Failure, AlertPage>(
        buildTestPage(<Alert>[buildTestAlert()], totalPages: 1),
      );
      await pumpAlertsScreen(tester);
      expect(service.alertsCalls, 1);

      // Act
      final indicator =
          tester.widget<RefreshIndicator>(find.byType(RefreshIndicator));
      await indicator.onRefresh();
      await tester.pump();
      await tester.pump();

      // Assert
      expect(service.alertsCalls, 2);
    });

    testWidgets('should expose a refresh indicator that reacts to the drag',
        (WidgetTester tester) async {
      // Arrange
      service.alertsResult = Right<Failure, AlertPage>(
        buildTestPage(<Alert>[buildTestAlert()]),
      );
      await pumpAlertsScreen(tester);

      // Act
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, 200),
      );
      await tester.pump();

      // Assert
      expect(
        find.byType(RefreshIndicator),
        findsOneWidget,
        reason: 'The screen always wraps its list in a refresh indicator',
      );
    });
  });
}
