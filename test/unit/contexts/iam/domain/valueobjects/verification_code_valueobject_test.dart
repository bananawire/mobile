import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/domain/model/valueobjects/verification_code.valueobject.dart';

void main() {
  group('VerificationCode', () {
    test('should expose the given code when it matches XXXX-XXXX', () {
      // Arrange
      const raw = 'A1B2-C3D4';

      // Act
      final code = VerificationCode(raw);

      // Assert
      expect(code.code, raw);
      expect(code.toString(), raw);
    });

    test('should accept uppercase letters and digits in both groups', () {
      // Arrange
      const valid = <String>['0000-0000', 'ZZZZ-ZZZZ', 'A1B2-C3D4', 'ABCD-1234'];

      // Act
      final codes = valid.map(VerificationCode.new).toList();

      // Assert
      expect(codes.map((c) => c.code), valid);
    });

    test('should throw ArgumentError when the code is empty', () {
      // Arrange
      const raw = '';

      // Act
      VerificationCode create() => VerificationCode(raw);

      // Assert
      expect(
        create,
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Verification code cannot be empty',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the code does not match XXXX-XXXX', () {
      // Arrange
      const malformed = <String, String>{
        'lowercase letters': 'a1b2-c3d4',
        'missing separator': 'A1B2C3D4',
        'wrong separator': 'A1B2_C3D4',
        'first group too short': 'A1B-C3D4',
        'first group too long': 'A1B2C-C3D4',
        'second group too short': 'A1B2-C3D',
        'second group too long': 'A1B2-C3D45',
        'special character': 'A1#2-C3D4',
        'surrounding whitespace': ' A1B2-C3D4',
      };

      for (final entry in malformed.entries) {
        // Act
        VerificationCode create() => VerificationCode(entry.value);

        // Assert
        expect(
          create,
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Verification code must be in format XXXX-XXXX (uppercase alphanumeric)',
            ),
          ),
          reason: entry.key,
        );
      }
    });
  });
}