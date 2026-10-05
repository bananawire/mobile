import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/devices/application/internal/commandservices/organizations_command_service_impl.dart';
import 'package:mobile/devices/domain/model/commands/create_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/update_organization_name.command.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_name.valueobject.dart';
import 'package:mobile/devices/infrastructure/api/gateways/organizations.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/create_organization_request.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/organization_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_organization_name_request.resource.dart';

import '../helpers/device_fixtures.dart';

class _MockOrganizationsGateway extends Mock implements OrganizationsGateway {}

void main() {
  late OrganizationsGateway gateway;
  late OrganizationsCommandServiceImpl sut;

  setUpAll(() {
    registerFallbackValue(CreateOrganizationRequestResource(name: 'name'));
    registerFallbackValue(UpdateOrganizationNameRequestResource(name: 'name'));
    registerFallbackValue(OrganizationResponseResource(
      id: 'org',
      name: 'name',
      ownerUserId: null,
      createdAt: null,
      updatedAt: null,
    ));
  });

  setUp(() {
    gateway = _MockOrganizationsGateway();
    sut = OrganizationsCommandServiceImpl(gateway);
  });

  group('OrganizationsCommandServiceImpl.handleCreateOrganization', () {
    test('should return the created organization read model when the gateway answers', () async {
      // Arrange
      when(() => gateway.createOrganization(any())).thenAnswer(
        (_) async => OrganizationResponseResource.fromJson(
          organizationResourceJson(id: 'org-9', name: 'Umbrella Inc'),
        ),
      );
      final command = CreateOrganizationCommand(name: OrganizationName('Umbrella Inc'));

      // Act
      final result = await sut.handleCreateOrganization(command);

      // Assert
      final organization = result.fold((_) => null, (value) => value);
      expect(organization, isA<OrganizationReadModel>());
      expect(organization!.id, 'org-9');
      expect(organization.name, 'Umbrella Inc');
      expect(organization.ownerUserId, 'user-1');
      expect(organization.createdAt, DateTime.utc(2024, 1, 15, 10));
      expect(organization.updatedAt, DateTime.utc(2024, 2, 20, 8, 5));
    });

    test('should submit the trimmed organization name as the create body', () async {
      // Arrange
      when(() => gateway.createOrganization(any())).thenAnswer(
        (_) async => OrganizationResponseResource.fromJson(organizationResourceJson()),
      );
      final command = CreateOrganizationCommand(name: OrganizationName('  Umbrella Inc '));

      // Act
      await sut.handleCreateOrganization(command);

      // Assert
      final captured =
          verify(() => gateway.createOrganization(captureAny())).captured;
      final resource = captured.single as CreateOrganizationRequestResource;
      expect(resource.name, 'Umbrella Inc');
    });

    test('should never reach the gateway when the organization name is too short', () {
      // Arrange / Act
      CreateOrganizationCommand buildCommand() =>
          CreateOrganizationCommand(name: OrganizationName('A'));

      // Assert
      expect(buildCommand, throwsA(isA<ArgumentError>()));
      verifyNever(() => gateway.createOrganization(any()));
    });

    test('should surface the gateway exception message when the name already exists', () async {
      // Arrange
      when(() => gateway.createOrganization(any()))
          .thenThrow(Exception('Organization name already in use'));
      final command = CreateOrganizationCommand(name: OrganizationName('Acme Corp'));

      // Act
      final result = await sut.handleCreateOrganization(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Organization name already in use');
    });

    test('should not translate dio status codes into human messages', () async {
      // Arrange
      when(() => gateway.createOrganization(any())).thenThrow(dioError(409));
      final command = CreateOrganizationCommand(name: OrganizationName('Acme Corp'));

      // Act
      final result = await sut.handleCreateOrganization(command);

      // Assert: documents that this command service has no status code mapping.
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, startsWith('DioException'));
      expect(failure.message, isNot(contains('Conflict.')));
    });

    test('should never perform a read while creating an organization', () async {
      // Arrange
      when(() => gateway.createOrganization(any())).thenAnswer(
        (_) async => OrganizationResponseResource.fromJson(organizationResourceJson()),
      );
      final command = CreateOrganizationCommand(name: OrganizationName('Acme Corp'));

      // Act
      await sut.handleCreateOrganization(command);

      // Assert
      verifyNever(() => gateway.getUserOrganizations());
      verifyNever(() => gateway.getOrganizationById(any()));
    });
  });

  group('OrganizationsCommandServiceImpl.handleDeleteOrganization', () {
    test('should return a successful right carrying no value when the organization is deleted', () async {
      // Arrange
      when(() => gateway.deleteOrganization(any())).thenAnswer((_) async {});
      final command = DeleteOrganizationCommand(organizationId: OrganizationId('org-1'));

      // Act
      final result = await sut.handleDeleteOrganization(command);

      // Assert
      expect(result.fold((_) => 'left', (_) => 'right'), 'right');
    });

    test('should delete the organization id exactly once', () async {
      // Arrange
      when(() => gateway.deleteOrganization(any())).thenAnswer((_) async {});
      final command = DeleteOrganizationCommand(organizationId: OrganizationId('org-1'));

      // Act
      await sut.handleDeleteOrganization(command);

      // Assert
      final verification = verify(() => gateway.deleteOrganization(captureAny()));
      expect(verification.captured.single, 'org-1');
      expect(verification.callCount, 1);
    });

    test('should surface the gateway exception message on a rejected deletion', () async {
      // Arrange
      when(() => gateway.deleteOrganization(any())).thenThrow(Exception('Organization still has spaces'));
      final command = DeleteOrganizationCommand(organizationId: OrganizationId('org-1'));

      // Act
      final result = await sut.handleDeleteOrganization(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Organization still has spaces');
    });
  });

  group('OrganizationsCommandServiceImpl.handleUpdateOrganizationName', () {
    test('should return a successful right carrying no value when the rename is accepted', () async {
      // Arrange
      when(() => gateway.updateOrganizationName(any(), any())).thenAnswer((_) async {});
      final command = UpdateOrganizationNameCommand(
        organizationId: OrganizationId('org-1'),
        name: OrganizationName('Renamed'),
      );

      // Act
      final result = await sut.handleUpdateOrganizationName(command);

      // Assert
      expect(result.fold((_) => 'left', (_) => 'right'), 'right');
    });

    test('should send the trimmed new name for the requested organization', () async {
      // Arrange
      when(() => gateway.updateOrganizationName(any(), any())).thenAnswer((_) async {});
      final command = UpdateOrganizationNameCommand(
        organizationId: OrganizationId('org-1'),
        name: OrganizationName('  Renamed  '),
      );

      // Act
      await sut.handleUpdateOrganizationName(command);

      // Assert
      final captured =
          verify(() => gateway.updateOrganizationName(captureAny(), captureAny())).captured;
      expect(captured[0], 'org-1');
      expect((captured[1] as UpdateOrganizationNameRequestResource).name, 'Renamed');
    });

    test('should surface the gateway exception message when the rename is rejected', () async {
      // Arrange
      when(() => gateway.updateOrganizationName(any(), any()))
          .thenThrow(Exception('Name must be unique'));
      final command = UpdateOrganizationNameCommand(
        organizationId: OrganizationId('org-1'),
        name: OrganizationName('Renamed'),
      );

      // Act
      final result = await sut.handleUpdateOrganizationName(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Name must be unique');
    });
  });
}