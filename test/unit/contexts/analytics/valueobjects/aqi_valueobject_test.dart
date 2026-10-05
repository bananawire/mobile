import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/domain/model/valueobjects/aqi.valueobject.dart';

void main() {
  group('Aqi', () {
    test('should keep the reading and category when both are valid', () {
      // Arrange
      const value = 42.0;
      const category = 'Moderate';

      // Act
      final aqi = Aqi(value, category);

      // Assert
      expect(aqi.value, value);
      expect(aqi.category, category);
    });

    test('should trim surrounding whitespace from the category', () {
      // Arrange
      const rawCategory = '  Unhealthy for Sensitive  ';

      // Act
      final aqi = Aqi(155, rawCategory);

      // Assert
      expect(aqi.category, 'Unhealthy for Sensitive');
    });

    test('should accept zero as the lower bound of a valid reading', () {
      // Arrange / Act
      final aqi = Aqi(0, 'Good');

      // Assert
      expect(aqi.value, 0);
      expect(aqi.category, 'Good');
    });

    test('should accept a decimal reading', () {
      // Arrange / Act
      final aqi = Aqi(42.75, 'Good');

      // Assert
      expect(aqi.value, 42.75);
    });

    test('should throw an ArgumentError when the reading is negative', () {
      // Arrange
      const negative = -0.01;

      // Act / Assert
      expect(
        () => Aqi(negative, 'Good'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'AQI value must be a non-negative finite number',
          ),
        ),
      );
    });

    test('should throw an ArgumentError when the reading is infinite', () {
      // Arrange
      const infinite = double.infinity;

      // Act / Assert
      expect(
        () => Aqi(infinite, 'Good'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw an ArgumentError when the reading is NaN', () {
      // Arrange
      const notANumber = double.nan;

      // Act / Assert
      expect(
        () => Aqi(notANumber, 'Good'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw an ArgumentError when the category is empty', () {
      // Arrange
      const blank = '';

      // Act / Assert
      expect(
        () => Aqi(10, blank),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'AQI category cannot be empty',
          ),
        ),
      );
    });

    test('should throw an ArgumentError when the category is only whitespace', () {
      // Arrange
      const blank = '   \t ';

      // Act / Assert
      expect(
        () => Aqi(10, blank),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}