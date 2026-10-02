import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_id.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';

void main() {
  group('NotificationId ValueObject', () {
    test(
      'should create NotificationId when valid non-empty string is provided',
      () {
        // Arrange
        const rawId = 'notif-12345';

        // Act
        final id = NotificationId(rawId);

        // Assert
        expect(id.value, equals(rawId));
      },
    );

    test('should throw ArgumentError when value is empty', () {
      // Arrange, Act & Assert
      expect(
        () => NotificationId(''),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Notification ID is required'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when value is whitespace only', () {
      // Arrange, Act & Assert
      expect(
        () => NotificationId('   \t\n  '),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Notification ID is required'),
          ),
        ),
      );
    });

    test('should support value equality when values are identical', () {
      // Arrange
      final id1 = NotificationId('id-abc');
      final id2 = NotificationId('id-abc');

      // Act & Assert
      expect(id1, equals(id2));
      expect(id1.hashCode, equals(id2.hashCode));
    });

    test('should not be equal when values are different', () {
      // Arrange
      final id1 = NotificationId('id-abc');
      final id2 = NotificationId('id-def');

      // Act & Assert
      expect(id1, isNot(equals(id2)));
    });

    test('should return value string when calling toString()', () {
      // Arrange
      final id = NotificationId('notif-999');

      // Act
      final result = id.toString();

      // Assert
      expect(result, equals('notif-999'));
    });
  });

  group('NotificationLog ValueObject', () {
    test('should construct NotificationLog when all fields are provided', () {
      // Arrange
      final id = NotificationId('notif-001');
      const userId = 'usr-001';
      const alertId = 'alert-999';
      const title = 'High CO2 Alert';
      const message = 'CO2 level has exceeded 1000 ppm';
      const sent = true;
      const errorMessage = null;
      final createdAt = DateTime.utc(2026, 10, 1, 10, 0);
      final updatedAt = DateTime.utc(2026, 10, 1, 10, 5);

      // Act
      final notification = NotificationLog(
        id: id,
        userId: userId,
        alertId: alertId,
        title: title,
        message: message,
        sent: sent,
        errorMessage: errorMessage,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Assert
      expect(notification.id, equals(id));
      expect(notification.userId, equals(userId));
      expect(notification.alertId, equals(alertId));
      expect(notification.title, equals(title));
      expect(notification.message, equals(message));
      expect(notification.sent, isTrue);
      expect(notification.errorMessage, isNull);
      expect(notification.createdAt, equals(createdAt));
      expect(notification.updatedAt, equals(updatedAt));
    });

    test('should allow null optional fields when omitted', () {
      // Arrange
      final id = NotificationId('notif-002');
      final now = DateTime.now();

      // Act
      final notification = NotificationLog(
        id: id,
        userId: 'usr-002',
        title: 'System Notice',
        message: 'Maintenance scheduled',
        sent: false,
        errorMessage: 'Push token expired',
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(notification.alertId, isNull);
      expect(notification.errorMessage, equals('Push token expired'));
      expect(notification.sent, isFalse);
    });
  });

  group('NotificationPage ValueObject', () {
    test(
      'should construct NotificationPage when all properties are provided',
      () {
        // Arrange
        final item = NotificationLog(
          id: NotificationId('notif-001'),
          userId: 'usr-001',
          title: 'Title',
          message: 'Message',
          sent: true,
          createdAt: DateTime.utc(2026, 10, 1),
          updatedAt: DateTime.utc(2026, 10, 1),
        );

        // Act
        final page = NotificationPage(
          content: [item],
          totalElements: 1,
          totalPages: 1,
          size: 20,
          number: 0,
        );

        // Assert
        expect(page.content.length, equals(1));
        expect(page.content.first.id.value, equals('notif-001'));
        expect(page.totalElements, equals(1));
        expect(page.totalPages, equals(1));
        expect(page.size, equals(20));
        expect(page.number, equals(0));
      },
    );

    test('should hold empty content list when no items are present', () {
      // Arrange & Act
      const page = NotificationPage(
        content: [],
        totalElements: 0,
        totalPages: 0,
        size: 20,
        number: 0,
      );

      // Assert
      expect(page.content, isEmpty);
      expect(page.totalElements, equals(0));
      expect(page.totalPages, equals(0));
    });
  });
}
