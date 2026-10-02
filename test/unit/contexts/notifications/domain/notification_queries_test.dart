import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notifications/domain/model/queries/get_notifications.query.dart';

void main() {
  group('GetNotificationsQuery', () {
    test(
      'should construct query with default values when no parameters are provided',
      () {
        // Arrange & Act
        final query = GetNotificationsQuery();

        // Assert
        expect(query.page, equals(0));
        expect(query.size, equals(20));
      },
    );

    test(
      'should construct query with custom values when valid page and size are provided',
      () {
        // Arrange & Act
        final query = GetNotificationsQuery(page: 3, size: 50);

        // Assert
        expect(query.page, equals(3));
        expect(query.size, equals(50));
      },
    );

    test(
      'should allow boundary values when page is 0, size is 1, or size is 100',
      () {
        // Arrange & Act
        final minQuery = GetNotificationsQuery(page: 0, size: 1);
        final maxQuery = GetNotificationsQuery(page: 0, size: 100);

        // Assert
        expect(minQuery.size, equals(1));
        expect(maxQuery.size, equals(100));
      },
    );

    test('should throw ArgumentError when page is negative', () {
      // Arrange, Act & Assert
      expect(
        () => GetNotificationsQuery(page: -1),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('page must be >= 0'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when size is less than 1', () {
      // Arrange, Act & Assert
      expect(
        () => GetNotificationsQuery(size: 0),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('size must be between 1 and 100'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when size is greater than 100', () {
      // Arrange, Act & Assert
      expect(
        () => GetNotificationsQuery(size: 101),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('size must be between 1 and 100'),
          ),
        ),
      );
    });
  });
}
