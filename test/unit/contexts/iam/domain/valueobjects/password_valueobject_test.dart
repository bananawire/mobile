import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/domain/model/valueobjects/password.valueobject.dart';

void main() {
  group('Password', () {
    test('should expose the given secret when it satisfies every rule', () {
      // Arrange
      const raw = 'Str0ng@Pass';

      // Act
      final password = Password(raw);

      // Assert
      expect(password.value, raw);
      expect(password.toString(), raw);
    });

    test(
      'should accept passwords of eight and of one hundred twenty eight characters',
      () {
        // Arrange
        final shortest = 'Aa1@${'b' * 4}';
        final longest = 'Aa1@${'b' * 124}';

        // Act
        final passwords = [Password(shortest), Password(longest)];

        // Assert
        expect(passwords.map((p) => p.value), [shortest, longest]);
      },
    );

    test('should throw ArgumentError when the password is empty', () {
      // Arrange
      const raw = '';

      // Act
      Password create() => Password(raw);

      // Assert
      expect(
        create,
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Password cannot be empty',
          ),
        ),
      );
    });

    test(
      'should throw ArgumentError when the password is shorter than eight characters',
      () {
        // Arrange
        const tooShort = 'Ab1@bc';

        // Act
        Password create() => Password(tooShort);

        // Assert
        expect(
          create,
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Password must be between 8 and 128 characters',
            ),
          ),
        );
      },
    );

    test(
      'should throw ArgumentError when the password is longer than one hundred twenty eight characters',
      () {
        // Arrange
        final tooLong = 'Aa1@${'b' * 125}';

        // Act
        Password create() => Password(tooLong);

        // Assert
        expect(
          create,
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Password must be between 8 and 128 characters',
            ),
          ),
        );
      },
    );

    test(
      'should throw ArgumentError when a required character class is missing',
      () {
        // Arrange
        final invalid = <String, String>{
          'without uppercase letter': 'str0ng@pass',
          'without lowercase letter': 'STR0NG@PASS',
          'without digit': 'Strong@Pass',
          'without special character': 'Str0ngPassw0rd',
        };

        for (final entry in invalid.entries) {
          // Act
          Password create() => Password(entry.value);

          // Assert
          expect(
            create,
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'Password must contain at least one uppercase letter, one '
                    'lowercase letter, one number, and one special character',
              ),
            ),
            reason: entry.key,
          );
        }
      },
    );

    test(
      'should throw ArgumentError when the password contains characters outside the allowed set',
      () {
        // Arrange
        const invalid = <String>[
          'Passw0rd ',
          'Passw0rd\t',
          'Passw0rd#',
          'Passw0rd~',
          'Passw0rd^',
          'Passw0rdÑ1@',
        ];

        for (final raw in invalid) {
          // Act
          Password create() => Password(raw);

          // Assert
          expect(
            create,
            throwsA(isA<ArgumentError>()),
            reason: 'expected <$raw> to be rejected',
          );
        }
      },
    );

    test('should accept every special character of the allowed set', () {
      // Arrange
      const allowed = <String>[
        'Aa1@bcde',
        r'Aa1$bcde',
        'Aa1%bcde',
        'Aa1*bcde',
        'Aa1?bcde',
        'Aa1&bcde',
      ];

      // Act
      final passwords = allowed.map(Password.new).toList();

      // Assert
      expect(passwords.map((p) => p.value), allowed);
    });
  });
}