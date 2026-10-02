import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/device_id.valueobject.dart';

void main() {
  group('EvaluationDeviceId', () {
    test(
      'should create valid EvaluationDeviceId when non-empty string is provided',
      () {
        // Arrange
        const rawId = 'device-abc-123';

        // Act
        final deviceId = EvaluationDeviceId(rawId);

        // Assert
        expect(deviceId.value, equals(rawId));
      },
    );

    test(
      'should trim leading and trailing whitespace when created with whitespace padded string',
      () {
        // Arrange
        const rawIdWithSpaces = '   device-abc-123   \t\n';

        // Act
        final deviceId = EvaluationDeviceId(rawIdWithSpaces);

        // Assert
        expect(deviceId.value, equals('device-abc-123'));
      },
    );

    test('should throw ArgumentError when input is an empty string', () {
      // Arrange
      const emptyId = '';

      // Act & Assert
      expect(
        () => EvaluationDeviceId(emptyId),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            equals('Device id is required'),
          ),
        ),
      );
    });

    test(
      'should throw ArgumentError when input contains only whitespace characters',
      () {
        // Arrange
        const whitespaceOnly = '     \t  \n  ';

        // Act & Assert
        expect(
          () => EvaluationDeviceId(whitespaceOnly),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              equals('Device id is required'),
            ),
          ),
        );
      },
    );
  });
}
