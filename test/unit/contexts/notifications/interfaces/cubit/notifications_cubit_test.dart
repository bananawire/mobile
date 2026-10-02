import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/notifications/domain/model/queries/get_notifications.query.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_id.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';
import 'package:mobile/notifications/domain/services/notifications.query-service.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsQueryService extends Mock implements NotificationsQueryService {}

NotificationLog _createFakeLog({required String id, required String title, bool sent = true}) {
  return NotificationLog(
    id: NotificationId(id),
    userId: 'usr-123',
    alertId: 'alt-456',
    title: title,
    message: 'Test notification message',
    sent: sent,
    createdAt: DateTime.utc(2026, 10, 2, 10, 0),
    updatedAt: DateTime.utc(2026, 10, 2, 10, 0),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(GetNotificationsQuery(page: 0, size: 20));
  });

  late MockNotificationsQueryService mockQueryService;

  setUp(() {
    mockQueryService = MockNotificationsQueryService();
  });

  group('NotificationsCubit - initial state', () {
    test('should have initial state with default values and unreadCount equal to 0', () {
      // Arrange & Act
      final cubit = NotificationsCubit(mockQueryService);

      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isLoadingMore, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.notifications, isEmpty);
      expect(cubit.state.totalElements, equals(0));
      expect(cubit.state.totalPages, equals(1));
      expect(cubit.state.currentPage, equals(0));
      expect(cubit.state.pageSize, equals(20));
      expect(cubit.state.isLastPage, isTrue);
      expect(cubit.state.lastSeenElements, equals(0));
      expect(cubit.state.unreadCount, equals(0));
    });
  });

  group('NotificationsCubit - loadNotifications', () {
    final sampleItem1 = _createFakeLog(id: 'notif-1', title: 'High CO2');
    final samplePage1 = NotificationPage(
      content: [sampleItem1],
      totalElements: 25,
      totalPages: 2,
      size: 20,
      number: 0,
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'should emit loading then success state when loadNotifications succeeds',
      build: () {
        when(() => mockQueryService.handleGetNotifications(any()))
            .thenAnswer((_) async => Right(samplePage1));
        return NotificationsCubit(mockQueryService);
      },
      act: (cubit) => cubit.loadNotifications(),
      expect: () => [
        isA<NotificationsState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<NotificationsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.notifications.length, 'notifications length', 1)
            .having((s) => s.totalElements, 'totalElements', 25)
            .having((s) => s.totalPages, 'totalPages', 2)
            .having((s) => s.currentPage, 'currentPage', 0)
            .having((s) => s.isLastPage, 'isLastPage', isFalse)
            .having((s) => s.unreadCount, 'unreadCount', 25),
      ],
      verify: (_) {
        verify(() => mockQueryService.handleGetNotifications(
          any(that: isA<GetNotificationsQuery>().having((q) => q.page, 'page', 0)),
        )).called(1);
      },
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'should mark isLastPage as true when totalPages is 1',
      build: () {
        final singlePage = NotificationPage(
          content: [sampleItem1],
          totalElements: 1,
          totalPages: 1,
          size: 20,
          number: 0,
        );
        when(() => mockQueryService.handleGetNotifications(any()))
            .thenAnswer((_) async => Right(singlePage));
        return NotificationsCubit(mockQueryService);
      },
      act: (cubit) => cubit.loadNotifications(),
      expect: () => [
        isA<NotificationsState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<NotificationsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isLastPage, 'isLastPage', isTrue),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'should emit loading then error state when handleGetNotifications returns Failure',
      build: () {
        when(() => mockQueryService.handleGetNotifications(any()))
            .thenAnswer((_) async => const Left(Failure('Failed to fetch notifications')));
        return NotificationsCubit(mockQueryService);
      },
      act: (cubit) => cubit.loadNotifications(),
      expect: () => [
        isA<NotificationsState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<NotificationsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', 'Failed to fetch notifications'),
      ],
    );

    test('should ignore loadNotifications call when already loading', () async {
      // Arrange
      when(() => mockQueryService.handleGetNotifications(any()))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return Right(samplePage1);
          });
      final cubit = NotificationsCubit(mockQueryService);

      // Act
      final f1 = cubit.loadNotifications();
      final f2 = cubit.loadNotifications();
      await Future.wait([f1, f2]);

      // Assert
      verify(() => mockQueryService.handleGetNotifications(any())).called(1);
    });
  });

  group('NotificationsCubit - pagination with loadMoreNotifications', () {
    final item1 = _createFakeLog(id: 'n-1', title: 'First item');
    final item2 = _createFakeLog(id: 'n-2', title: 'Second item');

    final page2 = NotificationPage(
      content: [item2],
      totalElements: 25,
      totalPages: 2,
      size: 20,
      number: 1,
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'should append new notifications and increment page when loadMoreNotifications succeeds',
      build: () {
        when(() => mockQueryService.handleGetNotifications(any()))
            .thenAnswer((_) async => Right(page2));
        return NotificationsCubit(mockQueryService);
      },
      seed: () => NotificationsState(
        notifications: [item1],
        currentPage: 0,
        totalPages: 2,
        totalElements: 25,
        isLastPage: false,
      ),
      act: (cubit) => cubit.loadMoreNotifications(),
      expect: () => [
        isA<NotificationsState>().having((s) => s.isLoadingMore, 'isLoadingMore', isTrue),
        isA<NotificationsState>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', isFalse)
            .having((s) => s.notifications.length, 'notifications length', 2)
            .having((s) => s.notifications[0].id.value, 'first id', 'n-1')
            .having((s) => s.notifications[1].id.value, 'second id', 'n-2')
            .having((s) => s.currentPage, 'currentPage', 1)
            .having((s) => s.isLastPage, 'isLastPage', isTrue),
      ],
      verify: (_) {
        verify(() => mockQueryService.handleGetNotifications(
          any(that: isA<GetNotificationsQuery>().having((q) => q.page, 'page', 1)),
        )).called(1);
      },
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'should not call service when isLastPage is true',
      build: () => NotificationsCubit(mockQueryService),
      seed: () => const NotificationsState(
        isLastPage: true,
        currentPage: 0,
      ),
      act: (cubit) => cubit.loadMoreNotifications(),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockQueryService.handleGetNotifications(any()));
      },
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'should not call service when isLoadingMore is already true',
      build: () => NotificationsCubit(mockQueryService),
      seed: () => const NotificationsState(
        isLoadingMore: true,
        isLastPage: false,
      ),
      act: (cubit) => cubit.loadMoreNotifications(),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockQueryService.handleGetNotifications(any()));
      },
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'should emit error when loadMoreNotifications fails',
      build: () {
        when(() => mockQueryService.handleGetNotifications(any()))
            .thenAnswer((_) async => const Left(Failure('Failed to load page 2')));
        return NotificationsCubit(mockQueryService);
      },
      seed: () => NotificationsState(
        notifications: [item1],
        currentPage: 0,
        totalPages: 2,
        totalElements: 25,
        isLastPage: false,
      ),
      act: (cubit) => cubit.loadMoreNotifications(),
      expect: () => [
        isA<NotificationsState>().having((s) => s.isLoadingMore, 'isLoadingMore', isTrue),
        isA<NotificationsState>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', 'Failed to load page 2')
            .having((s) => s.notifications.length, 'preserved notifications', 1),
      ],
    );
  });

  group('NotificationsCubit - refresh', () {
    final refreshedItem = _createFakeLog(id: 'refreshed-1', title: 'New Alert');
    final refreshedPage = NotificationPage(
      content: [refreshedItem],
      totalElements: 1,
      totalPages: 1,
      size: 20,
      number: 0,
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'should replace existing list when loadNotifications is called with isRefresh: true',
      build: () {
        when(() => mockQueryService.handleGetNotifications(any()))
            .thenAnswer((_) async => Right(refreshedPage));
        return NotificationsCubit(mockQueryService);
      },
      seed: () => NotificationsState(
        notifications: [_createFakeLog(id: 'old-1', title: 'Old Alert')],
        currentPage: 1,
        totalElements: 10,
      ),
      act: (cubit) => cubit.loadNotifications(isRefresh: true),
      expect: () => [
        isA<NotificationsState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<NotificationsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.notifications.length, 'notifications length', 1)
            .having((s) => s.notifications.first.id.value, 'id', 'refreshed-1')
            .having((s) => s.currentPage, 'currentPage', 0)
            .having((s) => s.totalElements, 'totalElements', 1),
      ],
    );
  });

  group('NotificationsCubit - markAllAsSeen and reset', () {
    test('should update lastSeenElements to totalElements and reduce unreadCount to 0', () {
      // Arrange
      final cubit = NotificationsCubit(mockQueryService);
      cubit.emit(const NotificationsState(
        totalElements: 8,
        lastSeenElements: 2,
      ));
      expect(cubit.state.unreadCount, equals(6));

      // Act
      cubit.markAllAsSeen();

      // Assert
      expect(cubit.state.lastSeenElements, equals(8));
      expect(cubit.state.unreadCount, equals(0));
    });

    test('should do nothing when lastSeenElements is already equal to totalElements', () {
      // Arrange
      final cubit = NotificationsCubit(mockQueryService);
      cubit.emit(const NotificationsState(
        totalElements: 5,
        lastSeenElements: 5,
      ));

      // Act
      cubit.markAllAsSeen();

      // Assert
      expect(cubit.state.lastSeenElements, equals(5));
      expect(cubit.state.unreadCount, equals(0));
    });

    test('should reset state back to default NotificationsState when reset() is called', () {
      // Arrange
      final cubit = NotificationsCubit(mockQueryService);
      cubit.emit(NotificationsState(
        notifications: [_createFakeLog(id: 'n-1', title: 'T')],
        totalElements: 10,
        currentPage: 2,
        errorMessage: 'Something broke',
      ));

      // Act
      cubit.reset();

      // Assert
      expect(cubit.state.notifications, isEmpty);
      expect(cubit.state.totalElements, equals(0));
      expect(cubit.state.currentPage, equals(0));
      expect(cubit.state.errorMessage, isNull);
    });
  });
}
