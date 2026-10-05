import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/commands/create_space.command.dart';
import 'package:mobile/devices/domain/model/commands/update_space_name.command.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_name.valueobject.dart';
import 'package:mobile/devices/interfaces/rest/transform/spaces_transform.dart';

void main() {
  group('toCreateSpaceRequestResource', () {
    test('should serialize the organization id and the trimmed space name', () {
      // Arrange
      final command = CreateSpaceCommand(
        organizationId: OrganizationId('org-1'),
        name: SpaceName('  Main Bedroom  '),
      );

      // Act
      final resource = toCreateSpaceRequestResource(command);

      // Assert
      expect(resource.organizationId, 'org-1');
      expect(resource.name, 'Main Bedroom');
      expect(resource.toJson(), <String, dynamic>{
        'organizationId': 'org-1',
        'name': 'Main Bedroom',
      });
    });

    test('should keep the unpadded organization id verbatim', () {
      // Arrange
      final command = CreateSpaceCommand(
        organizationId: OrganizationId(' org-1 '),
        name: SpaceName('Garage'),
      );

      // Act
      final body = toCreateSpaceRequestResource(command).toJson();

      // Assert
      expect(body['organizationId'], ' org-1 ');
    });

    test('should not leak extra keys into the create space body', () {
      // Arrange
      final command = CreateSpaceCommand(
        organizationId: OrganizationId('org-1'),
        name: SpaceName('Garage'),
      );

      // Act
      final body = toCreateSpaceRequestResource(command).toJson();

      // Assert
      expect(body.keys, ['organizationId', 'name']);
    });
  });

  group('toUpdateSpaceNameRequestResource', () {
    test('should serialize the trimmed name under the name key only', () {
      // Arrange
      final command = UpdateSpaceNameCommand(
        spaceId: SpaceId('space-1'),
        name: SpaceName('  Renamed  '),
      );

      // Act
      final resource = toUpdateSpaceNameRequestResource(command);

      // Assert
      expect(resource.name, 'Renamed');
      expect(resource.toJson(), <String, dynamic>{'name': 'Renamed'});
      expect(resource.toJson().keys, ['name']);
    });

    test('should not include the space id in the rename body', () {
      // Arrange
      final command = UpdateSpaceNameCommand(
        spaceId: SpaceId('space-1'),
        name: SpaceName('Renamed'),
      );

      // Act
      final body = toUpdateSpaceNameRequestResource(command).toJson();

      // Assert
      expect(body.containsKey('spaceId'), isFalse);
    });
  });
}