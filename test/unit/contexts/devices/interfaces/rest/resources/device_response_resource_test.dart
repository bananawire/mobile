import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_response.resource.dart';

import '../../../helpers/device_fixtures.dart';

void main() {
  group('DeviceResponseResource.fromJson', () {
    test('should parse every field of a well formed payload', () {
      // Arrange
      final json = deviceResourceJson();

      // Act
      final resource = DeviceResponseResource.fromJson(json);

      // Assert
      expect(resource.id, 'dev-1');
      expect(resource.serialNumber, 'SN-dev-1');
      expect(resource.name, 'Living Room Sensor');
      expect(resource.status, 'ONLINE');
      expect(resource.spaceId, 'space-1');
      expect(resource.ownerUserId, 'user-1');
      expect(resource.configuration, <String, String>{'reportingInterval': '60'});
      expect(resource.thresholds, hasLength(1));
      expect(resource.hardwareId, 'HW-1');
      expect(resource.deviceType, 'AIR_QUALITY');
      expect(resource.activatedAt, DateTime.utc(2024, 1, 15, 10, 30));
      expect(resource.lastSeenAt, DateTime.utc(2024, 2, 20, 8));
      expect(resource.createdAt, DateTime.utc(2024, 1, 15, 10));
      expect(resource.updatedAt, DateTime.utc(2024, 2, 20, 8, 5));
    });

    test('should parse an offset timestamp into the matching instant', () {
      // Arrange
      final json = deviceResourceJson(createdAt: '2024-02-20T08:05:00+02:00');

      // Act
      final resource = DeviceResponseResource.fromJson(json);

      // Assert
      expect(resource.createdAt, DateTime.utc(2024, 2, 20, 6, 5));
    });

    test('should fall back to empty strings when required fields are missing', () {
      // Arrange
      const json = <String, dynamic>{};

      // Act
      final resource = DeviceResponseResource.fromJson(json);

      // Assert
      expect(resource.id, '');
      expect(resource.serialNumber, '');
      expect(resource.name, '');
      expect(resource.status, '');
      expect(resource.hardwareId, '');
      expect(resource.deviceType, '');
    });

    test('should keep absent optional fields as null', () {
      // Arrange
      final json = deviceResourceJson(
        spaceId: null,
        ownerUserId: null,
        activatedAt: null,
        lastSeenAt: null,
        createdAt: null,
        updatedAt: null,
      );

      // Act
      final resource = DeviceResponseResource.fromJson(json);

      // Assert
      expect(resource.spaceId, isNull);
      expect(resource.ownerUserId, isNull);
      expect(resource.activatedAt, isNull);
      expect(resource.lastSeenAt, isNull);
      expect(resource.createdAt, isNull);
      expect(resource.updatedAt, isNull);
    });

    test('should coerce a non string scalar into its string form', () {
      // Arrange
      const json = <String, dynamic>{'id': 42, 'name': 7, 'spaceId': 9};

      // Act
      final resource = DeviceResponseResource.fromJson(json);

      // Assert
      expect(resource.id, '42');
      expect(resource.name, '7');
      expect(resource.spaceId, '9');
    });

    test('should keep only string entries of the configuration map', () {
      // Arrange
      const json = <String, dynamic>{
        'configuration': <String, dynamic>{
          'kept': 'yes',
          'numeric': 5,
          'nested': <String, dynamic>{'a': 'b'},
        },
      };

      // Act
      final resource = DeviceResponseResource.fromJson(json);

      // Assert
      expect(resource.configuration, <String, String>{'kept': 'yes'});
    });

    test('should return an empty configuration when the value is not a map', () {
      // Arrange
      const json = <String, dynamic>{'configuration': 'none'};

      // Act
      final resource = DeviceResponseResource.fromJson(json);

      // Assert
      expect(resource.configuration, isEmpty);
    });

    test('should keep the raw threshold entries without parsing them', () {
      // Arrange
      const json = <String, dynamic>{
        'thresholds': <dynamic>[
          {'metric': 'PM25', 'value': 60},
          {'metric': 'CO2', 'value': 900},
        ],
      };

      // Act
      final resource = DeviceResponseResource.fromJson(json);

      // Assert
      expect(resource.thresholds, hasLength(2));
      expect((resource.thresholds.first as Map<String, dynamic>)['metric'], 'PM25');
    });

    test('should return an empty threshold list when the value is not a list', () {
      // Arrange
      const json = <String, dynamic>{'thresholds': 'none'};

      // Act
      final resource = DeviceResponseResource.fromJson(json);

      // Assert
      expect(resource.thresholds, isEmpty);
    });

    test('should return a null timestamp when the value is not a valid date', () {
      // Arrange
      const json = <String, dynamic>{'lastSeenAt': 'yesterday'};

      // Act
      final resource = DeviceResponseResource.fromJson(json);

      // Assert
      expect(resource.lastSeenAt, isNull);
    });

    test('should not throw when an optional field carries an explicit null', () {
      // Arrange
      const json = <String, dynamic>{
        'id': 'dev-1',
        'spaceId': null,
        'lastSeenAt': null,
        'configuration': null,
        'thresholds': null,
      };

      // Act
      final resource = DeviceResponseResource.fromJson(json);

      // Assert
      expect(resource.id, 'dev-1');
      expect(resource.spaceId, isNull);
      expect(resource.lastSeenAt, isNull);
      expect(resource.configuration, isEmpty);
      expect(resource.thresholds, isEmpty);
    });
  });
}