import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';

void main() {
  group('AlertSeverity ValueObject', () {
    test(
      'should return correct uppercase apiValue for each AlertSeverity enum value',
      () {
        // Arrange & Act & Assert
        expect(AlertSeverity.critical.apiValue, equals('CRITICAL'));
        expect(AlertSeverity.warning.apiValue, equals('WARNING'));
        expect(AlertSeverity.low.apiValue, equals('LOW'));
      },
    );

    test(
      'should parse AlertSeverity case-insensitively when valid string is provided',
      () {
        // Arrange & Act & Assert
        expect(
          AlertSeverity.fromString('critical'),
          equals(AlertSeverity.critical),
        );
        expect(
          AlertSeverity.fromString('CRITICAL'),
          equals(AlertSeverity.critical),
        );
        expect(
          AlertSeverity.fromString('Critical'),
          equals(AlertSeverity.critical),
        );

        expect(
          AlertSeverity.fromString('warning'),
          equals(AlertSeverity.warning),
        );
        expect(
          AlertSeverity.fromString('WARNING'),
          equals(AlertSeverity.warning),
        );
        expect(
          AlertSeverity.fromString('Warning'),
          equals(AlertSeverity.warning),
        );

        expect(AlertSeverity.fromString('low'), equals(AlertSeverity.low));
        expect(AlertSeverity.fromString('LOW'), equals(AlertSeverity.low));
        expect(AlertSeverity.fromString('Low'), equals(AlertSeverity.low));
      },
    );

    test('should return null when string does not match any AlertSeverity', () {
      // Arrange & Act & Assert
      expect(AlertSeverity.fromString(''), isNull);
      expect(AlertSeverity.fromString('UNKNOWN'), isNull);
      expect(AlertSeverity.fromString('high'), isNull);
      expect(AlertSeverity.fromString('medium'), isNull);
    });
  });
}
