import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notifications/domain/model/queries/get_notifications.query.dart';

void main() {
  group('GetNotificationsQuery', () {
    test('should read the first page with twenty entries by default', () {
      // Arrange / Act
      final query = GetNotificationsQuery();

      // Assert
      expect(query.page, 0);
      expect(query.size, 20);
    });

    test('should keep the requested page and size', () {
      // Arrange / Act
      final query = GetNotificationsQuery(page: 3, size: 50);

      // Assert
      expect(query.page, 3);
      expect(query.size, 50);
    });

    test('should accept the first page index', () {
      // Arrange / Act
      final query = GetNotificationsQuery(page: 0);

      // Assert
      expect(query.page, 0);
    });

    test('should throw an ArgumentError when the page index is negative', () {
      // Act / Assert
      expect(
        () => GetNotificationsQuery(page: -1),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'page must be >= 0',
          ),
        ),
      );
    });

    for (final int allowed in <int>[1, 50, 100]) {
      test('should accept a page size of $allowed', () {
        // Arrange / Act
        final query = GetNotificationsQuery(size: allowed);

        // Assert
        expect(query.size, allowed);
      });
    }

    for (final int rejected in <int>[-1, 0, 101, 1000]) {
      test('should throw an ArgumentError when the page size is $rejected', () {
        // Act / Assert
        expect(
          () => GetNotificationsQuery(size: rejected),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.message,
              'message',
              'size must be between 1 and 100',
            ),
          ),
        );
      });
    }
  });
}