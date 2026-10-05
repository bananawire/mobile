import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';
import 'package:mobile/notifications/interfaces/rest/transform/notifications_transform.dart';

import '../../../helpers/notifications_fixtures.dart';

void main() {
  group('notificationResponseResourceToDomain', () {
    test('should map every wire field of a delivered notification onto the '
        'domain model', () {
      // Arrange
      final resource = notificationResourceFromJson(notificationJson);

      // Act
      final log = notificationResponseResourceToDomain(resource);

      // Assert
      expect(log.id.value, 'notification-1');
      expect(log.userId, 'user-1');
      expect(log.alertId, 'alert-1');
      expect(log.title, 'High temperature');
      expect(log.message, 'The kitchen sensor reported 41 degrees');
      expect(log.sent, isTrue);
      expect(log.errorMessage, isNull);
      expect(log.createdAt, DateTime.utc(2024, 5, 1, 10, 30));
      expect(log.updatedAt, DateTime.utc(2024, 5, 1, 10, 31));
    });

    test('should parse the creation timestamp as UTC when the wire value '
        'carries a zulu offset', () {
      // Arrange
      final resource = notificationResourceFromJson(<String, Object?>{
        ...notificationJson,
        'createdAt': '2024-05-01T10:30:00Z',
        'updatedAt': '2024-05-01T10:31:00Z',
      });

      // Act
      final log = notificationResponseResourceToDomain(resource);

      // Assert
      expect(log.createdAt.isUtc, isTrue);
      expect(log.createdAt, DateTime.utc(2024, 5, 1, 10, 30));
    });

    test('should parse a timestamp carrying an explicit numeric offset', () {
      // Arrange
      final resource = notificationResourceFromJson(<String, Object?>{
        ...notificationJson,
        'createdAt': '2024-05-01T10:30:00-05:00',
        'updatedAt': '2024-05-01T10:31:00-05:00',
      });

      // Act
      final log = notificationResponseResourceToDomain(resource);

      // Assert
      expect(log.createdAt, DateTime.utc(2024, 5, 1, 15, 30));
      expect(log.updatedAt, DateTime.utc(2024, 5, 1, 15, 31));
    });

    test('should parse a timestamp without any offset as a local instant',
        () {
      // Arrange
      final resource = notificationResourceFromJson(<String, Object?>{
        ...notificationJson,
        'createdAt': '2024-05-01T10:30:00',
        'updatedAt': '2024-05-01T10:31:00',
      });

      // Act
      final log = notificationResponseResourceToDomain(resource);

      // Assert
      expect(log.createdAt.isUtc, isFalse);
      expect(log.createdAt, DateTime(2024, 5, 1, 10, 30));
    });

    test('should fall back to the current instant when the creation timestamp '
        'cannot be parsed', () {
      // Arrange
      final resource = notificationResourceFromJson(<String, Object?>{
        ...notificationJson,
        'createdAt': 'not-a-date',
        'updatedAt': '2024-05-01T10:31:00Z',
      });
      final before = DateTime.now();

      // Act
      final log = notificationResponseResourceToDomain(resource);

      // Assert
      final after = DateTime.now();
      expect(log.createdAt.isAfter(before), isTrue);
      expect(log.createdAt.isBefore(after), isTrue);
      expect(log.updatedAt, DateTime.utc(2024, 5, 1, 10, 31));
    });

    test('should fall back to the current instant when the creation timestamp '
        'is missing', () {
      // Arrange
      final resource = notificationResourceFromJson(<String, Object?>{
        ...notificationJson,
      }..remove('createdAt'));
      final before = DateTime.now();

      // Act
      final log = notificationResponseResourceToDomain(resource);

      // Assert
      expect(log.createdAt.isAfter(before), isTrue);
      expect(log.createdAt.isBefore(DateTime.now()), isTrue);
    });

    test('should carry the delivery error of an undelivered notification', () {
      // Arrange
      final resource = notificationResourceFromJson(<String, Object?>{
        ...notificationJson,
        'sent': false,
        'errorMessage': 'Push token expired',
      });

      // Act
      final log = notificationResponseResourceToDomain(resource);

      // Assert
      expect(log.sent, isFalse);
      expect(log.errorMessage, 'Push token expired');
    });

    test('should map a null optional reference to a null domain field', () {
      // Arrange
      final resource = notificationResourceFromJson(<String, Object?>{
        ...notificationJson,
        'alertId': null,
        'errorMessage': null,
      });

      // Act
      final log = notificationResponseResourceToDomain(resource);

      // Assert
      expect(log.alertId, isNull);
      expect(log.errorMessage, isNull);
    });

    test('should throw an ArgumentError when the wire identifier is blank',
        () {
      // Arrange: the resource factory defaults a missing id to an empty
      // string and `NotificationId` refuses it.
      final resource = notificationResourceFromJson(<String, Object?>{
        ...notificationJson,
        'id': '',
      });

      // Act / Assert
      expect(
        () => notificationResponseResourceToDomain(resource),
        throwsArgumentError,
      );
    });

    test('should not read any field that is absent from the wire payload', () {
      // Arrange
      final resource = notificationResourceFromJson(<String, Object?>{
        'id': 'notification-1',
        'userId': 'user-1',
      });

      // Act
      final log = notificationResponseResourceToDomain(resource);

      // Assert: unknown or renamed fields stay empty instead of leaking in.
      expect(log.userId, 'user-1');
      expect(log.title, isEmpty);
      expect(log.message, isEmpty);
      expect(log.alertId, isNull);
      expect(log.sent, isFalse);
    });
  });

  group('notificationPageResourceToDomain', () {
    test('should map every element of the page and copy the pagination '
        'metadata', () {
      // Arrange
      final resource = notificationPageResourceFromJson(<String, Object?>{
        'content': <Object?>[
          <String, Object?>{
            ...notificationJson,
            'id': 'notification-1',
            'title': 'first',
          },
          <String, Object?>{
            ...notificationJson,
            'id': 'notification-2',
            'title': 'second',
          },
        ],
        'totalElements': 25,
        'totalPages': 2,
        'size': 20,
        'number': 1,
      });

      // Act
      final page = notificationPageResourceToDomain(resource);

      // Assert
      expect(page, isA<NotificationPage>());
      expect(page.content, hasLength(2));
      expect(
        page.content.map((log) => log.id.value).toList(),
        <String>['notification-1', 'notification-2'],
      );
      expect(
        page.content.map((log) => log.title).toList(),
        <String>['first', 'second'],
      );
      expect(page.totalElements, 25);
      expect(page.totalPages, 2);
      expect(page.size, 20);
      expect(page.number, 1);
    });

    test('should map an empty backend page to an empty domain page', () {
      // Arrange
      final resource =
          notificationPageResourceFromJson(emptyNotificationsPageJson);

      // Act
      final page = notificationPageResourceToDomain(resource);

      // Assert
      expect(page.content, isEmpty);
      expect(page.totalElements, 0);
      expect(page.totalPages, 0);
    });

    test('should keep the element order of the backend page', () {
      // Arrange
      final resource = notificationPageResourceFromJson(<String, Object?>{
        'content': <Object?>[
          <String, Object?>{'id': 'notification-3', 'title': 'third'},
          <String, Object?>{'id': 'notification-1', 'title': 'first'},
          <String, Object?>{'id': 'notification-2', 'title': 'second'},
        ],
      });

      // Act
      final page = notificationPageResourceToDomain(resource);

      // Assert
      expect(
        page.content.map((log) => log.id.value).toList(),
        <String>['notification-3', 'notification-1', 'notification-2'],
      );
    });
  });
}