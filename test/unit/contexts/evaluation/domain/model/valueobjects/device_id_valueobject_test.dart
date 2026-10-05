import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/device_id.valueobject.dart';

void main() {
  group('EvaluationDeviceId', () {
    test('should keep the given identifier when it is already free of '
        'surrounding whitespace', () {
      // Arrange
      const raw = 'device-1';

      // Act
      final deviceId = EvaluationDeviceId(raw);

      // Assert
      expect(deviceId.value, 'device-1');
    });

    test('should trim surrounding whitespace from the identifier', () {
      // Arrange
      const raw = '  device-1  ';

      // Act
      final deviceId = EvaluationDeviceId(raw);

      // Assert
      expect(deviceId.value, 'device-1');
    });

    test('should trim tabs and newlines surrounding the identifier', () {
      // Arrange
      const raw = '\t\n device-1 \n\t';

      // Act
      final deviceId = EvaluationDeviceId(raw);

      // Assert
      expect(deviceId.value, 'device-1');
    });

    test('should preserve whitespace inside the identifier because only the '
        'edges are trimmed', () {
      // Arrange
      const raw = 'device  1';

      // Act
      final deviceId = EvaluationDeviceId(raw);

      // Assert
      expect(deviceId.value, 'device  1');
    });

    test('should reject an empty identifier with an ArgumentError', () {
      // Arrange
      const raw = '';

      // Act / Assert
      expect(
        () => EvaluationDeviceId(raw),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Device id is required',
          ),
        ),
      );
    });

    test('should reject a whitespace-only identifier with an ArgumentError '
        'because trimming leaves it blank', () {
      // Arrange
      const raw = '     ';

      // Act / Assert
      expect(
        () => EvaluationDeviceId(raw),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Device id is required',
          ),
        ),
      );
    });

    test('should reject a tab and newline-only identifier with an '
        'ArgumentError', () {
      // Arrange
      const raw = '\t\n';

      // Act / Assert
      expect(
        () => EvaluationDeviceId(raw),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Device id is required',
          ),
        ),
      );
    });

    test('should not validate the identifier format because no UUID or length '
        'rule is implemented', () {
      // Arrange
      const candidates = <String>[
        'not-a-uuid',
        'x',
        '1',
        'a/b?c=d#e',
        'ñandú-9',
        'device-with-a-very-long-identifier-value-that-exceeds-any-reasonable-limit',
      ];

      // Act
      final ids = candidates.map((value) => EvaluationDeviceId(value)).toList();

      // Assert
      expect(ids.map((id) => id.value), candidates);
    });

    test('should accept an identifier that only contains non-whitespace '
        'punctuation', () {
      // Arrange
      const raw = '///';

      // Act
      final deviceId = EvaluationDeviceId(raw);

      // Assert
      expect(deviceId.value, '///');
    });

    test('should not provide value equality because the class does not use '
        'Equatable', () {
      // Arrange
      final first = EvaluationDeviceId('device-1');
      final second = EvaluationDeviceId('device-1');

      // Assert
      expect(first == second, isFalse);
    });
  });
}
