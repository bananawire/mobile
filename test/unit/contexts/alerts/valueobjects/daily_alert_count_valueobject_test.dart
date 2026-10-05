import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/daily_alert_count.valueobject.dart';

void main() {
  group('DailyAlertCount', () {
    test('should expose the date and count when built from a backend day bucket',
        () {
      // Arrange / Act
      const summary = DailyAlertCount(date: '2024-05-01', count: 7);

      // Assert
      expect(summary.date, '2024-05-01');
      expect(summary.count, 7);
    });

    test('should keep a zero count for a day without alerts', () {
      // Arrange / Act
      const summary = DailyAlertCount(date: '2024-05-02', count: 0);

      // Assert
      expect(summary.count, 0);
    });

    test('should keep a negative count because the value object performs no '
        'normalization', () {
      // Arrange / Act
      const summary = DailyAlertCount(date: '2024-05-03', count: -5);

      // Assert
      expect(
        summary.count,
        -5,
        reason: 'DailyAlertCount is a plain holder with no clamping',
      );
    });

    test('should keep the raw date string because no date parsing or '
        'normalization is performed', () {
      // Arrange / Act
      const summary = DailyAlertCount(date: '  2024-05-04  ', count: 1);

      // Assert
      expect(summary.date, '  2024-05-04  ');
    });

    test('should keep an empty date because no validation is performed', () {
      // Arrange / Act
      const summary = DailyAlertCount(date: '', count: 3);

      // Assert
      expect(summary.date, isEmpty);
    });

    test('should aggregate the total of several day buckets when they are '
        'combined by the caller', () {
      // Arrange
      const summaries = <DailyAlertCount>[
        DailyAlertCount(date: '2024-05-01', count: 2),
        DailyAlertCount(date: '2024-05-02', count: 5),
        DailyAlertCount(date: '2024-05-03', count: 0),
      ];

      // Act
      final total = summaries.fold<int>(0, (sum, day) => sum + day.count);

      // Assert
      expect(total, 7);
    });

    test('should keep the last bucket for a duplicated date because the value '
        'object performs no de-duplication', () {
      // Arrange
      const summaries = <DailyAlertCount>[
        DailyAlertCount(date: '2024-05-01', count: 2),
        DailyAlertCount(date: '2024-05-01', count: 9),
      ];

      // Act / Assert
      expect(summaries, hasLength(2));
      expect(summaries.last.count, 9);
    });

    test('should not define value equality so two identical buckets are '
        'distinct instances', () {
      // Arrange
      final first = DailyAlertCount(date: '2024-05-01', count: 7);
      final second = DailyAlertCount(date: '2024-05-01', count: 7);

      // Act / Assert
      expect(first == second, isFalse);
    });
  });
}