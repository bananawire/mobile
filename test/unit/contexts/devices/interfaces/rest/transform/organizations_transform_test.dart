import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/commands/create_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/update_organization_name.command.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_name.valueobject.dart';
import 'package:mobile/devices/interfaces/rest/transform/organizations_transform.dart';

void main() {
  group('toCreateOrganizationRequestResource', () {
    test('should serialize the trimmed organization name under the name key', () {
      // Arrange
      final command = CreateOrganizationCommand(name: OrganizationName('  Acme Corp  '));

      // Act
      final resource = toCreateOrganizationRequestResource(command);

      // Assert
      expect(resource.name, 'Acme Corp');
      expect(resource.toJson(), <String, dynamic>{'name': 'Acme Corp'});
      expect(resource.toJson().keys, ['name']);
    });

    test('should serialize a name at the maximum accepted length unchanged', () {
      // Arrange
      final name = 'z' * 64;
      final command = CreateOrganizationCommand(name: OrganizationName(name));

      // Act
      final body = toCreateOrganizationRequestResource(command).toJson();

      // Assert
      expect(body['name'], name);
    });
  });

  group('toUpdateOrganizationNameRequestResource', () {
    test('should serialize the trimmed new name under the name key', () {
      // Arrange
      final command = UpdateOrganizationNameCommand(
        organizationId: OrganizationId('org-1'),
        name: OrganizationName('\t Renamed \n'),
      );

      // Act
      final resource = toUpdateOrganizationNameRequestResource(command);

      // Assert
      expect(resource.name, 'Renamed');
      expect(resource.toJson(), <String, dynamic>{'name': 'Renamed'});
    });

    test('should not include the organization id in the rename body', () {
      // Arrange
      final command = UpdateOrganizationNameCommand(
        organizationId: OrganizationId('org-1'),
        name: OrganizationName('Renamed'),
      );

      // Act
      final body = toUpdateOrganizationNameRequestResource(command).toJson();

      // Assert
      expect(body.containsKey('organizationId'), isFalse);
    });
  });
}