import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/domain/model/valueobjects/google_id_token.valueobject.dart';

void main() {
  group('GoogleIdToken', () {
    test('should expose the given token unchanged', () {
      // Arrange
      const raw = 'ya29.a0AfH6SMBexampled';

      // Act
      final token = GoogleIdToken(raw);

      // Assert
      expect(token.token, raw);
    });

    test('should throw ArgumentError when the token is empty', () {
      // Arrange
      const raw = '';

      // Act
      GoogleIdToken create() => GoogleIdToken(raw);

      // Assert
      expect(
        create,
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Google ID token is required',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the token only contains whitespace', () {
      // Arrange
      const blanks = <String>['', ' ', '   ', '\t', '\n', ' \t\n '];

      for (final raw in blanks) {
        // Act
        GoogleIdToken create() => GoogleIdToken(raw);

        // Assert
        expect(
          create,
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Google ID token is required',
            ),
          ),
          reason: 'expected <$raw> to be rejected',
        );
      }
    });

    test('should keep surrounding whitespace of a non blank token', () {
      // Arrange
      const raw = '  padded-token  ';

      // Act
      final token = GoogleIdToken(raw);

      // Assert
      expect(token.token, raw);
    });
  });
}