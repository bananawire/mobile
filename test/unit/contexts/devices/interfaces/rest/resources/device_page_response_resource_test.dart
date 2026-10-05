import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_page_response.resource.dart';

import '../../../helpers/device_fixtures.dart';

void main() {
  group('DevicePageResponseResource.fromJson', () {
    test('should parse every content entry and the paging metadata', () {
      // Arrange
      final json = devicePageJson(totalElements: 2, number: 1, size: 20);

      // Act
      final page = DevicePageResponseResource.fromJson(json);

      // Assert
      expect(page.totalElements, 2);
      expect(page.number, 1);
      expect(page.size, 20);
      expect(page.content, hasLength(2));
      expect(page.content.map((d) => d.id), ['dev-1', 'dev-2']);
      expect(page.content.last.name, 'Kitchen Probe');
    });

    test('should return an empty content list when the key is missing', () {
      // Arrange
      const json = <String, dynamic>{'totalElements': 0};

      // Act
      final page = DevicePageResponseResource.fromJson(json);

      // Assert
      expect(page.content, isEmpty);
      expect(page.totalElements, 0);
      expect(page.number, 0);
      expect(page.size, 0);
    });

    test('should skip content entries that are not json objects', () {
      // Arrange
      final json = <String, dynamic>{
        'content': <dynamic>[
          deviceResourceJson(id: 'dev-1'),
          'not-a-device',
          42,
        ],
        'totalElements': 3,
      };

      // Act
      final page = DevicePageResponseResource.fromJson(json);

      // Assert
      expect(page.content, hasLength(1));
      expect(page.content.single.id, 'dev-1');
    });

    test('should coerce double encoded paging metadata into an int', () {
      // Arrange
      const json = <String, dynamic>{'totalElements': 12.0, 'number': 1.0, 'size': 2.0};

      // Act
      final page = DevicePageResponseResource.fromJson(json);

      // Assert
      expect(page.totalElements, 12);
      expect(page.number, 1);
      expect(page.size, 2);
    });

    test('should coerce string encoded paging metadata into an int', () {
      // Arrange
      const json = <String, dynamic>{'totalElements': '30', 'number': '2', 'size': '5'};

      // Act
      final page = DevicePageResponseResource.fromJson(json);

      // Assert
      expect(page.totalElements, 30);
      expect(page.number, 2);
      expect(page.size, 5);
    });

    test('should fall back to zero when the paging metadata is not numeric', () {
      // Arrange
      const json = <String, dynamic>{'totalElements': 'many', 'number': null, 'size': <int>[1]};

      // Act
      final page = DevicePageResponseResource.fromJson(json);

      // Assert
      expect(page.totalElements, 0);
      expect(page.number, 0);
      expect(page.size, 0);
    });

    test('should return an empty content list when the value is not a list', () {
      // Arrange
      const json = <String, dynamic>{'content': <String, dynamic>{}, 'totalElements': 1};

      // Act
      final page = DevicePageResponseResource.fromJson(json);

      // Assert
      expect(page.content, isEmpty);
    });
  });
}