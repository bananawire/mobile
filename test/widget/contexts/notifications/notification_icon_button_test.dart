import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';
import 'package:mobile/notifications/interfaces/widgets/notification_icon_button.dart';

import 'helpers/notifications_widget_harness.dart';

void main() {
  late FakeNotificationsQueryService queryService;
  late NotificationsCubit cubit;

  setUp(() {
    // The cubit registers a OneSignal foreground listener when it is built.
    // The widget test binding satisfies the plugin bridge and the listener is
    // never fired, so the plugin itself is never initialised.
    queryService = FakeNotificationsQueryService();
    cubit = NotificationsCubit(queryService);
    registerNotificationsCubit(cubit);
  });

  group('NotificationIconButton badge', () {
    testWidgets('should show the unread count on the bell badge',
        (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[
            buildWidgetNotification(id: 'notification-1'),
            buildWidgetNotification(id: 'notification-2'),
            buildWidgetNotification(id: 'notification-3'),
          ],
          totalElements: 3,
        ),
      );

      // Act
      await tester.pumpWidget(
        notificationsTestApp(child: const NotificationIconButton()),
      );
      await settle(tester);

      // Assert
      expect(cubit.state.unreadCount, 3);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should hide the badge when every notification was seen',
        (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(const <NotificationLog>[], totalElements: 0),
      );

      // Act
      await tester.pumpWidget(
        notificationsTestApp(child: const NotificationIconButton()),
      );
      await settle(tester);

      // Assert
      expect(cubit.state.unreadCount, 0);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('should hide the badge once the user has seen the list',
        (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[buildWidgetNotification()],
          totalElements: 2,
        ),
      );
      await tester.pumpWidget(
        notificationsTestApp(child: const NotificationIconButton()),
      );
      await settle(tester);
      expect(find.text('2'), findsOneWidget);

      // Act
      cubit.markAllAsSeen();
      await settle(tester);

      // Assert
      expect(cubit.state.unreadCount, 0);
      expect(find.text('2'), findsNothing);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('should show the whole unread count when it is more than two '
        'digits long', (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[buildWidgetNotification()],
          totalElements: 120,
        ),
      );

      // Act
      await tester.pumpWidget(
        notificationsTestApp(child: const NotificationIconButton()),
      );
      await settle(tester);

      // Assert
      expect(tester.takeException(), isNull);
      expect(find.text('120'), findsOneWidget);
    });
  });

  group('NotificationIconButton lifecycle', () {
    testWidgets('should load the first page of notifications when it is '
        'created', (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        notificationsTestApp(child: const NotificationIconButton()),
      );
      await settle(tester);

      // Assert
      expect(queryService.calls, 1);
      expect(queryService.requestedPages, <int>[0]);
      expect(cubit.state.isLoading, isFalse);
    });
  });

  group('NotificationIconButton navigation', () {
    testWidgets('should push the notifications route when tapped from another '
        'route', (WidgetTester tester) async {
      // Arrange
      final router = notificationsRouter(
        child: const NotificationIconButton(),
      );
      await pumpRoutedApp(tester, router);
      expect(currentLocation(router), '/home');
      expect(routeDepth(router), 1);

      // Act
      await tester.tap(find.byIcon(Icons.notifications_none));
      await settle(tester);

      // Assert
      expect(routeDepth(router), 2);
      expect(find.text('Notifications route'), findsOneWidget);
    });

    testWidgets('should not push the notifications route again when tapped '
        'from there', (WidgetTester tester) async {
      // Arrange
      final router = notificationsRouter(
        child: const NotificationIconButton(),
        notificationsChild: const Scaffold(
          body: Center(child: NotificationIconButton()),
        ),
        initialLocation: '/notifications',
      );
      await pumpRoutedApp(tester, router);
      expect(currentLocation(router), '/notifications');
      expect(routeDepth(router), 1);

      // Act
      await tester.tap(find.byIcon(Icons.notifications_none));
      await settle(tester);

      // Assert
      expect(routeDepth(router), 1);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });
  });
}