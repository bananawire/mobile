import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';

void main() {
  group('AlertId', () {
    test('should expose the given identifier when a non blank value is provided',
        () {
      // Arrange
      const rawId = 'alert-0001';

      // Act
      final alertId = AlertId(rawId);

      // Assert
      expect(alertId.value, rawId);
    });

    test('should keep surrounding whitespace when the value is padded',
        () {
      // Arrange
      const rawId = '  alert-0001  ';

      // Act
      final alertId = AlertId(rawId);

      // Assert
      expect(
        alertId.value,
        '  alert-0001  ',
        reason: 'AlertId does not trim, so the raw payload is preserved',
      );
    });

    test('should accept a single character identifier when it is not blank',
        () {
      // Arrange
      const rawId = 'a';

      // Act
      final alertId = AlertId(rawId);

      // Assert
      expect(alertId.value, 'a');
    });

    test(
        'should accept an opaque uuid like identifier because no format is '
        'enforced', () {
      // Arrange
      const rawId = '9f8d7c6b-1a2b-4c3d-8e9f-0a1b2c3d4e5f';

      // Act
      final alertId = AlertId(rawId);

      // Assert
      expect(alertId.value, '9f8d7c6b-1a2b-4c3d-8e9f-0a1b2c3d4e5f');
    });

    test('should throw ArgumentError when the identifier is an empty string',
        () {
      // Arrange
      const rawId = '';

      // Act / Assert
      expect(
        () => AlertId(rawId),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Alert ID is required',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the identifier is only whitespace',
        () {
      // Arrange
      const rawId = '   \t\n ';

      // Act / Assert
      expect(() => AlertId(rawId), throwsArgumentError);
    });

    test('should throw the documented ArgumentError when the identifier is blank',
        () {
      // Arrange
      const rawId = ' ';

      // Act / Assert
      expect(
        () => AlertId(rawId),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Alert ID is required',
          ),
        ),
      );
    });

    test('should not consider two instances with the same text equal because it '
        'has no equality override', () {
      // Arrange
      final first = AlertId('alert-1');
      final second = AlertId('alert-1');

      // Act
      final areEqual = first == second;

      // Assert
      expect(areEqual, isFalse);
      expect(first.hashCode, isNot(second.hashCode));
    });
  });
}