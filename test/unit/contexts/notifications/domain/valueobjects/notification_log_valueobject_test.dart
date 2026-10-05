import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';

import '../../helpers/notifications_fixtures.dart';

void main() {
  group('NotificationLog', () {
    test('should expose every field of a delivered notification', () {
      // Arrange
      final createdAt = DateTime.utc(2024, 5, 1, 10, 30);
      final updatedAt = DateTime.utc(2024, 5, 1, 11);

      // Act
      final log = buildNotificationLog(
        id: 'notification-1',
        userId: 'user-9',
        alertId: 'alert-3',
        title: 'Smoke detected',
        message: 'Kitchen is filled with smoke',
        sent: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Assert
      expect(log.id.value, 'notification-1');
      expect(log.userId, 'user-9');
      expect(log.alertId, 'alert-3');
      expect(log.title, 'Smoke detected');
      expect(log.message, 'Kitchen is filled with smoke');
      expect(log.sent, isTrue);
      expect(log.errorMessage, isNull);
      expect(log.createdAt, createdAt);
      expect(log.updatedAt, updatedAt);
    });

    test('should leave the optional alert reference empty when it is omitted',
        () {
      // Arrange / Act
      final log = buildNotificationLog(alertId: null);

      // Assert
      expect(log.alertId, isNull);
    });

    test('should keep the optional alert reference when it is provided', () {
      // Arrange / Act
      final log = buildNotificationLog(alertId: 'alert-3');

      // Assert
      expect(log.alertId, 'alert-3');
    });

    test('should expose the delivery error of an undelivered notification', () {
      // Arrange / Act
      final log = buildNotificationLog(
        sent: false,
        errorMessage: 'Push token expired',
      );

      // Assert
      expect(log.sent, isFalse);
      expect(log.errorMessage, 'Push token expired');
    });

    test('should default updatedAt to the creation instant when it is omitted',
        () {
      // Arrange
      final createdAt = DateTime.utc(2024, 5, 1, 10, 30);

      // Act
      final log = buildNotificationLog(createdAt: createdAt);

      // Assert
      expect(log.updatedAt, createdAt);
    });

    test('should keep the stored timestamps exactly as supplied without any '
        'timezone coercion', () {
      // Arrange
      final createdAt = DateTime.utc(2024, 5, 1, 10, 30);
      final updatedAt = DateTime.utc(2024, 5, 1, 10, 31);

      // Act
      final log = buildNotificationLog(
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Assert
      expect(log.createdAt.isUtc, isTrue);
      expect(log.createdAt, createdAt);
      expect(log.updatedAt, updatedAt);
      expect(log.createdAt.isBefore(log.updatedAt), isTrue);
    });

    test('should not validate its free text fields because the constructor is '
        'compile time required', () {
      // Arrange / Act: `NotificationLog` is a plain const data holder, so only
      // the type system guards the required fields. Blank text is accepted.
      final log = NotificationLog(
        id: buildNotificationLog().id,
        userId: '',
        title: '',
        message: '',
        sent: false,
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      );

      // Assert
      expect(log.userId, isEmpty);
      expect(log.title, isEmpty);
      expect(log.message, isEmpty);
      expect(log.sent, isFalse);
    });

    test('should compare by identity instead of by value', () {
      // Arrange
      final first = buildNotificationLog(id: 'notification-1');
      final second = buildNotificationLog(id: 'notification-1');

      // Act
      final areEqual = first == second;

      // Assert: two structurally identical logs are different objects, because
      // `NotificationLog` declares no `operator ==`.
      expect(identical(first, second), isFalse);
      expect(areEqual, isFalse);
    });
  });
}