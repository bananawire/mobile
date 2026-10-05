import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/notifications_fixtures.dart';

void main() {
  group('NotificationPageResource.fromJson', () {
    test('should read the content and the pagination metadata', () {
      // Arrange / Act
      final page = notificationPageResourceFromJson(notificationPageJson);

      // Assert
      expect(page.content, hasLength(1));
      expect(page.content.single.id, 'notification-1');
      expect(page.content.single.title, 'High temperature');
      expect(page.totalElements, 1);
      expect(page.totalPages, 1);
      expect(page.size, 20);
      expect(page.number, 0);
    });

    test('should read every element of a multi entry page', () {
      // Arrange
      final json = <String, Object?>{
        'content': <Object?>[
          <String, Object?>{'id': 'notification-1', 'title': 'first'},
          <String, Object?>{'id': 'notification-2', 'title': 'second'},
          <String, Object?>{'id': 'notification-3', 'title': 'third'},
        ],
        'totalElements': 3,
        'totalPages': 1,
        'size': 20,
        'number': 0,
      };

      // Act
      final page = notificationPageResourceFromJson(json);

      // Assert
      expect(page.content, hasLength(3));
      expect(
        page.content.map((element) => element.id).toList(),
        <String>['notification-1', 'notification-2', 'notification-3'],
      );
    });

    test('should read an empty content list as an empty page', () {
      // Arrange / Act
      final page =
          notificationPageResourceFromJson(emptyNotificationsPageJson);

      // Assert
      expect(page.content, isEmpty);
      expect(page.totalElements, 0);
      expect(page.totalPages, 0);
      expect(page.number, 0);
    });

    test('should read a missing content key as an empty list', () {
      // Arrange / Act
      final page = notificationPageResourceFromJson(<String, Object?>{
        'totalElements': 0,
        'totalPages': 0,
      });

      // Assert
      expect(page.content, isEmpty);
    });

    test('should read a content value of the wrong type as an empty list', () {
      // Arrange
      final Map<String, Object?> json = <String, Object?>{
        'content': <String, Object?>{'id': 'notification-1'},
      };

      // Act
      final page = notificationPageResourceFromJson(json);

      // Assert
      expect(page.content, isEmpty);
    });

    test('should skip content entries that are not objects', () {
      // Arrange
      final Map<String, Object?> json = <String, Object?>{
        'content': <Object?>[
          <String, Object?>{'id': 'notification-1'},
          'not an object',
          42,
          null,
          <String, Object?>{'id': 'notification-2'},
        ],
      };

      // Act
      final page = notificationPageResourceFromJson(json);

      // Assert
      expect(page.content, hasLength(2));
      expect(
        page.content.map((element) => element.id).toList(),
        <String>['notification-1', 'notification-2'],
      );
    });

    test('should default every missing pagination field to zero', () {
      // Arrange / Act
      final page = notificationPageResourceFromJson(const <String, Object?>{});

      // Assert
      expect(page.totalElements, 0);
      expect(page.totalPages, 0);
      expect(page.size, 0);
      expect(page.number, 0);
      expect(page.content, isEmpty);
    });

    test('should truncate a double valued pagination field to an integer', () {
      // Arrange
      final Map<String, Object?> json = <String, Object?>{
        'totalElements': 10.9,
        'totalPages': 2.5,
        'size': 20.0,
        'number': 1.2,
      };

      // Act
      final page = notificationPageResourceFromJson(json);

      // Assert
      expect(page.totalElements, 10);
      expect(page.totalPages, 2);
      expect(page.size, 20);
      expect(page.number, 1);
    });

    test('should throw a type error when a pagination field carries the wrong '
        'wire type', () {
      // Arrange: unlike the item resource, the page resource casts the numeric
      // metadata with `as num?`, so a textual value is a hard failure.
      final Map<String, Object?> json = <String, Object?>{
        'totalElements': '42',
      };

      // Act / Assert
      expect(
        () => notificationPageResourceFromJson(json),
        throwsA(isA<TypeError>()),
      );
    });

    test('should read the zero based page index of the last page', () {
      // Arrange
      final Map<String, Object?> json = <String, Object?>{
        'content': <Object?>[],
        'totalElements': 40,
        'totalPages': 2,
        'size': 20,
        'number': 1,
      };

      // Act
      final page = notificationPageResourceFromJson(json);

      // Assert
      expect(page.number, 1);
      expect(page.totalPages, 2);
      expect(page.totalElements, 40);
    });
  });
}