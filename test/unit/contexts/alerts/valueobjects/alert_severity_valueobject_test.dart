import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';

void main() {
  group('AlertSeverity', () {
    group('apiValue', () {
      test('should expose CRITICAL as the wire code for the critical severity',
          () {
        // Arrange / Act / Assert
        expect(AlertSeverity.critical.apiValue, 'CRITICAL');
      });

      test('should expose WARNING as the wire code for the warning severity',
          () {
        // Arrange / Act / Assert
        expect(AlertSeverity.warning.apiValue, 'WARNING');
      });

      test('should expose LOW as the wire code for the low severity', () {
        // Arrange / Act / Assert
        expect(AlertSeverity.low.apiValue, 'LOW');
      });
    });

    group('fromString', () {
      test('should parse the upper case critical wire code', () {
        // Arrange
        const wire = 'CRITICAL';

        // Act
        final severity = AlertSeverity.fromString(wire);

        // Assert
        expect(severity, AlertSeverity.critical);
      });

      test('should parse the upper case warning wire code', () {
        // Arrange
        const wire = 'WARNING';

        // Act
        final severity = AlertSeverity.fromString(wire);

        // Assert
        expect(severity, AlertSeverity.warning);
      });

      test('should parse the upper case low wire code', () {
        // Arrange
        const wire = 'LOW';

        // Act
        final severity = AlertSeverity.fromString(wire);

        // Assert
        expect(severity, AlertSeverity.low);
      });

      test('should parse a lower case wire code because the lookup upper cases '
          'the input', () {
        // Arrange
        const wire = 'critical';

        // Act
        final severity = AlertSeverity.fromString(wire);

        // Assert
        expect(severity, AlertSeverity.critical);
      });

      test('should parse a mixed case wire code because the lookup upper cases '
          'the input', () {
        // Arrange
        const wire = 'WaRnInG';

        // Act
        final severity = AlertSeverity.fromString(wire);

        // Assert
        expect(severity, AlertSeverity.warning);
      });

      test('should return null when the wire code is unknown', () {
        // Arrange
        const wire = 'FATAL';

        // Act
        final severity = AlertSeverity.fromString(wire);

        // Assert
        expect(severity, isNull);
      });

      test('should return null when the wire code is empty', () {
        // Arrange
        const wire = '';

        // Act
        final severity = AlertSeverity.fromString(wire);

        // Assert
        expect(severity, isNull);
      });

      test('should return null when the wire code is padded with whitespace',
          () {
        // Arrange
        const wire = ' CRITICAL ';

        // Act
        final severity = AlertSeverity.fromString(wire);

        // Assert
        expect(
          severity,
          isNull,
          reason: 'The lookup does not trim, so a padded wire code is unknown',
        );
      });
    });

    group('round trip', () {
      test('should map every declared severity back from its own wire code', () {
        // Arrange
        final severities = AlertSeverity.values;

        // Act
        final parsed = severities
            .map((severity) => AlertSeverity.fromString(severity.apiValue))
            .toList();

        // Assert
        expect(parsed, severities);
      });
    });
  });
}