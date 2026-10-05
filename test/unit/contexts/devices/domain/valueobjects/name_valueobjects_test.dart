import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_name.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_name.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_name.valueobject.dart';

void main() {
  group('DeviceName', () {
    test('should expose the name as its value when given a valid device name', () {
      // Arrange
      const raw = 'Living Room Sensor';

      // Act
      final name = DeviceName(raw);

      // Assert
      expect(name.value, 'Living Room Sensor');
    });

    test('should trim surrounding whitespace when given a padded device name', () {
      // Arrange
      const raw = '  Kitchen Probe  ';

      // Act
      final name = DeviceName(raw);

      // Assert
      expect(name.value, 'Kitchen Probe');
    });

    test('should throw ArgumentError when given a whitespace only device name', () {
      // Arrange
      const raw = '   ';

      // Act / Assert
      expect(
        () => DeviceName(raw),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Device name is required')),
      );
    });

    test('should accept a single character device name because no minimum length is enforced', () {
      // Arrange
      const raw = 'A';

      // Act
      final name = DeviceName(raw);

      // Assert
      expect(name.value, 'A');
    });
  });

  group('SpaceName', () {
    test('should expose the name as its value when given a valid space name', () {
      // Arrange
      const raw = 'Main Bedroom';

      // Act
      final name = SpaceName(raw);

      // Assert
      expect(name.value, 'Main Bedroom');
    });

    test('should accept the minimum length of two characters', () {
      // Arrange
      const raw = 'AB';

      // Act
      final name = SpaceName(raw);

      // Assert
      expect(name.value, 'AB');
    });

    test('should accept the maximum length of sixty four characters', () {
      // Arrange
      final raw = 'x' * 64;

      // Act
      final name = SpaceName(raw);

      // Assert
      expect(name.value.length, 64);
    });

    test('should throw ArgumentError when the name is longer than sixty four characters', () {
      // Arrange
      final raw = 'x' * 65;

      // Act / Assert
      expect(
        () => SpaceName(raw),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Space name is too long')),
      );
    });

    test('should throw ArgumentError when the trimmed name is a single character', () {
      // Arrange
      const raw = ' x ';

      // Act / Assert
      expect(
        () => SpaceName(raw),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Space name is too short')),
      );
    });

    test('should throw ArgumentError when the name is whitespace only', () {
      // Arrange
      const raw = '  \t';

      // Act / Assert
      expect(
        () => SpaceName(raw),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', 'Space name is required'),
        ),
      );
    });
  });

  group('OrganizationName', () {
    test('should expose the name as its value when given a valid organization name', () {
      // Arrange
      const raw = 'Acme Corp';

      // Act
      final name = OrganizationName(raw);

      // Assert
      expect(name.value, 'Acme Corp');
    });

    test('should accept the minimum length of two characters', () {
      // Arrange
      const raw = 'AB';

      // Act
      final name = OrganizationName(raw);

      // Assert
      expect(name.value, 'AB');
    });

    test('should accept the maximum length of sixty four characters', () {
      // Arrange
      final raw = 'y' * 64;

      // Act
      final name = OrganizationName(raw);

      // Assert
      expect(name.value.length, 64);
    });

    test('should throw ArgumentError when the name is longer than sixty four characters', () {
      // Arrange
      final raw = 'y' * 65;

      // Act / Assert
      expect(
        () => OrganizationName(raw),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', 'Organization name is too long'),
        ),
      );
    });

    test('should throw ArgumentError when the trimmed name is a single character', () {
      // Arrange
      const raw = ' Z ';

      // Act / Assert
      expect(
        () => OrganizationName(raw),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', 'Organization name is too short'),
        ),
      );
    });

    test('should throw ArgumentError when the name is whitespace only', () {
      // Arrange
      const raw = ' ';

      // Act / Assert
      expect(
        () => OrganizationName(raw),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', 'Organization name is required'),
        ),
      );
    });
  });
}