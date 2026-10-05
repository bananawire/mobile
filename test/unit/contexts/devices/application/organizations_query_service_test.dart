import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/devices/application/internal/queryservices/organizations_query_service_impl.dart';
import 'package:mobile/devices/domain/model/queries/get_user_organizations.query.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/infrastructure/api/gateways/organizations.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/create_organization_request.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/organization_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_organization_name_request.resource.dart';

import '../helpers/device_fixtures.dart';

class _MockOrganizationsGateway extends Mock implements OrganizationsGateway {}

void main() {
  late OrganizationsGateway gateway;
  late OrganizationsQueryServiceImpl sut;

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
    sut = OrganizationsQueryServiceImpl(gateway);
  });

  group('OrganizationsQueryServiceImpl.handleGetUserOrganizations', () {
    test('should return every organization mapped when the gateway answers', () async {
      // Arrange
      when(() => gateway.getUserOrganizations()).thenAnswer(
        (_) async => [
          OrganizationResponseResource.fromJson(organizationResourceJson(id: 'org-1', name: 'Acme')),
          OrganizationResponseResource.fromJson(organizationResourceJson(id: 'org-2', name: 'Umbrella')),
        ],
      );

      // Act
      final result = await sut.handleGetUserOrganizations(const GetUserOrganizationsQuery());

      // Assert
      final organizations = result.fold((_) => null, (value) => value);
      expect(organizations, hasLength(2));
      expect(organizations!.first, isA<OrganizationReadModel>());
      expect(organizations.map((o) => o.id), ['org-1', 'org-2']);
      expect(organizations.first.ownerUserId, 'user-1');
      expect(organizations.first.createdAt, DateTime.utc(2024, 1, 15, 10));
    });

    test('should return an empty list when the user owns no organization', () async {
      // Arrange
      when(() => gateway.getUserOrganizations()).thenAnswer((_) async => []);

      // Act
      final result = await sut.handleGetUserOrganizations(const GetUserOrganizationsQuery());

      // Assert
      final organizations = result.fold((_) => null, (value) => value);
      expect(organizations, isEmpty);
    });

    test('should surface the gateway exception message as the failure', () async {
      // Arrange
      when(() => gateway.getUserOrganizations()).thenThrow(Exception('Token expired'));

      // Act
      final result = await sut.handleGetUserOrganizations(const GetUserOrganizationsQuery());

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Token expired');
    });

    test('should never write while listing organizations', () async {
      // Arrange
      when(() => gateway.getUserOrganizations()).thenAnswer((_) async => []);

      // Act
      await sut.handleGetUserOrganizations(const GetUserOrganizationsQuery());

      // Assert
      verifyNever(() => gateway.createOrganization(any()));
      verifyNever(() => gateway.deleteOrganization(any()));
      verifyNever(() => gateway.updateOrganizationName(any(), any()));
    });
  });

  group('OrganizationsQueryServiceImpl.handleGetOrganizationById', () {
    test('should return the organization read model when the gateway answers', () async {
      // Arrange
      when(() => gateway.getOrganizationById(any())).thenAnswer(
        (_) async => OrganizationResponseResource.fromJson(organizationResourceJson(id: 'org-7', name: 'Globex')),
      );

      // Act
      final result = await sut.handleGetOrganizationById('org-7');

      // Assert
      final organization = result.fold((_) => null, (value) => value);
      expect(organization!.id, 'org-7');
      expect(organization.name, 'Globex');
      expect(organization.updatedAt, DateTime.utc(2024, 2, 20, 8, 5));
    });

    test('should ask the gateway for the given organization id', () async {
      // Arrange
      when(() => gateway.getOrganizationById(any())).thenAnswer(
        (_) async => OrganizationResponseResource.fromJson(organizationResourceJson()),
      );

      // Act
      await sut.handleGetOrganizationById('org-7');

      // Assert
      final captured = verify(() => gateway.getOrganizationById(captureAny())).captured;
      expect(captured.single, 'org-7');
    });

    test('should return null timestamps when the payload omits them', () async {
      // Arrange
      when(() => gateway.getOrganizationById(any())).thenAnswer(
        (_) async => OrganizationResponseResource.fromJson(
          organizationResourceJson(ownerUserId: null, createdAt: null, updatedAt: null),
        ),
      );

      // Act
      final result = await sut.handleGetOrganizationById('org-7');

      // Assert
      final organization = result.fold((_) => null, (value) => value);
      expect(organization!.ownerUserId, isNull);
      expect(organization.createdAt, isNull);
      expect(organization.updatedAt, isNull);
    });

    test('should surface the gateway exception message for a missing organization', () async {
      // Arrange
      when(() => gateway.getOrganizationById(any())).thenThrow(dioError(404));

      // Act
      final result = await sut.handleGetOrganizationById('missing');

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, startsWith('DioException'));
      expect(failure.statusCode, isNull);
    });
  });
}