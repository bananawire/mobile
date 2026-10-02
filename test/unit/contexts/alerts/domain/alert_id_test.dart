import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';

void main() {
  group('AlertId ValueObject', () {
    test('should create AlertId when value is valid non-empty string', () {
      // Arrange & Act
      final alertId = AlertId('alert-123');

      // Assert
      expect(alertId.value, equals('alert-123'));
    });

    test('should trim leading and trailing whitespace when value has whitespace', () {
      // Arrange & Act
      final alertId = AlertId('  alert-456  ');

      // Assert
      expect(alertId.value, equals('alert-456'));
    });

    test('should throw ArgumentError when value is empty', () {
      // Arrange, Act & Assert
      expect(() => AlertId(''), throwsA(isA<ArgumentError>()));
    });

    test('should throw ArgumentError when value contains only whitespace', () {
      // Arrange, Act & Assert
      expect(() => AlertId('   \t\n  '), throwsA(isA<ArgumentError>()));
    });

    test('should support value equality when two AlertIds have same value', () {
      // Arrange
      final id1 = AlertId('alert-abc');
      final id2 = AlertId('alert-abc');
      final id3 = AlertId('alert-xyz');

      // Act & Assert
      expect(id1, equals(id2));
      expect(id1.hashCode, equals(id2.hashCode));
      expect(id1, isNot(equals(id3)));
    });

    test('should return value string when toString is called', () {
      // Arrange
      final alertId = AlertId('alert-789');

      // Act & Assert
      expect(alertId.toString(), equals('alert-789'));
    });
  });
}
