import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';
import 'package:mobile/shared/interfaces/widgets/clair_app_bar.dart';
import 'package:mobile/shared/interfaces/widgets/clair_name.dart';

import 'helpers/shared_widget_harness.dart';

void main() {
  group('ClairAppBar title', () {
    late FakeNotificationsCubit notificationsCubit;
    late GoRouter router;

    setUp(() {
      notificationsCubit = FakeNotificationsCubit();
      registerSharedNotificationsCubit(notificationsCubit);
      router = sharedFlatRouter(child: const ClairAppBar());
      addTearDown(router.dispose);
    });

    testWidgets('should render the Clair brand name as the title', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSharedRouter(tester, router);

      // Act
      final title = find.byType(ClairName);

      // Assert
      expect(title, findsOneWidget);
    });

    testWidgets('should reserve the standard toolbar height', (
      WidgetTester tester,
    ) async {
      // Arrange
      const appBar = ClairAppBar();

      // Act
      await pumpSharedRouter(tester, router);

      // Assert
      expect(appBar.preferredSize, const Size.fromHeight(kToolbarHeight));
      expect(tester.getSize(find.byType(AppBar)).height, kToolbarHeight);
    });

    testWidgets('should offer the bell and the settings actions', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSharedRouter(tester, router);

      // Act
      final bell = find.byIcon(Icons.notifications_none);
      final settings = find.byIcon(Icons.settings);

      // Assert
      expect(bell, findsOneWidget);
      expect(settings, findsOneWidget);
    });

    testWidgets(
      'should expose no semantic label on its icon actions, because they carry no tooltip',
      (WidgetTester tester) async {
        // Arrange
        final handle = tester.ensureSemantics();

        // Act
        await pumpSharedRouter(tester, router);

        // Assert: documented current behaviour. A screen reader announces both
        // actions as bare buttons, so the app bar does not meet
        // `labeledTapTargetGuideline`. A tooltip on either action would fix it.
        final bell = tester.getSemantics(find.byIcon(Icons.notifications_none));
        final settings = tester.getSemantics(find.byIcon(Icons.settings));
        expect(bell.label, isEmpty);
        expect(settings.label, isEmpty);
        handle.dispose();
      },
    );

    testWidgets('should ask the notifications cubit to load on mount', (
      WidgetTester tester,
    ) async {
      // Arrange
      final loadingRouter = sharedFlatRouter(child: const ClairAppBar());
      addTearDown(loadingRouter.dispose);

      // Act
      await pumpSharedRouter(tester, loadingRouter);

      // Assert
      expect(notificationsCubit.loadNotificationsCalls, 1);
      expect(notificationsCubit.refreshFlags, <bool>[false]);
    });
  });

  group('ClairAppBar leading', () {
    late FakeNotificationsCubit notificationsCubit;

    setUp(() {
      notificationsCubit = FakeNotificationsCubit();
      registerSharedNotificationsCubit(notificationsCubit);
    });

    testWidgets('should hide the back button by default', (
      WidgetTester tester,
    ) async {
      // Arrange
      final router = sharedFlatRouter(child: const ClairAppBar());
      addTearDown(router.dispose);

      // Act
      await pumpSharedRouter(tester, router);

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('should show the back button when showBack is true', (
      WidgetTester tester,
    ) async {
      // Arrange
      final router = sharedFlatRouter(child: const ClairAppBar(showBack: true));
      addTearDown(router.dispose);

      // Act
      await pumpSharedRouter(tester, router);

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets(
      'should pop the previous route when back is tapped with history',
      (WidgetTester tester) async {
        // Arrange: push a page that hosts the app bar over a plain page, so the
        // router can pop and exactly one back button is on screen.
        final router = sharedPushedAppBarRouter(
          child: const ClairAppBar(showBack: true),
        );
        addTearDown(router.dispose);
        await pumpSharedRouter(tester, router);
        router.push('/second');
        await settleNavigation(tester);
        expect(find.text('Second body'), findsOneWidget);

        // Act
        await tester.tap(find.byIcon(Icons.arrow_back));
        await settleNavigation(tester);

        // Assert
        expect(find.text('Home body'), findsOneWidget);
        expect(routeDepth(router), 1);
      },
    );

    testWidgets(
      'should route to the fallback location when back is tapped without history',
      (WidgetTester tester) async {
        // Arrange: `/home` is the bottom of the stack, so nothing can be popped.
        final router = sharedFlatRouter(
          child: const ClairAppBar(
            showBack: true,
            backFallbackLocation: '/second',
          ),
        );
        addTearDown(router.dispose);
        await pumpSharedRouter(tester, router);
        expect(currentLocation(router), '/home');

        // Act
        await tester.tap(find.byIcon(Icons.arrow_back));
        await settleNavigation(tester);

        // Assert
        expect(currentLocation(router), '/second');
        expect(find.text('Second body'), findsOneWidget);
      },
    );

    testWidgets(
      'should stay put when back is tapped without history or fallback',
      (WidgetTester tester) async {
        // Arrange: no fallback location was configured, so there is nothing to do.
        final router = sharedFlatRouter(
          child: const ClairAppBar(showBack: true),
        );
        addTearDown(router.dispose);
        await pumpSharedRouter(tester, router);

        // Act
        await tester.tap(find.byIcon(Icons.arrow_back));
        await settleNavigation(tester);

        // Assert
        expect(currentLocation(router), '/home');
        expect(find.text('Home body'), findsOneWidget);
      },
    );
  });

  group('ClairAppBar settings action', () {
    late FakeNotificationsCubit notificationsCubit;

    setUp(() {
      notificationsCubit = FakeNotificationsCubit();
      registerSharedNotificationsCubit(notificationsCubit);
    });

    testWidgets(
      'should push the settings route when the settings action is tapped',
      (WidgetTester tester) async {
        // Arrange
        final router = sharedFlatRouter(child: const ClairAppBar());
        addTearDown(router.dispose);
        await pumpSharedRouter(tester, router);

        // Act
        await tester.tap(find.byIcon(Icons.settings));
        await settleNavigation(tester);

        // Assert
        expect(find.text('Settings page'), findsOneWidget);
        expect(routeDepth(router), 2);
      },
    );

    testWidgets(
      'should not push settings twice when already on the settings route',
      (WidgetTester tester) async {
        // Arrange: the app bar only lives on `/settings`, so the second tap has
        // a single unambiguous settings action to hit.
        final router = sharedSettingsAppBarRouter(child: const ClairAppBar());
        addTearDown(router.dispose);
        await pumpSharedRouter(tester, router);
        router.push('/settings');
        await settleNavigation(tester);
        expect(find.text('Settings page'), findsOneWidget);
        expect(routeDepth(router), 2);

        // Act
        await tester.tap(find.byIcon(Icons.settings));
        await settleNavigation(tester);

        // Assert: the app bar guards on the current location.
        expect(routeDepth(router), 2);
        expect(find.text('Settings page'), findsOneWidget);
      },
    );
  });

  group('ClairAppBar unread badge', () {
    late FakeNotificationsCubit notificationsCubit;
    late GoRouter router;

    setUp(() {
      notificationsCubit = FakeNotificationsCubit();
      registerSharedNotificationsCubit(notificationsCubit);
      router = sharedFlatRouter(child: const ClairAppBar());
      addTearDown(router.dispose);
    });

    testWidgets('should show no badge when there are no notifications', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSharedRouter(tester, router);

      // Act
      final badge = find.text('0');

      // Assert
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      expect(badge, findsNothing);
    });

    testWidgets('should show the unread count on the bell badge', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSharedRouter(tester, router);

      // Act
      notificationsCubit.emit(
        const NotificationsState(totalElements: 3, lastSeenElements: 0),
      );
      await settle(tester);

      // Assert
      expect(notificationsCubit.state.unreadCount, 3);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should hide the badge once every notification has been seen', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSharedRouter(tester, router);
      notificationsCubit.emit(
        const NotificationsState(totalElements: 3, lastSeenElements: 0),
      );
      await settle(tester);
      expect(find.text('3'), findsOneWidget);

      // Act
      notificationsCubit.markAllAsSeen();
      await settle(tester);

      // Assert
      expect(notificationsCubit.state.unreadCount, 0);
      expect(find.text('3'), findsNothing);
    });

    testWidgets('should update the badge to the new unread count', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSharedRouter(tester, router);
      notificationsCubit.emit(
        const NotificationsState(totalElements: 5, lastSeenElements: 0),
      );
      await settle(tester);
      expect(find.text('5'), findsOneWidget);

      // Act
      notificationsCubit.emit(
        const NotificationsState(totalElements: 5, lastSeenElements: 2),
      );
      await settle(tester);

      // Assert
      expect(find.text('5'), findsNothing);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should push the notifications route when the bell is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSharedRouter(tester, router);

      // Act
      await tester.tap(find.byIcon(Icons.notifications_none));
      await settleNavigation(tester);

      // Assert
      expect(find.text('Notifications page'), findsOneWidget);
      expect(routeDepth(router), 2);
    });
  });
}
