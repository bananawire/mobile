import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/domain/model/valueobjects/session_id.valueobject.dart';

void main() {
  group('SessionId', () {
    test('should expose the given identifier when a canonical UUID is provided', () {
      // Arrange
      const raw = '9f8c1b2a-3d4e-4f50-8a6b-7c8d9e0f1a2b';

      // Act
      final sessionId = SessionId(raw);

      // Assert
      expect(sessionId.id, raw);
      expect(sessionId.toString(), raw);
    });

    test('should accept an uppercase UUID', () {
      // Arrange
      const raw = '9F8C1B2A-3D4E-4F50-8A6B-7C8D9E0F1A2B';

      // Act
      final sessionId = SessionId(raw);

      // Assert
      expect(sessionId.id, raw);
    });

    test('should throw ArgumentError when the identifier is empty', () {
      // Arrange
      const raw = '';

      // Act
      SessionId create() => SessionId(raw);

      // Assert
      expect(
        create,
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Session ID cannot be empty',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the identifier is not a UUID', () {
      // Arrange
      const malformed = <String, String>{
        'plain text': 'session-1',
        'missing dashes': '9f8c1b2a3d4e4f508a6b7c8d9e0f1a2b',
        'too short': '9f8c1b2a-3d4e-4f50-8a6b',
        'non hexadecimal character': '9f8c1b2a-3d4e-4f50-8a6b-7c8d9e0f1a2g',
        'surrounding whitespace': ' 9f8c1b2a-3d4e-4f50-8a6b-7c8d9e0f1a2b ',
      };

      for (final entry in malformed.entries) {
        // Act
        SessionId create() => SessionId(entry.value);

        // Assert
        expect(
          create,
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Session ID must be a valid UUID',
            ),
          ),
          reason: entry.key,
        );
      }
    });
  });
}