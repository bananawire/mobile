import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_daily_summary.query.dart';

void main() {
  group('GetAlertDailySummaryQuery', () {
    test('should default to thirty days when no argument is provided', () {
      // Arrange / Act
      final query = GetAlertDailySummaryQuery();

      // Assert
      expect(query.days, 30);
    });

    test('should expose the requested window when a valid amount of days is '
        'provided', () {
      // Arrange / Act
      final query = GetAlertDailySummaryQuery(days: 7);

      // Assert
      expect(query.days, 7);
    });

    test('should accept the lower boundary when one day is requested', () {
      // Arrange / Act
      final query = GetAlertDailySummaryQuery(days: 1);

      // Assert
      expect(query.days, 1);
    });

    test('should accept the upper boundary when three hundred sixty five days '
        'are requested', () {
      // Arrange / Act
      final query = GetAlertDailySummaryQuery(days: 365);

      // Assert
      expect(query.days, 365);
    });

    test('should throw ArgumentError when zero days are requested', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertDailySummaryQuery(days: 0),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'days must be between 1 and 365',
          ),
        ),
      );
    });

    test('should throw ArgumentError when more than three hundred sixty five '
        'days are requested', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertDailySummaryQuery(days: 366),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'days must be between 1 and 365',
          ),
        ),
      );
    });

    test('should throw ArgumentError when a negative window is requested', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertDailySummaryQuery(days: -1),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'days must be between 1 and 365',
          ),
        ),
      );
    });
  });
}