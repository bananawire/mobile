import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';

import '../../helpers/notifications_fixtures.dart';

void main() {
  group('NotificationsState defaults', () {
    test('should describe an idle screen that already sits on the last page',
        () {
      // Arrange / Act
      const state = NotificationsState();

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
  });

  group('NotificationsState.copyWith', () {
    test('should keep every field that is not overridden', () {
      // Arrange
      final original = NotificationsState(
        isLoading: true,
        isLoadingMore: true,
        errorMessage: 'Backend down',
        notifications: <NotificationLog>[buildNotificationLog()],
        totalElements: 7,
        totalPages: 3,
        currentPage: 1,
        pageSize: 50,
        isLastPage: false,
        lastSeenElements: 4,
      );

      // Act
      final copy = original.copyWith(isLoading: false);

      // Assert
      expect(copy.isLoading, isFalse);
      expect(copy.isLoadingMore, isTrue);
      expect(copy.errorMessage, 'Backend down');
      expect(copy.notifications, same(original.notifications));
      expect(copy.totalElements, 7);
      expect(copy.totalPages, 3);
      expect(copy.currentPage, 1);
      expect(copy.pageSize, 50);
      expect(copy.isLastPage, isFalse);
      expect(copy.lastSeenElements, 4);
    });

    test('should clear the error message when null is passed explicitly', () {
      // Arrange
      final original = const NotificationsState(errorMessage: 'Backend down');

      // Act
      final copy = original.copyWith(errorMessage: null);

      // Assert
      expect(copy.errorMessage, isNull);
    });

    test('should keep the error message when the field is left out', () {
      // Arrange
      final original = const NotificationsState(errorMessage: 'Backend down');

      // Act
      final copy = original.copyWith(isLoading: true);

      // Assert: only an explicit null clears the message.
      expect(copy.errorMessage, 'Backend down');
    });

    test('should replace the notification list with the given one', () {
      // Arrange
      final original = NotificationsState(
        notifications: <NotificationLog>[buildNotificationLog(id: 'first')],
      );
      final replacement = <NotificationLog>[
        buildNotificationLog(id: 'first'),
        buildNotificationLog(id: 'second'),
      ];

      // Act
      final copy = original.copyWith(notifications: replacement);

      // Assert
      expect(copy.notifications, same(replacement));
      expect(copy.notifications, hasLength(2));
    });
  });

  group('NotificationsState.unreadCount', () {
    test('should count the notifications above the seen marker', () {
      // Arrange / Act
      const state = NotificationsState(
        totalElements: 10,
        lastSeenElements: 4,
      );

      // Assert
      expect(state.unreadCount, 6);
    });

    test('should count every notification before the user sees any', () {
      // Arrange / Act
      const state = NotificationsState(totalElements: 3);

      // Assert
      expect(state.unreadCount, 3);
    });

    test('should report zero once everything above the marker is seen', () {
      // Arrange / Act
      const state = NotificationsState(
        totalElements: 5,
        lastSeenElements: 5,
      );

      // Assert
      expect(state.unreadCount, 0);
    });

    test('should clamp a negative difference to zero when the backend total '
        'drops', () {
      // Arrange / Act
      const state = NotificationsState(
        totalElements: 2,
        lastSeenElements: 8,
      );

      // Assert
      expect(state.unreadCount, 0);
    });
  });
}