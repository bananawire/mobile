import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/interfaces/rest/resources/daily_alert_summary.resource.dart';

void main() {
  group('DailyAlertSummaryResource.fromJson', () {
    test('should map the date and count of a well formed day bucket', () {
      // Arrange
      const json = <String, dynamic>{'date': '2024-05-01', 'count': 7};

      // Act
      final resource = DailyAlertSummaryResource.fromJson(json);

      // Assert
      expect(resource.date, '2024-05-01');
      expect(resource.count, 7);
    });

    test('should keep a double count as a double because the resource is not '
        'rounded here', () {
      // Arrange
      const json = <String, dynamic>{'date': '2024-05-01', 'count': 7.5};

      // Act
      final resource = DailyAlertSummaryResource.fromJson(json);

      // Assert
      expect(resource.count, 7.5);
    });

    test('should throw a TypeError when the count is delivered as a string',
        () {
      // Arrange
      const json = <String, dynamic>{'date': '2024-05-01', 'count': '12'};

      // Act / Assert
      expect(
        () => DailyAlertSummaryResource.fromJson(json),
        throwsA(
          isA<TypeError>().having(
            (error) => error.toString(),
            'message',
            contains("type 'String' is not a subtype of type 'num?'"),
          ),
        ),
        reason: 'The count is cast with `as num?`, so a string payload is a '
            'hard failure and never reaches the tryParse fallback',
      );
    });

    test('should throw a TypeError when the count is a non numeric string',
        () {
      // Arrange
      const json = <String, dynamic>{'date': '2024-05-01', 'count': 'many'};

      // Act / Assert
      expect(
        () => DailyAlertSummaryResource.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });

    test('should fall back to zero when the count key is missing', () {
      // Arrange
      const json = <String, dynamic>{'date': '2024-05-01'};

      // Act
      final resource = DailyAlertSummaryResource.fromJson(json);

      // Assert
      expect(resource.count, 0);
    });

    test('should fall back to zero when the count is null', () {
      // Arrange
      const json = <String, dynamic>{'date': '2024-05-01', 'count': null};

      // Act
      final resource = DailyAlertSummaryResource.fromJson(json);

      // Assert
      expect(resource.count, 0);
    });

    test('should fall back to zero when a double count is missing entirely',
        () {
      // Arrange
      const json = <String, dynamic>{};

      // Act
      final resource = DailyAlertSummaryResource.fromJson(json);

      // Assert
      expect(resource.date, isEmpty);
      expect(resource.count, 0);
    });

    test('should fall back to an empty date when the date is missing', () {
      // Arrange
      const json = <String, dynamic>{'count': 3};

      // Act
      final resource = DailyAlertSummaryResource.fromJson(json);

      // Assert
      expect(resource.date, isEmpty);
      expect(resource.count, 3);
    });

    test('should stringify a non string date instead of failing', () {
      // Arrange
      const json = <String, dynamic>{'date': 20240501, 'count': 1};

      // Act
      final resource = DailyAlertSummaryResource.fromJson(json);

      // Assert
      expect(resource.date, '20240501');
    });
  });
}