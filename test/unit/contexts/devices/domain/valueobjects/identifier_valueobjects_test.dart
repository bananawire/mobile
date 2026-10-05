import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/hardware_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';

void main() {
  group('DeviceId', () {
    test('should expose the identifier as its value when given a well formed id', () {
      // Arrange
      const raw = 'dev-8f2c';

      // Act
      final deviceId = DeviceId(raw);

      // Assert
      expect(deviceId.value, raw);
    });

    test('should trim surrounding whitespace when given a padded identifier', () {
      // Arrange
      const raw = '  dev-8f2c\n';

      // Act
      final deviceId = DeviceId(raw);

      // Assert
      expect(deviceId.value, 'dev-8f2c');
    });

    test('should throw ArgumentError when given an empty identifier', () {
      // Arrange
      const raw = '';

      // Act / Assert
      expect(
        () => DeviceId(raw),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Device id is required')),
      );
    });

    test('should throw ArgumentError when given a whitespace only identifier', () {
      // Arrange
      const raw = '   \t ';

      // Act / Assert
      expect(
        () => DeviceId(raw),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Device id is required')),
      );
    });

    test('should not enforce a UUID or any other structural format on the identifier', () {
      // Arrange
      const raw = 'NOT-A-UUID-at-all';

      // Act
      final deviceId = DeviceId(raw);

      // Assert
      expect(deviceId.value, 'NOT-A-UUID-at-all');
    });
  });

  group('HardwareId', () {
    test('should expose the serial as its value when given a well formed hardware id', () {
      // Arrange
      const raw = 'HW-9911';

      // Act
      final hardwareId = HardwareId(raw);

      // Assert
      expect(hardwareId.value, 'HW-9911');
    });

    test('should trim surrounding whitespace when given a padded hardware id', () {
      // Arrange
      const raw = ' HW-9911 ';

      // Act
      final hardwareId = HardwareId(raw);

      // Assert
      expect(hardwareId.value, 'HW-9911');
    });

    test('should throw ArgumentError when given a whitespace only hardware id', () {
      // Arrange
      const raw = '     ';

      // Act / Assert
      expect(
        () => HardwareId(raw),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Hardware ID is required')),
      );
    });
  });

  group('SpaceId', () {
    test('should expose the identifier as its value when given a well formed space id', () {
      // Arrange
      const raw = 'space-1';

      // Act
      final spaceId = SpaceId(raw);

      // Assert
      expect(spaceId.value, 'space-1');
    });

    test('should keep the raw identifier untrimmed because only validation trims', () {
      // Arrange
      const raw = ' space-1 ';

      // Act
      final spaceId = SpaceId(raw);

      // Assert
      expect(spaceId.value, ' space-1 ');
    });

    test('should throw ArgumentError when given a whitespace only space id', () {
      // Arrange
      const raw = '  ';

      // Act / Assert
      expect(
        () => SpaceId(raw),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Space id is required')),
      );
    });
  });

  group('OrganizationId', () {
    test('should expose the identifier as its value when given a well formed organization id', () {
      // Arrange
      const raw = 'org-1';

      // Act
      final organizationId = OrganizationId(raw);

      // Assert
      expect(organizationId.value, 'org-1');
    });

    test('should keep the raw identifier untrimmed because only validation trims', () {
      // Arrange
      const raw = ' org-1 ';

      // Act
      final organizationId = OrganizationId(raw);

      // Assert
      expect(organizationId.value, ' org-1 ');
    });

    test('should throw ArgumentError when given a whitespace only organization id', () {
      // Arrange
      const raw = '\n\t';

      // Act / Assert
      expect(
        () => OrganizationId(raw),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', 'Organization id is required'),
        ),
      );
    });
  });
}