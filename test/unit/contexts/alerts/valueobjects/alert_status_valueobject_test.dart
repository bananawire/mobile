import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';

void main() {
  group('AlertStatus', () {
    group('apiValue', () {
      test('should expose ACTIVE as the wire code for the active status', () {
        // Arrange / Act / Assert
        expect(AlertStatus.active.apiValue, 'ACTIVE');
      });

      test(
          'should expose ACKNOWLEDGED as the wire code for the acknowledged '
          'status', () {
        // Arrange / Act / Assert
        expect(AlertStatus.acknowledged.apiValue, 'ACKNOWLEDGED');
      });

      test('should expose RESOLVED as the wire code for the resolved status',
          () {
        // Arrange / Act / Assert
        expect(AlertStatus.resolved.apiValue, 'RESOLVED');
      });
    });

    group('fromString', () {
      test('should parse the upper case active wire code', () {
        // Arrange
        const wire = 'ACTIVE';

        // Act
        final status = AlertStatus.fromString(wire);

        // Assert
        expect(status, AlertStatus.active);
      });

      test('should parse the upper case acknowledged wire code', () {
        // Arrange
        const wire = 'ACKNOWLEDGED';

        // Act
        final status = AlertStatus.fromString(wire);

        // Assert
        expect(status, AlertStatus.acknowledged);
      });

      test('should parse the upper case resolved wire code', () {
        // Arrange
        const wire = 'RESOLVED';

        // Act
        final status = AlertStatus.fromString(wire);

        // Assert
        expect(status, AlertStatus.resolved);
      });

      test('should parse a lower case wire code because the lookup upper cases '
          'the input', () {
        // Arrange
        const wire = 'resolved';

        // Act
        final status = AlertStatus.fromString(wire);

        // Assert
        expect(status, AlertStatus.resolved);
      });

      test('should parse a mixed case wire code because the lookup upper cases '
          'the input', () {
        // Arrange
        const wire = 'AcKnOwLeDgEd';

        // Act
        final status = AlertStatus.fromString(wire);

        // Assert
        expect(status, AlertStatus.acknowledged);
      });

      test('should return null when the wire code is unknown', () {
        // Arrange
        const wire = 'PENDING';

        // Act
        final status = AlertStatus.fromString(wire);

        // Assert
        expect(status, isNull);
      });

      test('should return null when the wire code is empty', () {
        // Arrange
        const wire = '';

        // Act
        final status = AlertStatus.fromString(wire);

        // Assert
        expect(status, isNull);
      });

      test('should not accept a severity wire code as a status', () {
        // Arrange
        const wire = 'CRITICAL';

        // Act
        final status = AlertStatus.fromString(wire);

        // Assert
        expect(status, isNull);
      });
    });

    group('round trip', () {
      test('should map every declared status back from its own wire code', () {
        // Arrange
        final statuses = AlertStatus.values;

        // Act
        final parsed =
            statuses.map((status) => AlertStatus.fromString(status.apiValue))
                .toList();

        // Assert
        expect(parsed, statuses);
      });
    });
  });
}