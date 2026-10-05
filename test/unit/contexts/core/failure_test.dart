import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/failure.dart';

void main() {
  group('Failure', () {
    test('should carry the message and status code when both are provided', () {
      // Arrange
      const message = 'Unable to reach the backend.';
      const statusCode = 503;

      // Act
      const failure = Failure(message, statusCode: statusCode);

      // Assert
      expect(failure.message, message);
      expect(failure.statusCode, statusCode);
    });

    test('should default the status code to null when it is omitted', () {
      // Arrange & Act
      const failure = Failure('Unexpected error');

      // Assert
      expect(failure.message, 'Unexpected error');
      expect(failure.statusCode, isNull);
    });

    test('should render both the message and the status code in toString', () {
      // Arrange
      const failure = Failure('Bad request.', statusCode: 400);

      // Act
      final rendered = failure.toString();

      // Assert
      expect(rendered, 'Failure(message: Bad request., statusCode: 400)');
    });

    test('should render a null status code in toString when it is omitted', () {
      // Arrange
      const failure = Failure('Unexpected error');

      // Act
      final rendered = failure.toString();

      // Assert
      expect(rendered, 'Failure(message: Unexpected error, statusCode: null)');
    });

    test('should be usable inside const collections', () {
      // Arrange
      const failures = <Failure>[
        Failure('Offline', statusCode: 0),
        Failure('Unexpected error'),
      ];

      // Act
      final messages = failures.map((failure) => failure.message).toList();

      // Assert
      expect(messages, <String>['Offline', 'Unexpected error']);
      expect(
        failures.map((failure) => failure.statusCode),
        <int?>[0, null],
      );
    });
  });
}