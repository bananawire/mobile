import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/notifications/domain/model/queries/get_notifications.query.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_screen.dart';

import 'helpers/notifications_widget_harness.dart';

void main() {
  late FakeNotificationsQueryService queryService;
  late NotificationsCubit cubit;

  setUp(() {
    // The screen reads the cubit straight from get_it and the shared
    // `ClairAppBar` does too, so one real cubit is registered for both.
    queryService = FakeNotificationsQueryService();
    cubit = NotificationsCubit(queryService);
    registerNotificationsCubit(cubit);
  });

  /// Pumps the screen inside the localization harness it renders with.
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      notificationsTestApp(child: const NotificationsScreen()),
    );
    await settle(tester);
  }

  group('NotificationsScreen first load', () {
    testWidgets('should read the first page of notifications when it opens',
        (WidgetTester tester) async {
      // Arrange / Act
      await pumpScreen(tester);

      // Assert
      expect(queryService.requestedPages, <int>[0]);
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('should show a progress indicator while the page is loading',
        (WidgetTester tester) async {
      // Arrange: the very first page request never settles on its own.
      final pending = Completer<Either<Failure, NotificationPage>>();
      queryService.pendingResult = pending.future;

      // Act
      await tester.pumpWidget(
        notificationsTestApp(child: const NotificationsScreen()),
      );
      await tester.pump();

      // Assert
      expect(cubit.state.isLoading, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // The first load replaces the whole body with the spinner, so the title
      // and the empty state are not on screen yet.
      expect(find.text('Notifications'), findsNothing);
      expect(find.text('No notifications yet'), findsNothing);

      // The request lands and the spinner gives way to the empty state.
      pending.complete(
        Right<Failure, NotificationPage>(
          buildWidgetPage(const <NotificationLog>[], totalElements: 0),
        ),
      );
      await settle(tester);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('No notifications yet'), findsOneWidget);
    });
  });

  group('NotificationsScreen empty state', () {
    testWidgets('should invite the user to wait when there is nothing to show',
        (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(const <NotificationLog>[], totalElements: 0),
      );

      // Act
      await pumpScreen(tester);

      // Assert
      expect(find.text('No notifications yet'), findsOneWidget);
      expect(
        find.text('We will let you know when something important happens.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('NotificationsScreen list', () {
    testWidgets('should render the title and the message of every loaded '
        'notification', (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[
            buildWidgetNotification(
              id: 'notification-1',
              title: 'High temperature',
              message: 'The kitchen sensor reported 41 degrees',
            ),
            buildWidgetNotification(
              id: 'notification-2',
              title: 'Smoke detected',
              message: 'The hallway is filled with smoke',
            ),
          ],
          totalElements: 2,
        ),
      );

      // Act
      await pumpScreen(tester);

      // Assert
      expect(find.text('High temperature'), findsOneWidget);
      expect(find.text('The kitchen sensor reported 41 degrees'), findsOneWidget);
      expect(find.text('Smoke detected'), findsOneWidget);
      expect(
        find.text('The hallway is filled with smoke'),
        findsOneWidget,
      );
      expect(find.text('No notifications yet'), findsNothing);
    });

    testWidgets('should mark a delivered notification with the active bell '
        'icon', (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[buildWidgetNotification(sent: true)],
          totalElements: 1,
        ),
      );

      // Act
      await pumpScreen(tester);

      // Assert
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('should show the delivery error of an undelivered '
        'notification', (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[
            buildWidgetNotification(
              sent: false,
              errorMessage: 'Push token expired',
            ),
          ],
          totalElements: 1,
        ),
      );

      // Act
      await pumpScreen(tester);

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Push token expired'), findsOneWidget);
    });

    testWidgets('should not show a delivery error chip for a delivered '
        'notification', (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[buildWidgetNotification(sent: true)],
          totalElements: 1,
        ),
      );

      // Act
      await pumpScreen(tester);

      // Assert
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    });

    testWidgets('should label a notification created moments ago as just now',
        (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[
            buildWidgetNotification(createdAt: DateTime.now()),
          ],
          totalElements: 1,
        ),
      );

      // Act
      await pumpScreen(tester);

      // Assert
      expect(find.text('Just now'), findsOneWidget);
    });

    testWidgets('should label a notification of two hours ago with the hours '
        'elapsed', (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[
            buildWidgetNotification(
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            ),
          ],
          totalElements: 1,
        ),
      );

      // Act
      await pumpScreen(tester);

      // Assert
      expect(find.text('2h ago'), findsOneWidget);
      expect(find.text('Just now'), findsNothing);
    });

    testWidgets('should show the calendar day of a notification older than a '
        'week', (WidgetTester tester) async {
      // Arrange
      final createdAt = DateTime.now().subtract(const Duration(days: 30));
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[buildWidgetNotification(createdAt: createdAt)],
          totalElements: 1,
        ),
      );

      // Act
      await pumpScreen(tester);

      // Assert
      final expected = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
      expect(find.text(expected), findsOneWidget);
      expect(find.text('Just now'), findsNothing);
    });
  });

  group('NotificationsScreen error state', () {
    testWidgets('should show the failure message when the page cannot be read',
        (WidgetTester tester) async {
      // Arrange
      queryService.result = const Left<Failure, NotificationPage>(
        Failure('Invalid page size', statusCode: 400),
      );

      // Act
      await pumpScreen(tester);

      // Assert
      expect(find.text('Invalid page size'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('No notifications yet'), findsNothing);
      expect(cubit.state.errorMessage, 'Invalid page size');
    });

    testWidgets('should keep the loaded notifications visible when a refresh '
        'fails', (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[
            buildWidgetNotification(id: 'notification-1', title: 'High temperature'),
          ],
          totalElements: 1,
        ),
      );
      await pumpScreen(tester);
      expect(find.text('High temperature'), findsOneWidget);
      queryService.result = const Left<Failure, NotificationPage>(
        Failure('Backend down', statusCode: 500),
      );

      // Act
      await cubit.loadNotifications(isRefresh: true);
      await settle(tester);

      // Assert: the error does not replace the content that is already shown.
      expect(find.text('High temperature'), findsOneWidget);
      expect(find.text('Backend down'), findsNothing);
    });

    testWidgets('should retry the failed load when the user pulls to refresh',
        (WidgetTester tester) async {
      // Arrange
      queryService.result = const Left<Failure, NotificationPage>(
        Failure('Backend down', statusCode: 500),
      );
      await pumpScreen(tester);
      expect(find.text('Backend down'), findsOneWidget);
      final callsBeforeRetry = queryService.calls;
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[
            buildWidgetNotification(
              id: 'notification-1',
              title: 'High temperature',
            ),
          ],
          totalElements: 1,
        ),
      );

      // Act
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await settle(tester);

      // Assert: the refresh indicator reloads the page and clears the error.
      expect(queryService.calls, callsBeforeRetry + 1);
      expect(find.text('High temperature'), findsOneWidget);
      expect(find.text('Backend down'), findsNothing);
      expect(cubit.state.errorMessage, isNull);
    });
  });

  group('NotificationsScreen unread marker', () {
    testWidgets('should mark the loaded notifications as seen once the screen '
        'shows them', (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[
            buildWidgetNotification(id: 'notification-1'),
            buildWidgetNotification(id: 'notification-2'),
          ],
          totalElements: 2,
        ),
      );

      // Act
      await pumpScreen(tester);

      // Assert: the screen listener calls `markAllAsSeen`, which empties the
      // bell badge.
      expect(cubit.state.lastSeenElements, 2);
      expect(cubit.state.unreadCount, 0);
      expect(find.text('2'), findsNothing);
    });
  });

  group('NotificationsScreen pagination', () {
    testWidgets('should read the next page when the user reaches the bottom of '
        'the list', (WidgetTester tester) async {
      // Arrange: a long first page with a successor keeps the cubit willing to
      // paginate.
      queryService.onQuery = (GetNotificationsQuery query) {
        if (query.page == 0) {
          return Right<Failure, NotificationPage>(
            buildWidgetPage(
              <NotificationLog>[
                for (int index = 0; index < 30; index++)
                  buildWidgetNotification(
                    id: 'notification-$index',
                    title: 'Notification $index',
                  ),
              ],
              totalElements: 60,
              totalPages: 2,
            ),
          );
        }
        return Right<Failure, NotificationPage>(
          buildWidgetPage(
            <NotificationLog>[
              buildWidgetNotification(id: 'page-2', title: 'Second page item'),
            ],
            totalElements: 60,
            totalPages: 2,
            number: 1,
          ),
        );
      };

      // Act
      await pumpScreen(tester);
      expect(queryService.requestedPages, <int>[0]);
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -2000),
      );
      await settle(tester);
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -2000),
      );
      await settle(tester);

      // Assert: the scroll listener asked for the second page.
      expect(queryService.requestedPages, <int>[0, 1]);
    });

    testWidgets('should not read another page once the last page is reached',
        (WidgetTester tester) async {
      // Arrange
      queryService.result = Right<Failure, NotificationPage>(
        buildWidgetPage(
          <NotificationLog>[buildWidgetNotification()],
          totalElements: 1,
          totalPages: 1,
        ),
      );

      // Act
      await pumpScreen(tester);
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -2000),
      );
      await settle(tester);

      // Assert
      expect(queryService.requestedPages, <int>[0]);
      expect(cubit.state.isLastPage, isTrue);
    });
  });
}