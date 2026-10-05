import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/commands/claim_device_to_space.command.dart';
import 'package:mobile/devices/domain/model/commands/pair_device.command.dart';
import 'package:mobile/devices/domain/model/valueobjects/claim_token.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/hardware_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';
import 'package:mobile/devices/interfaces/rest/transform/devices_transform.dart';

void main() {
  group('toPairDeviceRequestResource', () {
    test('should serialize the trimmed hardware id under the hardwareId key', () {
      // Arrange
      final command = PairDeviceCommand(hardwareId: HardwareId('  HW-77  '));

      // Act
      final resource = toPairDeviceRequestResource(command);

      // Assert
      expect(resource.hardwareId, 'HW-77');
      expect(resource.toJson(), <String, dynamic>{'hardwareId': 'HW-77'});
    });

    test('should serialize the hardware id exactly once with no extra keys', () {
      // Arrange
      final command = PairDeviceCommand(hardwareId: HardwareId('HW-77'));

      // Act
      final body = toPairDeviceRequestResource(command).toJson();

      // Assert
      expect(body.keys, ['hardwareId']);
    });
  });

  group('toClaimDeviceRequestResource', () {
    test('should serialize the trimmed claim token and the raw space id', () {
      // Arrange
      final command = ClaimDeviceToSpaceCommand(
        claimToken: ClaimToken('  token-abc  '),
        spaceId: SpaceId('space-42'),
      );

      // Act
      final resource = toClaimDeviceRequestResource(command);

      // Assert
      expect(resource.claimToken, 'token-abc');
      expect(resource.spaceId, 'space-42');
      expect(resource.toJson(), <String, dynamic>{
        'claimToken': 'token-abc',
        'spaceId': 'space-42',
      });
    });

    test('should keep the unpadded space id verbatim because the value object does not trim', () {
      // Arrange
      final command = ClaimDeviceToSpaceCommand(
        claimToken: ClaimToken('token-abc'),
        spaceId: SpaceId(' space-42 '),
      );

      // Act
      final body = toClaimDeviceRequestResource(command).toJson();

      // Assert
      expect(body['spaceId'], ' space-42 ');
    });

    test('should not leak extra keys into the claim body', () {
      // Arrange
      final command = ClaimDeviceToSpaceCommand(
        claimToken: ClaimToken('token-abc'),
        spaceId: SpaceId('space-42'),
      );

      // Act
      final body = toClaimDeviceRequestResource(command).toJson();

      // Assert
      expect(body.keys, ['claimToken', 'spaceId']);
    });
  });
}