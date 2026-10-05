import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/valueobjects/claim_token.valueobject.dart';

void main() {
  group('ClaimToken', () {
    test('should expose the token as its value when given a well formed claim token', () {
      // Arrange
      const raw = 'claim-token-abc123';

      // Act
      final token = ClaimToken(raw);

      // Assert
      expect(token.value, 'claim-token-abc123');
    });

    test('should trim surrounding whitespace when given a padded claim token', () {
      // Arrange
      const raw = '\t claim-token-abc123 \n';

      // Act
      final token = ClaimToken(raw);

      // Assert
      expect(token.value, 'claim-token-abc123');
    });

    test('should throw ArgumentError when given an empty claim token', () {
      // Arrange
      const raw = '';

      // Act / Assert
      expect(
        () => ClaimToken(raw),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', 'Claim token is required'),
        ),
      );
    });

    test('should throw ArgumentError when given a whitespace only claim token', () {
      // Arrange
      const raw = '    ';

      // Act / Assert
      expect(
        () => ClaimToken(raw),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', 'Claim token is required'),
        ),
      );
    });

    test('should accept a single character claim token because no length is enforced', () {
      // Arrange
      const raw = 'c';

      // Act
      final token = ClaimToken(raw);

      // Assert
      expect(token.value, 'c');
    });
  });
}