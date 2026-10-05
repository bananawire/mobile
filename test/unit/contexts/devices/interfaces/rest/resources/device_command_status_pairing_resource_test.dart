import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_command_type.valueobject.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_command_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_pairing.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_status_response.resource.dart';

import '../../../helpers/device_fixtures.dart';

void main() {
  group('DeviceCommandResponseResource.fromJson', () {
    test('should parse every field of a well formed payload', () {
      // Arrange
      final json = deviceCommandJson();

      // Act
      final resource = DeviceCommandResponseResource.fromJson(json);

      // Assert
      expect(resource.id, 'cmd-1');
      expect(resource.deviceId, 'dev-1');
      expect(resource.type, 'STANDBY');
      expect(resource.status, 'QUEUED');
      expect(resource.payload, '{"deep":true}');
      expect(resource.sentAt, DateTime.utc(2024, 2, 20, 8));
      expect(resource.executedAt, isNull);
      expect(resource.failureReason, isNull);
      expect(resource.createdAt, DateTime.utc(2024, 2, 20, 7, 59));
    });

    test('should fall back to empty strings for missing identifiers', () {
      // Arrange
      const json = <String, dynamic>{'status': 'QUEUED'};

      // Act
      final resource = DeviceCommandResponseResource.fromJson(json);

      // Assert
      expect(resource.id, '');
      expect(resource.deviceId, '');
      expect(resource.type, '');
      expect(resource.status, 'QUEUED');
    });

    test('should return null timestamps for missing or invalid date values', () {
      // Arrange
      const json = <String, dynamic>{'sentAt': 'not-a-date', 'createdAt': 5};

      // Act
      final resource = DeviceCommandResponseResource.fromJson(json);

      // Assert
      expect(resource.sentAt, isNull);
      expect(resource.createdAt, isNull);
    });

    test('should expose the failure reason when the command failed', () {
      // Arrange
      final json = deviceCommandJson(failureReason: 'device offline');

      // Act
      final resource = DeviceCommandResponseResource.fromJson(json);

      // Assert
      expect(resource.failureReason, 'device offline');
    });
  });

  group('DeviceCommandResponseResource.typeAsEnum', () {
    test('should decode every supported api command type case insensitively', () {
      // Arrange
      final expected = <String, DeviceCommandType>{
        'STANDBY': DeviceCommandType.standby,
        'standby': DeviceCommandType.standby,
        'WAKE': DeviceCommandType.wake,
        'Wake': DeviceCommandType.wake,
        'RESTART': DeviceCommandType.restart,
        'restart': DeviceCommandType.restart,
      };

      for (final entry in expected.entries) {
        // Arrange
        final resource = DeviceCommandResponseResource.fromJson(<String, dynamic>{'type': entry.key});

        // Act / Assert
        expect(resource.typeAsEnum, entry.value, reason: 'type "${entry.key}"');
      }
    });

    test('should return null for an unsupported command type', () {
      // Arrange
      final resource =
          DeviceCommandResponseResource.fromJson(<String, dynamic>{'type': 'HIBERNATE'});

      // Act / Assert
      expect(resource.typeAsEnum, isNull);
    });

    test('should return null when the type is missing', () {
      // Arrange
      const json = <String, dynamic>{'id': 'cmd-1'};

      // Act
      final resource = DeviceCommandResponseResource.fromJson(json);

      // Assert
      expect(resource.typeAsEnum, isNull);
    });
  });

  group('DeviceStatusResponseResource.fromJson', () {
    test('should parse a well formed payload', () {
      // Arrange
      final json = deviceStatusJson();

      // Act
      final resource = DeviceStatusResponseResource.fromJson(json);

      // Assert
      expect(resource.deviceId, 'dev-1');
      expect(resource.status, 'ONLINE');
      expect(resource.lastSeenAt, DateTime.utc(2024, 2, 20, 8));
    });

    test('should fall back to the id key when deviceId is absent', () {
      // Arrange
      final json = deviceStatusJson(key: 'id', deviceId: 'dev-8');

      // Act
      final resource = DeviceStatusResponseResource.fromJson(json);

      // Assert
      expect(resource.deviceId, 'dev-8');
    });

    test('should prefer deviceId over id when both are present', () {
      // Arrange
      const json = <String, dynamic>{'deviceId': 'dev-1', 'id': 'other', 'status': 'ONLINE'};

      // Act
      final resource = DeviceStatusResponseResource.fromJson(json);

      // Assert
      expect(resource.deviceId, 'dev-1');
    });

    test('should fall back to an empty identifier and status when the payload is empty', () {
      // Arrange
      const json = <String, dynamic>{};

      // Act
      final resource = DeviceStatusResponseResource.fromJson(json);

      // Assert
      expect(resource.deviceId, '');
      expect(resource.status, '');
      expect(resource.lastSeenAt, isNull);
    });

    test('should return a null timestamp for an invalid date value', () {
      // Arrange
      const json = <String, dynamic>{'status': 'ONLINE', 'lastSeenAt': 'soon'};

      // Act
      final resource = DeviceStatusResponseResource.fromJson(json);

      // Assert
      expect(resource.lastSeenAt, isNull);
    });
  });

  group('DevicePairingResource.fromJson', () {
    test('should parse the device id and claim token', () {
      // Arrange
      final json = devicePairingJson(deviceId: 'dev-9', claimToken: 'token-1');

      // Act
      final resource = DevicePairingResource.fromJson(json);

      // Assert
      expect(resource.deviceId, 'dev-9');
      expect(resource.claimToken, 'token-1');
    });

    test('should keep a missing claim token as null', () {
      // Arrange
      final json = devicePairingJson(claimToken: null);

      // Act
      final resource = DevicePairingResource.fromJson(json);

      // Assert
      expect(resource.claimToken, isNull);
    });

    test('should coerce a non string claim token into its string form', () {
      // Arrange
      const json = <String, dynamic>{'deviceId': 'dev-9', 'claimToken': 12345};

      // Act
      final resource = DevicePairingResource.fromJson(json);

      // Assert
      expect(resource.claimToken, '12345');
    });

    test('should fall back to an empty device id when the payload is empty', () {
      // Arrange
      const json = <String, dynamic>{};

      // Act
      final resource = DevicePairingResource.fromJson(json);

      // Assert
      expect(resource.deviceId, '');
      expect(resource.claimToken, isNull);
    });
  });
}