import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts.query.dart';

void main() {
  group('GetAlertsQuery', () {
    test('should default to the first page with twenty items when no arguments '
        'are provided', () {
      // Arrange / Act
      final query = GetAlertsQuery();

      // Assert
      expect(query.page, 0);
      expect(query.size, 20);
    });

    test('should expose the requested pagination when valid arguments are '
        'provided', () {
      // Arrange / Act
      final query = GetAlertsQuery(page: 3, size: 50);

      // Assert
      expect(query.page, 3);
      expect(query.size, 50);
    });

    test('should accept the lower page boundary when page is zero', () {
      // Arrange / Act
      final query = GetAlertsQuery(page: 0, size: 1);

      // Assert
      expect(query.page, 0);
    });

    test('should accept the upper size boundary when size is one hundred', () {
      // Arrange / Act
      final query = GetAlertsQuery(page: 0, size: 100);

      // Assert
      expect(query.size, 100);
    });

    test('should throw ArgumentError when the page is negative', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertsQuery(page: -1),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'page must be >= 0',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the size is zero', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertsQuery(page: 0, size: 0),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'size must be between 1 and 100',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the size exceeds one hundred', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertsQuery(page: 0, size: 101),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'size must be between 1 and 100',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the size is negative', () {
      // Arrange / Act / Assert
      expect(() => GetAlertsQuery(page: 0, size: -5), throwsArgumentError);
    });

    test('should report the page violation first when both page and size are '
        'invalid', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertsQuery(page: -2, size: 500),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'page must be >= 0',
          ),
        ),
      );
    });
  });
}