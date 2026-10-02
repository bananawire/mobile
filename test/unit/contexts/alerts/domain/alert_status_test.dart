import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';

void main() {
  group('AlertStatus ValueObject', () {
    test(
      'should return correct uppercase apiValue for each AlertStatus enum value',
      () {
        // Arrange & Act & Assert
        expect(AlertStatus.active.apiValue, equals('ACTIVE'));
        expect(AlertStatus.acknowledged.apiValue, equals('ACKNOWLEDGED'));
        expect(AlertStatus.resolved.apiValue, equals('RESOLVED'));
      },
    );

    test(
      'should parse AlertStatus case-insensitively when valid status string is provided',
      () {
        // Arrange & Act & Assert
        expect(AlertStatus.fromString('active'), equals(AlertStatus.active));
        expect(AlertStatus.fromString('ACTIVE'), equals(AlertStatus.active));
        expect(AlertStatus.fromString('Active'), equals(AlertStatus.active));

        expect(
          AlertStatus.fromString('acknowledged'),
          equals(AlertStatus.acknowledged),
        );
        expect(
          AlertStatus.fromString('ACKNOWLEDGED'),
          equals(AlertStatus.acknowledged),
        );
        expect(
          AlertStatus.fromString('Acknowledged'),
          equals(AlertStatus.acknowledged),
        );

        expect(
          AlertStatus.fromString('resolved'),
          equals(AlertStatus.resolved),
        );
        expect(
          AlertStatus.fromString('RESOLVED'),
          equals(AlertStatus.resolved),
        );
        expect(
          AlertStatus.fromString('Resolved'),
          equals(AlertStatus.resolved),
        );
      },
    );

    test('should return null when status string is unknown or empty', () {
      // Arrange & Act & Assert
      expect(AlertStatus.fromString(''), isNull);
      expect(AlertStatus.fromString('PENDING'), isNull);
      expect(AlertStatus.fromString('closed'), isNull);
      expect(AlertStatus.fromString('unknown_status'), isNull);
    });
  });
}
