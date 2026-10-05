import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/domain/model/valueobjects/user_id.valueobject.dart';

void main() {
  group('UserId', () {
    test('should expose the given identifier when a canonical UUID is provided', () {
      // Arrange
      const raw = '3f2504e0-4f89-41d3-9a0c-0305e82c3301';

      // Act
      final userId = UserId(raw);

      // Assert
      expect(userId.id, raw);
      expect(userId.toString(), raw);
    });

    test('should accept an uppercase UUID', () {
      // Arrange
      const raw = '3F2504E0-4F89-41D3-9A0C-0305E82C3301';

      // Act
      final userId = UserId(raw);

      // Assert
      expect(userId.id, raw);
    });

    test('should throw ArgumentError when the identifier is empty', () {
      // Arrange
      const raw = '';

      // Act
      UserId create() => UserId(raw);

      // Assert
      expect(
        create,
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'User ID cannot be empty',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the identifier is not a UUID', () {
      // Arrange
      const malformed = <String, String>{
        'plain text': 'user-1',
        'missing dashes': '3f2504e04f8941d39a0c0305e82c3301',
        'too short': '3f2504e0-4f89-41d3-9a0c',
        'non hexadecimal character': '3f2504e0-4f89-41d3-9a0c-0305e82c330z',
        'surrounding whitespace': ' 3f2504e0-4f89-41d3-9a0c-0305e82c3301 ',
        'uuid with trailing text': '3f2504e0-4f89-41d3-9a0c-0305e82c3301x',
      };

      for (final entry in malformed.entries) {
        // Act
        UserId create() => UserId(entry.value);

        // Assert
        expect(
          create,
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'User ID must be a valid UUID',
            ),
          ),
          reason: entry.key,
        );
      }
    });

    test('should not consider two identifiers built from the same input as equal', () {
      // Arrange
      const raw = '3f2504e0-4f89-41d3-9a0c-0305e82c3301';
      final first = UserId(raw);
      final second = UserId(raw);

      // Act
      final areEqual = first == second;

      // Assert
      expect(areEqual, isFalse);
      expect(first.id, second.id);
    });
  });
}