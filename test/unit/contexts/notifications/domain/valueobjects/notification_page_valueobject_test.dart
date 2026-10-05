import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';

import '../../helpers/notifications_fixtures.dart';

void main() {
  group('NotificationPage', () {
    test('should expose the content and the pagination metadata', () {
      // Arrange
      final content = <NotificationLog>[
        buildNotificationLog(id: 'notification-1'),
        buildNotificationLog(id: 'notification-2'),
      ];

      // Act
      final page = buildNotificationPage(
        content,
        totalElements: 42,
        totalPages: 3,
        size: 20,
        number: 1,
      );

      // Assert
      expect(page.content, content);
      expect(page.content, hasLength(2));
      expect(page.totalElements, 42);
      expect(page.totalPages, 3);
      expect(page.size, 20);
      expect(page.number, 1);
    });

    test('should describe an empty first page with zero elements', () {
      // Arrange / Act
      final page = buildNotificationPage(
        const <NotificationLog>[],
        totalElements: 0,
        totalPages: 0,
        size: 20,
        number: 0,
      );

      // Assert
      expect(page.content, isEmpty);
      expect(page.totalElements, 0);
      expect(page.totalPages, 0);
      expect(page.number, 0);
    });

    test('should report more elements than the current page holds when the '
        'backend paginates', () {
      // Arrange
      final page = buildNotificationPage(
        <NotificationLog>[buildNotificationLog(id: 'notification-1')],
        totalElements: 100,
        totalPages: 5,
        size: 20,
        number: 0,
      );

      // Assert
      expect(page.content, hasLength(1));
      expect(page.totalElements, greaterThan(page.content.length));
      expect(page.totalPages, 5);
    });

    test('should accept the lower pagination bound on every numeric field', () {
      // Arrange / Act
      final page = NotificationPage(
        content: const <NotificationLog>[],
        totalElements: 0,
        totalPages: 0,
        size: 0,
        number: 0,
      );

      // Assert
      expect(page.number, 0);
      expect(page.size, 0);
      expect(page.totalPages, 0);
      expect(page.totalElements, 0);
    });

    test('should keep the zero page index of an empty backend answer', () {
      // Arrange / Act
      final page = emptyNotificationsPage;

      // Assert
      expect(page.number, 0);
      expect(page.totalPages, 0);
      expect(page.totalElements, 0);
      expect(page.content, isEmpty);
      expect(page.size, 20);
    });

    test('should not clamp a page index beyond the last page because the read '
        'model is a plain data holder', () {
      // Arrange / Act
      final page = NotificationPage(
        content: <NotificationLog>[buildNotificationLog()],
        totalElements: 5,
        totalPages: 1,
        size: 20,
        number: 7,
      );

      // Assert
      expect(page.number, 7);
    });

    test('should compare by identity instead of by value', () {
      // Arrange
      final first = buildNotificationPage(
        <NotificationLog>[buildNotificationLog(id: 'notification-1')],
        totalElements: 1,
        totalPages: 1,
      );
      final second = buildNotificationPage(
        <NotificationLog>[buildNotificationLog(id: 'notification-1')],
        totalElements: 1,
        totalPages: 1,
      );

      // Act
      final areEqual = first == second;

      // Assert
      expect(identical(first, second), isFalse);
      expect(areEqual, isFalse);
    });
  });
}