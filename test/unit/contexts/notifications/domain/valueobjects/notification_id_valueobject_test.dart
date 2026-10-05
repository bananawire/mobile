import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_id.valueobject.dart';

/// Renders a blank sample readably inside a test name.
String _label(String blank) => blank.isEmpty ? 'empty' : 'whitespace only';

void main() {
  group('NotificationId', () {
    test('should keep the given identifier untouched', () {
      // Arrange
      const raw = 'notification-42';

      // Act
      final id = NotificationId(raw);

      // Assert
      expect(id.value, raw);
    });

    test('should not normalise surrounding whitespace', () {
      // Arrange
      const raw = '  notification-42  ';

      // Act
      final id = NotificationId(raw);

      // Assert: the factory only checks that the value is not blank, it does
      // not trim what the backend sent.
      expect(id.value, raw);
    });

    test('should accept identifiers made of any non blank characters', () {
      // Arrange
      const raw = '  a  ';

      // Act
      final id = NotificationId(raw);

      // Assert
      expect(id.value, raw);
    });

    for (final String blank in <String>['', ' ', '\t', '\n', '   \t \n ']) {
      test('should throw an ArgumentError when the identifier is ${_label(blank)}', () {
        // Arrange
        final String blank = '';

        // Act / Assert
        expect(() => NotificationId(blank), throwsArgumentError);
      });
    }

    test('should report the required field in the rejection message', () {
      // Act / Assert
      expect(
        () => NotificationId('   '),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Notification ID is required',
          ),
        ),
      );
    });

    test('should be equal to another identifier carrying the same value', () {
      // Arrange
      final first = NotificationId('notification-42');
      final second = NotificationId('notification-42');

      // Act
      final areEqual = first == second;

      // Assert
      expect(areEqual, isTrue);
      expect(first.hashCode, second.hashCode);
    });

    test('should not be equal to an identifier carrying another value', () {
      // Arrange
      final first = NotificationId('notification-42');
      final second = NotificationId('notification-43');

      // Act
      final areEqual = first == second;

      // Assert
      expect(areEqual, isFalse);
    });

    test('should not be equal to an object of another type', () {
      // Arrange
      final id = NotificationId('notification-42');
      final Object other = 'notification-42';

      // Act
      final areEqual = id == other;

      // Assert
      expect(areEqual, isFalse);
    });

    test('should render the raw identifier in toString', () {
      // Arrange
      final id = NotificationId('notification-42');

      // Act / Assert
      expect(id.toString(), 'notification-42');
    });
  });
}