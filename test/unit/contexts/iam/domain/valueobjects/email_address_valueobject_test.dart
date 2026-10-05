import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/domain/model/valueobjects/email_address.valueobject.dart';

void main() {
  group('EmailAddress', () {
    test(
      'should expose the given address when a well formed address is provided',
      () {
        // Arrange
        const raw = 'ada.lovelace@example.com';

        // Act
        final email = EmailAddress(raw);

        // Assert
        expect(email.address, raw);
        expect(email.toString(), raw);
      },
    );

    test('should keep uppercase letters of the local and domain parts', () {
      // Arrange
      const raw = 'Ada.Lovelace@Example.COM';

      // Act
      final email = EmailAddress(raw);

      // Assert
      expect(email.address, raw);
    });

    test(
      'should accept a multi level subdomain when the top level domain is two to four characters',
      () {
        // Arrange
        const valid = <String>[
          'user@example.com',
          'user@example.io',
          'user@example.info',
          'user@mail.sub.example.co.uk',
          'user-name@example-domain.com',
          'user_name@example.com',
          'first.last@example.com',
        ];

        // Act
        final results = valid.map(EmailAddress.new).toList();

        // Assert
        expect(results.map((e) => e.address), valid);
      },
    );

    test(
      'should throw ArgumentError when the address is empty',
      () {
        // Arrange
        const raw = '';

        // Act
        EmailAddress create() => EmailAddress(raw);

        // Assert
        expect(
          create,
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Email address cannot be empty',
            ),
          ),
        );
      },
    );

    test(
      'should throw ArgumentError when the address has no at sign',
      () {
        // Arrange
        const raw = 'ada.lovelace.example.com';

        // Act
        EmailAddress create() => EmailAddress(raw);

        // Assert
        expect(
          create,
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Invalid email address format',
            ),
          ),
        );
      },
    );

    test(
      'should throw ArgumentError when the address has no domain suffix',
      () {
        // Arrange
        const malformed = <String, String>{
          'missing top level domain': 'ada@example',
          'single character top level domain': 'ada@example.c',
          'top level domain longer than four characters': 'ada@example.museum',
          'missing domain': 'ada@',
          'missing local part': '@example.com',
          'missing trailing dot separator': 'ada@example.',
        };

        for (final entry in malformed.entries) {
          // Arrange
          final reason = entry.key;
          final raw = entry.value;

          // Act
          EmailAddress create() => EmailAddress(raw);

          // Assert
          expect(
            create,
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'Invalid email address format',
              ),
            ),
            reason: reason,
          );
        }
      },
    );

    test(
      'should throw ArgumentError when the address contains characters outside the allowed set',
      () {
        // Arrange
        const malformed = <String>[
          'ada lovelace@example.com',
          'ada+lovelace@example.com',
          'ada@exa mple.com',
          '  ada@example.com',
          'ada@example.com  ',
          '\tada@example.com',
          'ada@@example.com',
          'ada.lovelace@.com',
        ];

        for (final raw in malformed) {
          // Act
          EmailAddress create() => EmailAddress(raw);

          // Assert
          expect(
            create,
            throwsA(isA<ArgumentError>()),
            reason: 'expected <$raw> to be rejected',
          );
        }
      },
    );
  });
}