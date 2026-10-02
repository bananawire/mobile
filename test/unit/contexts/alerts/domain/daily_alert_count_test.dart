import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/daily_alert_count.valueobject.dart';

void main() {
  group('DailyAlertCount ValueObject', () {
    test(
      'should construct DailyAlertCount with required date and count fields',
      () {
        // Arrange & Act
        const summary = DailyAlertCount(date: '2026-10-02', count: 5);

        // Assert
        expect(summary.date, equals('2026-10-02'));
        expect(summary.count, equals(5));
      },
    );

    test('should allow zero count when constructing DailyAlertCount', () {
      // Arrange & Act
      const summary = DailyAlertCount(date: '2026-10-01', count: 0);

      // Assert
      expect(summary.date, equals('2026-10-01'));
      expect(summary.count, equals(0));
    });
  });
}
