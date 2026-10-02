import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_id.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/test_widget_harness.dart';

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

NotificationLog _sampleLog({
  required String id,
  required String title,
  required String message,
  bool sent = true,
  String? errorMessage,
}) {
  return NotificationLog(
    id: NotificationId(id),
    userId: 'user-001',
    alertId: 'alert-001',
    title: title,
    message: message,
    sent: sent,
    errorMessage: errorMessage,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
  );
}

void main() {
  late MockNotificationsCubit mockCubit;

  setUp(() {
    mockCubit = MockNotificationsCubit();
    when(() => mockCubit.state).thenReturn(const NotificationsState());
    when(() => mockCubit.loadNotifications(isRefresh: any(named: 'isRefresh')))
        .thenAnswer((_) async {});
    when(() => mockCubit.loadMoreNotifications()).thenAnswer((_) async {});
    when(() => mockCubit.markAllAsSeen()).thenReturn(null);

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

  group('NotificationsScreen', () {
    testWidgets('should show loading indicator when state is loading and list is empty', (tester) async {
      // Arrange
      when(() => mockCubit.state).thenReturn(
        const NotificationsState(isLoading: true, notifications: []),
      );

      // Act
      await tester.pumpWidget(
        buildTestableWidget(const NotificationsScreen()),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render empty state when not loading and list is empty', (tester) async {
      // Arrange
      when(() => mockCubit.state).thenReturn(
        const NotificationsState(isLoading: false, notifications: []),
      );

      // Act
      await tester.pumpWidget(
        buildTestableWidget(const NotificationsScreen()),
      );
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should render error state when errorMessage is present and list is empty', (tester) async {
      // Arrange
      when(() => mockCubit.state).thenReturn(
        const NotificationsState(
          isLoading: false,
          errorMessage: 'Unable to reach backend service',
          notifications: [],
        ),
      );

      // Act
      await tester.pumpWidget(
        buildTestableWidget(const NotificationsScreen()),
      );
      await tester.pump();

      // Assert
      expect(find.text('Unable to reach backend service'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should render notifications list when notifications are present', (tester) async {
      // Arrange
      final notifications = [
        _sampleLog(
          id: 'n-1',
          title: 'High CO2 Alert',
          message: 'Living room CO2 exceeded 1000 ppm',
          sent: true,
        ),
        _sampleLog(
          id: 'n-2',
          title: 'Connection Lost',
          message: 'Kitchen sensor went offline',
          sent: false,
          errorMessage: 'Device unreachable',
        ),
      ];

      when(() => mockCubit.state).thenReturn(
        NotificationsState(
          isLoading: false,
          notifications: notifications,
          totalElements: 2,
          totalPages: 1,
          isLastPage: true,
        ),
      );

      // Act
      await tester.pumpWidget(
        buildTestableWidget(const NotificationsScreen()),
      );
      await tester.pump();

      // Assert
      expect(find.text('High CO2 Alert'), findsOneWidget);
      expect(find.text('Living room CO2 exceeded 1000 ppm'), findsOneWidget);
      expect(find.text('Connection Lost'), findsOneWidget);
      expect(find.text('Kitchen sensor went offline'), findsOneWidget);
      expect(find.text('Device unreachable'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    });

    testWidgets('should call markAllAsSeen when loaded and lastSeenElements differs from totalElements', (tester) async {
      // Arrange
      final notifications = [
        _sampleLog(
          id: 'n-1',
          title: 'Notification 1',
          message: 'Message 1',
        ),
      ];

      whenListen(
        mockCubit,
        Stream.fromIterable([
          NotificationsState(
            isLoading: false,
            notifications: notifications,
            totalElements: 1,
            lastSeenElements: 0,
          ),
        ]),
        initialState: const NotificationsState(isLoading: true),
      );

      // Act
      await tester.pumpWidget(
        buildTestableWidget(const NotificationsScreen()),
      );
      await tester.pump();

      // Assert
      verify(() => mockCubit.markAllAsSeen()).called(1);
    });
  });
}
