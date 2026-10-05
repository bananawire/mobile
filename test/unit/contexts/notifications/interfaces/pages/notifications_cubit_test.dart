import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/notifications/domain/model/queries/get_notifications.query.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/notifications_fixtures.dart';

void main() {
  late MockNotificationsQueryService queryService;
  late NotificationsCubit cubit;
  late List<NotificationsState> emitted;
  late StreamSubscription<NotificationsState> subscription;

  /// The page a first successful load returns; three pages keep the cubit
  /// willing to load more.
  NotificationPage firstPage(List<NotificationLog> logs) =>
      buildNotificationPage(
        logs,
        totalElements: logs.length,
        totalPages: 3,
        size: 20,
        number: 0,
      );

  /// A page on the second zero based index.
  NotificationPage secondPage(
    List<NotificationLog> logs, {
    int number = 1,
    int totalPages = 3,
  }) =>
      buildNotificationPage(
        logs,
        totalElements: logs.length,
        totalPages: totalPages,
        size: 20,
        number: number,
      );

  void stubResult(Either<Failure, NotificationPage> result) {
    when(() => queryService.handleGetNotifications(any()))
        .thenAnswer((_) async => result);
  }

  /// Waits until every state emitted so far reached [emitted], because the
  /// cubit stream delivers its events asynchronously.
  Future<void> flush() => Future<void>.delayed(Duration.zero);

  /// The query the service was asked for last.
  GetNotificationsQuery capturedQuery() {
    final captured = verify(() => queryService.handleGetNotifications(captureAny()))
        .captured;
    return captured.last as GetNotificationsQuery;
  }

  setUpAll(() {
    // `NotificationsCubit` registers a OneSignal foreground listener in its
    // constructor. Reading `OneSignal.Notifications` builds the plugin bridge,
    // which asserts on the binary messenger, so the test binding is
    // initialised here. The plugin is never initialised and no platform method
    // is invoked: the listener is registered but never fired.
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(GetNotificationsQuery());
  });

  setUp(() {
    queryService = MockNotificationsQueryService();
    cubit = NotificationsCubit(queryService);
    emitted = <NotificationsState>[];
    subscription = cubit.stream.listen(emitted.add);
    stubResult(Right<Failure, NotificationPage>(emptyNotificationsPage));
  });

  tearDown(() async {
    await subscription.cancel();
    await cubit.close();
  });

  group('NotificationsCubit initial state', () {
    test('should start idle, empty and already on the last page', () {
      // Arrange / Act
      final state = cubit.state;

      // Assert
      expect(state.isLoading, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.notifications, isEmpty);
      expect(state.totalElements, 0);
      expect(state.totalPages, 1);
      expect(state.currentPage, 0);
      expect(state.pageSize, 20);
      expect(state.isLastPage, isTrue);
      expect(state.lastSeenElements, 0);
      expect(state.unreadCount, 0);
    });

    test('should not read any notification before the first load', () async {
      // Arrange / Act
      await Future<void>.delayed(Duration.zero);

      // Assert
      verifyNever(() => queryService.handleGetNotifications(any()));
      expect(emitted, isEmpty);
    });
  });

  group('NotificationsCubit.loadNotifications', () {
    test('should show the loading flag and then the loaded page on success',
        () async {
      // Arrange
      stubResult(
        Right<Failure, NotificationPage>(
          firstPage(<NotificationLog>[
            buildNotificationLog(id: 'notification-1'),
            buildNotificationLog(id: 'notification-2'),
          ]),
        ),
      );

      // Act
      await cubit.loadNotifications();
      await flush();

      // Assert: one loading transition followed by the loaded page.
      expect(emitted, hasLength(2));
      expect(emitted.first.isLoading, isTrue);
      expect(emitted.first.notifications, isEmpty);
      expect(emitted.last.isLoading, isFalse);
      expect(emitted.last.errorMessage, isNull);
      expect(
        emitted.last.notifications.map((log) => log.id.value).toList(),
        <String>['notification-1', 'notification-2'],
      );
      expect(emitted.last.totalElements, 2);
      expect(emitted.last.totalPages, 3);
      expect(emitted.last.currentPage, 0);
      expect(emitted.last.isLastPage, isFalse);
    });

    test('should request the first page with the configured page size',
        () async {
      // Arrange
      stubResult(Right<Failure, NotificationPage>(emptyNotificationsPage));

      // Act
      await cubit.loadNotifications();
      await flush();

      // Assert
      final query = capturedQuery();
      expect(query.page, 0);
      expect(query.size, cubit.state.pageSize);
      expect(query.size, 20);
    });

    test('should expose the failure message and stop loading on error', () async {
      // Arrange
      stubResult(
        const Left<Failure, NotificationPage>(
          Failure('Invalid page size', statusCode: 400),
        ),
      );

      // Act
      await cubit.loadNotifications();
      await flush();

      // Assert
      expect(emitted, hasLength(2));
      expect(emitted.first.isLoading, isTrue);
      expect(emitted.last.isLoading, isFalse);
      expect(emitted.last.errorMessage, 'Invalid page size');
      expect(emitted.last.notifications, isEmpty);
    });

    test('should keep the already loaded notifications visible when a refresh '
        'fails', () async {
      // Arrange
      stubResult(
        Right<Failure, NotificationPage>(
          firstPage(<NotificationLog>[buildNotificationLog(id: 'notification-1')]),
        ),
      );
      await cubit.loadNotifications();
      await flush();
      emitted.clear();
      stubResult(
        const Left<Failure, NotificationPage>(
          Failure('Backend down', statusCode: 500),
        ),
      );

      // Act
      await cubit.loadNotifications(isRefresh: true);
      await flush();

      // Assert
      expect(emitted.last.errorMessage, 'Backend down');
      expect(emitted.last.notifications, hasLength(1));
      expect(emitted.last.notifications.single.id.value, 'notification-1');
    });

    test('should not hit the query service twice while a request is pending',
        () async {
      // Arrange
      final pending = Completer<Either<Failure, NotificationPage>>();
      when(() => queryService.handleGetNotifications(any()))
          .thenAnswer((_) => pending.future);

      // Act
      final first = cubit.loadNotifications();
      final second = cubit.loadNotifications(isRefresh: true);
      expect(cubit.state.isLoading, isTrue);
      pending.complete(Right<Failure, NotificationPage>(emptyNotificationsPage));
      await Future.wait<void>(<Future<void>>[first, second]);

      // Assert
      verify(() => queryService.handleGetNotifications(any())).called(1);
      expect(cubit.state.isLoading, isFalse);
    });

    test('should report no more pages when the loaded page is the last one',
        () async {
      // Arrange
      stubResult(
        Right<Failure, NotificationPage>(
          buildNotificationPage(
            <NotificationLog>[buildNotificationLog()],
            totalElements: 1,
            totalPages: 1,
            number: 0,
          ),
        ),
      );

      // Act
      await cubit.loadNotifications();
      await flush();

      // Assert
      expect(cubit.state.isLastPage, isTrue);
    });

    test('should report no more pages when the backend returns an empty page',
        () async {
      // Arrange
      stubResult(
        Right<Failure, NotificationPage>(
          buildNotificationPage(
            const <NotificationLog>[],
            totalElements: 40,
            totalPages: 2,
            number: 0,
          ),
        ),
      );

      // Act
      await cubit.loadNotifications();
      await flush();

      // Assert
      expect(cubit.state.isLastPage, isTrue);
      expect(cubit.state.totalElements, 40);
    });

    test('should clear a previous error message when a new load starts',
        () async {
      // Arrange
      stubResult(
        const Left<Failure, NotificationPage>(Failure('Network down')),
      );
      await cubit.loadNotifications();
      await flush();
      expect(cubit.state.errorMessage, 'Network down');
      final pending = Completer<Either<Failure, NotificationPage>>();
      when(() => queryService.handleGetNotifications(any()))
          .thenAnswer((_) => pending.future);

      // Act
      final reload = cubit.loadNotifications();

      // Assert
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.errorMessage, isNull);
      pending.complete(Right<Failure, NotificationPage>(emptyNotificationsPage));
      await reload;
    });

    test('should clear the error message after a successful load', () async {
      // Arrange
      stubResult(
        const Left<Failure, NotificationPage>(Failure('Network down')),
      );
      await cubit.loadNotifications();
      await flush();

      // Act
      stubResult(Right<Failure, NotificationPage>(emptyNotificationsPage));
      await cubit.loadNotifications();
      await flush();

      // Assert
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.isLoading, isFalse);
    });
  });

  group('NotificationsCubit.loadMoreNotifications', () {
    /// Puts the cubit on a page that still has a successor.
    Future<void> seedFirstPage(List<NotificationLog> logs) async {
      stubResult(Right<Failure, NotificationPage>(firstPage(logs)));
      await cubit.loadNotifications();
      await flush();
      expect(cubit.state.isLastPage, isFalse);
      await flush();
      emitted.clear();
    }

    test('should do nothing on a fresh cubit because it already sits on the '
        'last page', () async {
      // Act
      await cubit.loadMoreNotifications();
      await flush();

      // Assert
      verifyNever(() => queryService.handleGetNotifications(any()));
      expect(cubit.state.isLoadingMore, isFalse);
      expect(emitted, isEmpty);
    });

    test('should do nothing when the last page is already reached', () async {
      // Arrange
      await seedFirstPage(<NotificationLog>[buildNotificationLog()]);
      stubResult(
        Right<Failure, NotificationPage>(
          secondPage(
            <NotificationLog>[buildNotificationLog(id: 'second')],
            number: 2,
          ),
        ),
      );
      await cubit.loadMoreNotifications();
      await flush();
      expect(cubit.state.isLastPage, isTrue);
      await flush();
      final before = cubit.state;
      emitted.clear();

      // Act
      await cubit.loadMoreNotifications();
      await flush();

      // Assert: the two calls are the seeded load and the single accepted
      // pagination request.
      verify(() => queryService.handleGetNotifications(any())).called(2);
      expect(cubit.state, same(before));
      expect(emitted, isEmpty);
    });

    test('should append the next page and advance the page index', () async {
      // Arrange
      await seedFirstPage(<NotificationLog>[buildNotificationLog(id: 'first')]);
      stubResult(
        Right<Failure, NotificationPage>(
          secondPage(<NotificationLog>[buildNotificationLog(id: 'second')]),
        ),
      );

      // Act
      await cubit.loadMoreNotifications();
      await flush();

      // Assert
      expect(capturedQuery().page, 1);
      expect(
        cubit.state.notifications.map((log) => log.id.value).toList(),
        <String>['first', 'second'],
      );
      expect(cubit.state.currentPage, 1);
      expect(cubit.state.isLoadingMore, isFalse);
      expect(cubit.state.isLastPage, isFalse);
    });

    test('should show the loading-more flag before appending the next page',
        () async {
      // Arrange
      await seedFirstPage(<NotificationLog>[buildNotificationLog(id: 'first')]);
      final pending = Completer<Either<Failure, NotificationPage>>();
      when(() => queryService.handleGetNotifications(any()))
          .thenAnswer((_) => pending.future);

      // Act
      final loading = cubit.loadMoreNotifications();

      // Assert
      expect(cubit.state.isLoadingMore, isTrue);
      expect(cubit.state.notifications, hasLength(1));
      pending.complete(
        Right<Failure, NotificationPage>(secondPage(<NotificationLog>[])),
      );
      await loading;
      expect(cubit.state.isLoadingMore, isFalse);
    });

    test('should report the last page once the page index catches up with the '
        'page count', () async {
      // Arrange
      await seedFirstPage(<NotificationLog>[buildNotificationLog(id: 'first')]);
      stubResult(
        Right<Failure, NotificationPage>(
          secondPage(
            <NotificationLog>[buildNotificationLog(id: 'second')],
            number: 2,
            totalPages: 3,
          ),
        ),
      );

      // Act
      await cubit.loadMoreNotifications();
      await flush();

      // Assert: number 2 is the last zero based index of a three page answer.
      expect(cubit.state.isLastPage, isTrue);
    });

    test('should report the last page when the next page comes back empty',
        () async {
      // Arrange
      await seedFirstPage(<NotificationLog>[buildNotificationLog(id: 'first')]);
      stubResult(
        Right<Failure, NotificationPage>(secondPage(<NotificationLog>[])),
      );

      // Act
      await cubit.loadMoreNotifications();
      await flush();

      // Assert
      expect(cubit.state.isLastPage, isTrue);
      expect(cubit.state.notifications, hasLength(1));
    });

    test('should keep the already loaded notifications when loading more '
        'fails', () async {
      // Arrange
      await seedFirstPage(<NotificationLog>[buildNotificationLog(id: 'first')]);
      stubResult(
        const Left<Failure, NotificationPage>(Failure('Page unavailable')),
      );

      // Act
      await cubit.loadMoreNotifications();
      await flush();

      // Assert
      expect(cubit.state.errorMessage, 'Page unavailable');
      expect(cubit.state.isLoadingMore, isFalse);
      expect(
        cubit.state.notifications.map((log) => log.id.value).toList(),
        <String>['first'],
      );
      expect(cubit.state.currentPage, 0);
    });

    test('should not hit the query service twice while a page is pending',
        () async {
      // Arrange
      await seedFirstPage(<NotificationLog>[buildNotificationLog(id: 'first')]);
      final pending = Completer<Either<Failure, NotificationPage>>();
      when(() => queryService.handleGetNotifications(any()))
          .thenAnswer((_) => pending.future);

      // Act
      final first = cubit.loadMoreNotifications();
      final second = cubit.loadMoreNotifications();
      expect(cubit.state.isLoadingMore, isTrue);
      pending.complete(
        Right<Failure, NotificationPage>(secondPage(<NotificationLog>[])),
      );
      await Future.wait<void>(<Future<void>>[first, second]);

      // Assert: the two calls are the seeded load and one pagination request,
      // so the second concurrent call never reached the service.
      verify(() => queryService.handleGetNotifications(any())).called(2);
    });

    test('should not read the next page while the first page is still loading',
        () async {
      // Arrange
      final pending = Completer<Either<Failure, NotificationPage>>();
      when(() => queryService.handleGetNotifications(any()))
          .thenAnswer((_) => pending.future);
      final loading = cubit.loadNotifications();

      // Act
      await cubit.loadMoreNotifications();
      await flush();

      // Assert
      verify(() => queryService.handleGetNotifications(any())).called(1);
      pending.complete(Right<Failure, NotificationPage>(emptyNotificationsPage));
      await loading;
    });
  });

  group('NotificationsCubit unread counter', () {
    test('should count every loaded notification as unread', () async {
      // Arrange
      stubResult(
        Right<Failure, NotificationPage>(
          firstPage(<NotificationLog>[
            buildNotificationLog(id: 'notification-1'),
            buildNotificationLog(id: 'notification-2'),
            buildNotificationLog(id: 'notification-3'),
          ]),
        ),
      );

      // Act
      await cubit.loadNotifications();
      await flush();

      // Assert
      expect(cubit.state.lastSeenElements, 0);
      expect(cubit.state.unreadCount, 3);
    });

    test('should drop the unread count to zero once everything is seen',
        () async {
      // Arrange
      stubResult(
        Right<Failure, NotificationPage>(
          firstPage(<NotificationLog>[
            buildNotificationLog(id: 'notification-1'),
            buildNotificationLog(id: 'notification-2'),
          ]),
        ),
      );
      await cubit.loadNotifications();
      await flush();

      // Act
      cubit.markAllAsSeen();

      // Assert
      expect(cubit.state.lastSeenElements, 2);
      expect(cubit.state.unreadCount, 0);
    });

    test('should not emit anything when everything is already seen', () async {
      // Arrange
      stubResult(
        Right<Failure, NotificationPage>(
          firstPage(<NotificationLog>[buildNotificationLog()]),
        ),
      );
      await cubit.loadNotifications();
      await flush();
      cubit.markAllAsSeen();
      await flush();
      emitted.clear();

      // Act
      cubit.markAllAsSeen();

      // Assert
      await Future<void>.delayed(Duration.zero);
      expect(emitted, isEmpty);
    });

    test('should keep counting only the newly arrived notifications after a '
        'refresh', () async {
      // Arrange
      stubResult(
        Right<Failure, NotificationPage>(
          firstPage(<NotificationLog>[buildNotificationLog(id: 'notification-1')]),
        ),
      );
      await cubit.loadNotifications();
      await flush();
      cubit.markAllAsSeen();
      stubResult(
        Right<Failure, NotificationPage>(
          firstPage(<NotificationLog>[
            buildNotificationLog(id: 'notification-1'),
            buildNotificationLog(id: 'notification-2'),
          ]),
        ),
      );

      // Act
      await cubit.loadNotifications(isRefresh: true);

      // Assert: the backend counts from the beginning, so everything above the
      // seen marker counts as unread again.
      expect(cubit.state.totalElements, 2);
      expect(cubit.state.lastSeenElements, 1);
      expect(cubit.state.unreadCount, 1);
    });

    test('should never report a negative unread count', () {
      // Arrange / Act
      const state = NotificationsState(
        totalElements: 2,
        lastSeenElements: 5,
      );

      // Assert
      expect(state.unreadCount, 0);
    });
  });

  group('NotificationsCubit.reset', () {
    test('should return the cubit to its initial state', () async {
      // Arrange
      stubResult(
        Right<Failure, NotificationPage>(
          firstPage(<NotificationLog>[buildNotificationLog(id: 'notification-1')]),
        ),
      );
      await cubit.loadNotifications();
      await flush();
      expect(cubit.state.notifications, isNotEmpty);
      await flush();

      // Act
      cubit.reset();
      await flush();

      // Assert
      expect(cubit.state.notifications, isEmpty);
      expect(cubit.state.totalElements, 0);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.lastSeenElements, 0);
      expect(cubit.state.isLastPage, isTrue);
      expect(emitted.last.notifications, isEmpty);
    });
  });
}