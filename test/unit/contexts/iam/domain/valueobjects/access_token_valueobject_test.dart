import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/domain/model/valueobjects/access_token.valueobject.dart';

void main() {
  group('AccessToken', () {
    test('should expose the given token and render it as string', () {
      // Arrange
      const raw = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.abc123';

      // Act
      final token = AccessToken(raw);

      // Assert
      expect(token.token, raw);
      expect(token.toString(), raw);
    });

    test('should accept an opaque non empty token', () {
      // Arrange
      const raw = 'opaque-token-value';

      // Act
      final token = AccessToken(raw);

      // Assert
      expect(token.token, raw);
    });

    test('should throw ArgumentError when the token is empty', () {
      // Arrange
      const raw = '';

      // Act
      AccessToken create() => AccessToken(raw);

      // Assert
      expect(
        create,
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Access token cannot be empty',
          ),
        ),
      );
    });

    test('should accept a whitespace only token because only emptiness is rejected', () {
      // Arrange
      const raw = '   ';

      // Act
      final token = AccessToken(raw);

      // Assert
      expect(token.token, raw);
    });
  });
}