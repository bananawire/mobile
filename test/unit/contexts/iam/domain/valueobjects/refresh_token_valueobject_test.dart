import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/domain/model/valueobjects/refresh_token.valueobject.dart';

void main() {
  group('RefreshToken', () {
    test('should expose the given token and render it as string', () {
      // Arrange
      const raw = 'rt_9f8c1b2a3d4e4f508a6b7c8d9e0f1a2b';

      // Act
      final token = RefreshToken(raw);

      // Assert
      expect(token.token, raw);
      expect(token.toString(), raw);
    });

    test('should accept a JWT shaped refresh token', () {
      // Arrange
      const raw = 'header.payload.signature';

      // Act
      final token = RefreshToken(raw);

      // Assert
      expect(token.token, raw);
    });

    test('should throw ArgumentError when the token is empty', () {
      // Arrange
      const raw = '';

      // Act
      RefreshToken create() => RefreshToken(raw);

      // Assert
      expect(
        create,
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Refresh token cannot be empty',
          ),
        ),
      );
    });
  });
}