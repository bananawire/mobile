import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/interfaces/rest/resources/alert_page.resource.dart';

import '../../../alerts_fixtures.dart';

void main() {
  group('AlertPageResource.fromJson', () {
    test('should map the content items and the pagination metadata of a page '
        'wrapper', () {
      // Arrange
      final json = alertPageJson(
        content: [alertJson(), resolvedAlertJson()],
        totalElements: 41,
        totalPages: 3,
        size: 20,
        number: 1,
      );

      // Act
      final resource = AlertPageResource.fromJson(json);

      // Assert
      expect(resource.content, hasLength(2));
      expect(resource.content.first.id, 'alert-1');
      expect(resource.content.last.id, 'alert-2');
      expect(resource.content.last.resolvedAt, '2024-05-02T09:15:00Z');
      expect(resource.totalElements, 41);
      expect(resource.totalPages, 3);
      expect(resource.size, 20);
      expect(resource.number, 1);
    });

    test('should expose an empty content list when the page wrapper carries no '
        'items', () {
      // Arrange / Act
      final resource = AlertPageResource.fromJson(emptyAlertPageJson);

      // Assert
      expect(resource.content, isEmpty);
      expect(resource.totalElements, 0);
      expect(resource.totalPages, 0);
      expect(resource.number, 0);
    });

    test('should expose an empty content list when the content key is missing',
        () {
      // Arrange
      const json = <String, dynamic>{'totalElements': 5, 'totalPages': 1};

      // Act
      final resource = AlertPageResource.fromJson(json);

      // Assert
      expect(resource.content, isEmpty);
      expect(resource.totalElements, 5);
      expect(resource.totalPages, 1);
    });

    test('should expose an empty content list when content is not a list', () {
      // Arrange
      const json = <String, dynamic>{
        'content': 'not-a-list',
        'totalElements': 3,
      };

      // Act
      final resource = AlertPageResource.fromJson(json);

      // Assert
      expect(resource.content, isEmpty);
    });

    test('should expose an empty content list when content is null', () {
      // Arrange
      const json = <String, dynamic>{'content': null};

      // Act
      final resource = AlertPageResource.fromJson(json);

      // Assert
      expect(resource.content, isEmpty);
    });

    test('should skip non object entries inside the content list', () {
      // Arrange
      final json = <String, dynamic>{
        'content': <dynamic>[
          alertJson(),
          'garbage',
          42,
          resolvedAlertJson(),
        ],
      };

      // Act
      final resource = AlertPageResource.fromJson(json);

      // Assert
      expect(resource.content, hasLength(2));
      expect(resource.content.first.id, 'alert-1');
      expect(resource.content.last.id, 'alert-2');
    });

    test('should default every pagination counter to zero when the wrapper '
        'omits them', () {
      // Arrange
      const json = <String, dynamic>{};

      // Act
      final resource = AlertPageResource.fromJson(json);

      // Assert
      expect(resource.totalElements, 0);
      expect(resource.totalPages, 0);
      expect(resource.size, 0);
      expect(resource.number, 0);
    });

    test('should default every pagination counter to zero when the counters are '
        'explicitly null', () {
      // Arrange
      const json = <String, dynamic>{
        'totalElements': null,
        'totalPages': null,
        'size': null,
        'number': null,
      };

      // Act
      final resource = AlertPageResource.fromJson(json);

      // Assert
      expect(resource.totalElements, 0);
      expect(resource.totalPages, 0);
      expect(resource.size, 0);
      expect(resource.number, 0);
    });

    test('should truncate double counters to integers', () {
      // Arrange
      const json = <String, dynamic>{
        'totalElements': 41.0,
        'totalPages': 3.9,
        'size': 20.5,
        'number': 1.2,
      };

      // Act
      final resource = AlertPageResource.fromJson(json);

      // Assert
      expect(resource.totalElements, 41);
      expect(resource.totalPages, 3);
      expect(resource.size, 20);
      expect(resource.number, 1);
    });

    test('should throw a TypeError when a counter is delivered as a string', () {
      // Arrange
      const json = <String, dynamic>{
        'totalElements': '41',
        'totalPages': '3',
      };

      // Act / Assert
      expect(
        () => AlertPageResource.fromJson(json),
        throwsA(
          isA<TypeError>().having(
            (error) => error.toString(),
            'message',
            contains("type 'String' is not a subtype of type 'num?'"),
          ),
        ),
        reason: 'The counters are read with an `as num?` cast, so string '
            'counters are a hard failure instead of a zero fallback',
      );
    });
  });
}