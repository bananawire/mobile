import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/interfaces/rest/resources/organization_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/space_response.resource.dart';

import '../../../helpers/device_fixtures.dart';

void main() {
  group('SpaceResponseResource.fromJson', () {
    test('should parse every field of a well formed payload', () {
      // Arrange
      final json = spaceResourceJson();

      // Act
      final resource = SpaceResponseResource.fromJson(json);

      // Assert
      expect(resource.id, 'space-1');
      expect(resource.name, 'Main Bedroom');
      expect(resource.organizationId, 'org-1');
      expect(resource.ownerUserId, 'user-1');
      expect(resource.createdAt, DateTime.utc(2024, 1, 15, 10));
      expect(resource.updatedAt, DateTime.utc(2024, 2, 20, 8, 5));
    });

    test('should fall back to empty strings when required fields are missing', () {
      // Arrange
      const json = <String, dynamic>{'name': 'Main Bedroom'};

      // Act
      final resource = SpaceResponseResource.fromJson(json);

      // Assert
      expect(resource.id, '');
      expect(resource.organizationId, '');
      expect(resource.name, 'Main Bedroom');
    });

    test('should keep absent optional fields as null', () {
      // Arrange
      final json = spaceResourceJson(ownerUserId: null, createdAt: null, updatedAt: null);

      // Act
      final resource = SpaceResponseResource.fromJson(json);

      // Assert
      expect(resource.ownerUserId, isNull);
      expect(resource.createdAt, isNull);
      expect(resource.updatedAt, isNull);
    });

    test('should return a null timestamp for an invalid date value', () {
      // Arrange
      const json = <String, dynamic>{'createdAt': 'the other day'};

      // Act
      final resource = SpaceResponseResource.fromJson(json);

      // Assert
      expect(resource.createdAt, isNull);
    });

    test('should coerce a numeric identifier into its string form', () {
      // Arrange
      const json = <String, dynamic>{'id': 17, 'organizationId': 3};

      // Act
      final resource = SpaceResponseResource.fromJson(json);

      // Assert
      expect(resource.id, '17');
      expect(resource.organizationId, '3');
    });
  });

  group('OrganizationResponseResource.fromJson', () {
    test('should parse every field of a well formed payload', () {
      // Arrange
      final json = organizationResourceJson();

      // Act
      final resource = OrganizationResponseResource.fromJson(json);

      // Assert
      expect(resource.id, 'org-1');
      expect(resource.name, 'Acme Corp');
      expect(resource.ownerUserId, 'user-1');
      expect(resource.createdAt, DateTime.utc(2024, 1, 15, 10));
      expect(resource.updatedAt, DateTime.utc(2024, 2, 20, 8, 5));
    });

    test('should fall back to empty strings when required fields are missing', () {
      // Arrange
      const json = <String, dynamic>{};

      // Act
      final resource = OrganizationResponseResource.fromJson(json);

      // Assert
      expect(resource.id, '');
      expect(resource.name, '');
    });

    test('should keep absent optional fields as null', () {
      // Arrange
      final json = organizationResourceJson(ownerUserId: null, createdAt: null, updatedAt: null);

      // Act
      final resource = OrganizationResponseResource.fromJson(json);

      // Assert
      expect(resource.ownerUserId, isNull);
      expect(resource.createdAt, isNull);
      expect(resource.updatedAt, isNull);
    });

    test('should parse an explicit null timestamp as null', () {
      // Arrange
      const json = <String, dynamic>{'id': 'org-1', 'updatedAt': null};

      // Act
      final resource = OrganizationResponseResource.fromJson(json);

      // Assert
      expect(resource.updatedAt, isNull);
    });
  });
}