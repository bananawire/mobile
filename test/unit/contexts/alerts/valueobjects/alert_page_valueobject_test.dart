import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_page.valueobject.dart';

import '../alerts_fixtures.dart';

void main() {
  group('AlertPage', () {
    test('should expose the content and pagination metadata when built from '
        'real alerts', () {
      // Arrange
      final alerts = [buildAlert(), buildAlert(id: 'alert-2')];

      // Act
      final page = AlertPage(
        content: alerts,
        totalElements: 42,
        totalPages: 3,
        size: 20,
        number: 0,
      );

      // Assert
      expect(page.content, hasLength(2));
      expect(page.content.first.id.value, 'alert-1');
      expect(page.totalElements, 42);
      expect(page.totalPages, 3);
      expect(page.size, 20);
      expect(page.number, 0);
    });

    test('should expose an empty content list when the page has no elements',
        () {
      // Arrange / Act
      final page = AlertPage(
        content: const [],
        totalElements: 0,
        totalPages: 0,
        size: 20,
        number: 0,
      );

      // Assert
      expect(page.content, isEmpty);
      expect(page.totalElements, 0);
      expect(page.totalPages, 0);
    });

    test('should expose the zero based page number when the first page is '
        'requested', () {
      // Arrange / Act
      final page = AlertPage(
        content: const [],
        totalElements: 0,
        totalPages: 1,
        size: 20,
        number: 0,
      );

      // Assert
      expect(page.number, 0);
    });

    test('should expose the last page number when the backend returns the final '
        'page', () {
      // Arrange / Act
      final page = AlertPage(
        content: const [],
        totalElements: 41,
        totalPages: 3,
        size: 20,
        number: 2,
      );

      // Assert
      expect(page.number, 2);
      expect(page.totalPages, 3);
      expect(page.size, 20);
    });

    test('should keep a negative page number because pagination bounds are not '
        'validated in this value object', () {
      // Arrange / Act
      final page = AlertPage(
        content: const [],
        totalElements: 0,
        totalPages: 0,
        size: 0,
        number: -5,
      );

      // Assert
      expect(page.number, -5);
      expect(page.size, 0);
    });

    test('should keep the total element count that disagrees with the content '
        'length because no consistency check is performed', () {
      // Arrange / Act
      final page = AlertPage(
        content: [buildAlert()],
        totalElements: 137,
        totalPages: 14,
        size: 10,
        number: 0,
      );

      // Assert
      expect(page.content, hasLength(1));
      expect(page.totalElements, 137);
    });

    test('should allow a const construction when used as a compile time '
        'constant', () {
      // Arrange / Act
      const page = AlertPage(
        content: [],
        totalElements: 0,
        totalPages: 0,
        size: 20,
        number: 0,
      );

      // Assert
      expect(page.totalPages, 0);
    });
  });
}