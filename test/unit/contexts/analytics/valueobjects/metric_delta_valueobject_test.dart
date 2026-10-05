import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/domain/model/valueobjects/metric_delta.valueobject.dart';

void main() {
  group('MetricDelta', () {
    test('should keep the metric value and its signed percentage as provided',
        () {
      // Arrange
      const value = 612.0;
      const delta = -12.25;

      // Act
      final metric = MetricDelta(value, delta);

      // Assert
      expect(metric.value, value);
      expect(metric.deltaPercentage, delta);
    });

    test('should keep a null percentage to signal no comparison period', () {
      // Arrange / Act
      final metric = MetricDelta(21.6, null);

      // Assert
      expect(metric.value, 21.6);
      expect(metric.deltaPercentage, isNull);
    });

    test('should keep a zero percentage so a flat trend is distinguishable '
        'from a missing one', () {
      // Arrange / Act
      final metric = MetricDelta(48.2, 0);

      // Assert
      expect(metric.deltaPercentage, 0);
    });

    test('should not normalize the percentage sign, leaving direction '
        'decisions to the presentation layer', () {
      // Arrange
      const growing = 12.0;
      const shrinking = -12.0;

      // Act
      final up = MetricDelta(100, growing);
      final down = MetricDelta(100, shrinking);

      // Assert
      expect(up.deltaPercentage, greaterThan(0));
      expect(down.deltaPercentage, lessThan(0));
      expect(up.deltaPercentage, equals(12.0));
      expect(down.deltaPercentage, equals(-up.deltaPercentage!));
    });

    test('should accept a negative metric value because only the percentage '
        'carries direction', () {
      // Arrange / Act
      final metric = MetricDelta(-3.5, 1);

      // Assert
      expect(metric.value, -3.5);
    });

    test('should throw an ArgumentError when the metric value is infinite', () {
      // Arrange
      const infinite = double.infinity;

      // Act / Assert
      expect(
        () => MetricDelta(infinite, 1),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Metric value must be a finite number',
          ),
        ),
      );
    });

    test('should throw an ArgumentError when the metric value is NaN', () {
      // Arrange
      const notANumber = double.nan;

      // Act / Assert
      expect(
        () => MetricDelta(notANumber, null),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw an ArgumentError when the percentage is infinite', () {
      // Arrange
      const infinite = double.infinity;

      // Act / Assert
      expect(
        () => MetricDelta(10, infinite),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Delta percentage must be null or a finite number',
          ),
        ),
      );
    });

    test('should throw an ArgumentError when the percentage is NaN', () {
      // Arrange
      const notANumber = double.nan;

      // Act / Assert
      expect(
        () => MetricDelta(10, notANumber),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}