import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_space.query.dart';

void main() {
  group('GetAlertsBySpaceQuery', () {
    test('should expose the space identifier with default pagination when only '
        'the space is provided', () {
      // Arrange / Act
      final query = GetAlertsBySpaceQuery(spaceId: 'space-1');

      // Assert
      expect(query.spaceId, 'space-1');
      expect(query.page, 0);
      expect(query.size, 20);
    });

    test('should expose the requested pagination when valid arguments are '
        'provided', () {
      // Arrange / Act
      final query = GetAlertsBySpaceQuery(spaceId: 'space-7', page: 4, size: 10);

      // Assert
      expect(query.spaceId, 'space-7');
      expect(query.page, 4);
      expect(query.size, 10);
    });

    test('should accept the pagination boundaries when page is zero and size is '
        'one hundred', () {
      // Arrange / Act
      final query = GetAlertsBySpaceQuery(spaceId: 'space-1', page: 0, size: 100);

      // Assert
      expect(query.page, 0);
      expect(query.size, 100);
    });

    test('should throw ArgumentError when the space identifier is empty', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertsBySpaceQuery(spaceId: ''),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'spaceId cannot be empty',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the space identifier is only '
        'whitespace', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertsBySpaceQuery(spaceId: '\t '),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'spaceId cannot be empty',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the page is negative', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertsBySpaceQuery(spaceId: 'space-1', page: -3),
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
        () => GetAlertsBySpaceQuery(spaceId: 'space-1', size: 0),
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
        () => GetAlertsBySpaceQuery(spaceId: 'space-1', size: 1000),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'size must be between 1 and 100',
          ),
        ),
      );
    });
  });
}