import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';
import 'package:mobile/notifications/interfaces/widgets/notification_icon_button.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/test_widget_harness.dart';

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

void main() {
  late MockNotificationsCubit mockCubit;

  setUp(() {
    mockCubit = MockNotificationsCubit();
    when(() => mockCubit.state).thenReturn(const NotificationsState());
    when(
      () => mockCubit.loadNotifications(isRefresh: any(named: 'isRefresh')),
    ).thenAnswer((_) async {});

    if (getIt.isRegistered<NotificationsCubit>()) {
      getIt.unregister<NotificationsCubit>();
    }
    getIt.registerSingleton<NotificationsCubit>(mockCubit);
  });

  tearDown(() {
    if (getIt.isRegistered<NotificationsCubit>()) {
      getIt.unregister<NotificationsCubit>();
    }
  });

  group('NotificationIconButton', () {
    testWidgets('should render icon button with notifications_none icon', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestableWidget(const NotificationIconButton()),
      );
      await tester.pump();

      // Assert
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets(
      'should trigger loadNotifications on post frame callback when mounted',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestableWidget(const NotificationIconButton()),
        );
        await tester.pump();

        // Assert
        verify(() => mockCubit.loadNotifications()).called(1);
      },
    );

    testWidgets('should not display badge counter when unread count is 0', (
      tester,
    ) async {
      // Arrange
      when(() => mockCubit.state).thenReturn(
        const NotificationsState(totalElements: 5, lastSeenElements: 5),
      );

      // Act
      await tester.pumpWidget(
        buildTestableWidget(const NotificationIconButton()),
      );
      await tester.pump();

      // Assert
      final badgeFinder = find.byType(Badge);
      expect(badgeFinder, findsOneWidget);

      final badge = tester.widget<Badge>(badgeFinder);
      expect(badge.isLabelVisible, isFalse);
      expect(find.text('0'), findsNothing);
    });

    testWidgets(
      'should display badge counter when unread count is greater than 0',
      (tester) async {
        // Arrange
        when(() => mockCubit.state).thenReturn(
          const NotificationsState(totalElements: 7, lastSeenElements: 3),
        );

        // Act
        await tester.pumpWidget(
          buildTestableWidget(const NotificationIconButton()),
        );
        await tester.pump();

        // Assert
        final badgeFinder = find.byType(Badge);
        expect(badgeFinder, findsOneWidget);

        final badge = tester.widget<Badge>(badgeFinder);
        expect(badge.isLabelVisible, isTrue);
        expect(find.text('4'), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to /notifications when tapped from a different route',
      (tester) async {
        // Arrange
        var navigatedToNotifications = false;

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) =>
                  const Scaffold(body: NotificationIconButton()),
            ),
            GoRoute(
              path: '/notifications',
              builder: (context, state) {
                navigatedToNotifications = true;
                return const Scaffold(body: Text('Notifications Page'));
              },
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert
        expect(navigatedToNotifications, isTrue);
        expect(find.text('Notifications Page'), findsOneWidget);
      },
    );

    testWidgets(
      'should not push route when tapped and current location is already /notifications',
      (tester) async {
        // Arrange
        var pushAttempts = 0;

        final router = GoRouter(
          initialLocation: '/notifications',
          routes: [
            GoRoute(
              path: '/notifications',
              builder: (context, state) {
                pushAttempts++;
                return const Scaffold(body: NotificationIconButton());
              },
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        );
        await tester.pumpAndSettle();

        // Reset counter after initial build
        pushAttempts = 0;

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert
        expect(pushAttempts, equals(0));
      },
    );
  });
}
