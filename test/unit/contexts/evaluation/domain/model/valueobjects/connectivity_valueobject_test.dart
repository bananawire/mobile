import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/connectivity.valueobject.dart';

void main() {
  group('Connectivity', () {
    test('should expose the status, network and signal strength it was built '
        'with', () {
      // Arrange / Act
      final connectivity = Connectivity(
        status: 'ONLINE',
        network: 'wifi',
        signalStrength: -57,
      );

      // Assert
      expect(connectivity.status, 'ONLINE');
      expect(connectivity.network, 'wifi');
      expect(connectivity.signalStrength, -57);
    });

    test('should accept a null network because the field is nullable', () {
      // Arrange / Act
      final connectivity = Connectivity(
        status: 'ONLINE',
        network: null,
        signalStrength: -57,
      );

      // Assert
      expect(connectivity.network, isNull);
    });

    test(
      'should accept a null signal strength because the field is nullable',
      () {
        // Arrange / Act
        final connectivity = Connectivity(
          status: 'UNKNOWN',
          network: null,
          signalStrength: null,
        );

        // Assert
        expect(connectivity.signalStrength, isNull);
        expect(connectivity.status, 'UNKNOWN');
      },
    );

    test(
      'should keep a null signal strength instead of coercing it to zero',
      () {
        // Arrange / Act
        final connectivity = Connectivity(
          status: 'OFFLINE',
          network: null,
          signalStrength: null,
        );

        // Assert
        expect(connectivity.signalStrength, isNot(0));
      },
    );

    test('should preserve the raw dBm signal strength including negative '
        'values without normalising them', () {
      // Arrange
      const readings = <int>[-90, -70, -57, -40, 0];

      // Act
      final connectivities = readings
          .map(
            (dbm) => Connectivity(
              status: 'ONLINE',
              network: 'wifi',
              signalStrength: dbm,
            ),
          )
          .toList();

      // Assert
      expect(connectivities.map((c) => c.signalStrength), readings);
    });

    test('should preserve an out-of-band signal strength because no range '
        'validation is implemented', () {
      // Arrange / Act
      final connectivity = Connectivity(
        status: 'ONLINE',
        network: 'wifi',
        signalStrength: 150,
      );

      // Assert
      expect(connectivity.signalStrength, 150);
    });

    test('should preserve any status string verbatim because no wire-code '
        'codec or unknown-state rejection is implemented', () {
      // Arrange
      const statuses = <String>[
        'ONLINE',
        'OFFLINE',
        'DEGRADED',
        'UNKNOWN_WIRE_CODE_FROM_A_NEWER_BACKEND',
        '',
        '   ',
        'ONLINE ',
        'online',
      ];

      // Act
      final connectivities = statuses
          .map(
            (status) => Connectivity(
              status: status,
              network: null,
              signalStrength: null,
            ),
          )
          .toList();

      // Assert
      expect(connectivities.map((c) => c.status), statuses);
    });

    test('should not provide value equality because the class does not use '
        'Equatable', () {
      // Arrange
      final first = Connectivity(
        status: 'ONLINE',
        network: 'wifi',
        signalStrength: -57,
      );
      final second = Connectivity(
        status: 'ONLINE',
        network: 'wifi',
        signalStrength: -57,
      );

      // Assert
      expect(first == second, isFalse);
    });

    test('should be constructible as a compile-time constant', () {
      // Arrange / Act
      const first = Connectivity(
        status: 'ONLINE',
        network: 'wifi',
        signalStrength: -57,
      );
      const second = Connectivity(
        status: 'ONLINE',
        network: 'wifi',
        signalStrength: -57,
      );

      // Assert: identical const arguments are canonicalised.
      expect(identical(first, second), isTrue);
    });
  });
}
