import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/devices/application/internal/queryservices/spaces_query_service_impl.dart';
import 'package:mobile/devices/domain/model/queries/get_spaces_by_organization.query.dart';
import 'package:mobile/devices/domain/model/readmodels/space.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/infrastructure/api/gateways/spaces.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/create_space_request.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/space_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_space_name_request.resource.dart';

import '../helpers/device_fixtures.dart';

class _MockSpacesGateway extends Mock implements SpacesGateway {}

void main() {
  late SpacesGateway gateway;
  late SpacesQueryServiceImpl sut;

  setUpAll(() {
    registerFallbackValue(CreateSpaceRequestResource(organizationId: 'org', name: 'nm'));
    registerFallbackValue(UpdateSpaceNameRequestResource(name: 'nm'));
    registerFallbackValue(SpaceResponseResource(
      id: 'space',
      name: 'name',
      organizationId: 'org',
      ownerUserId: null,
      createdAt: null,
      updatedAt: null,
    ));
  });

  setUp(() {
    gateway = _MockSpacesGateway();
    sut = SpacesQueryServiceImpl(gateway);
  });

  group('SpacesQueryServiceImpl.handleGetSpacesByOrganization', () {
    test('should return every space mapped when the gateway answers', () async {
      // Arrange
      when(() => gateway.getSpacesByOrganization(organizationId: any(named: 'organizationId'))).thenAnswer(
        (_) async => [
          SpaceResponseResource.fromJson(spaceResourceJson(id: 'space-1', name: 'Main Bedroom')),
          SpaceResponseResource.fromJson(spaceResourceJson(id: 'space-2', name: 'Garage')),
        ],
      );
      final query = GetSpacesByOrganizationQuery(organizationId: OrganizationId('org-1'));

      // Act
      final result = await sut.handleGetSpacesByOrganization(query);

      // Assert
      final spaces = result.fold((_) => null, (value) => value);
      expect(spaces, hasLength(2));
      expect(spaces!.first, isA<SpaceReadModel>());
      expect(spaces.map((s) => s.id), ['space-1', 'space-2']);
      expect(spaces.first.name, 'Main Bedroom');
      expect(spaces.first.organizationId, 'org-1');
      expect(spaces.last.name, 'Garage');
    });

    test('should ask the gateway for the given organization id', () async {
      // Arrange
      when(() => gateway.getSpacesByOrganization(organizationId: any(named: 'organizationId')))
          .thenAnswer((_) async => []);
      final query = GetSpacesByOrganizationQuery(organizationId: OrganizationId('org-1'));

      // Act
      await sut.handleGetSpacesByOrganization(query);

      // Assert
      final captured = verify(
        () => gateway.getSpacesByOrganization(organizationId: captureAny(named: 'organizationId')),
      ).captured;
      expect(captured.single, 'org-1');
    });

    test('should return an empty list when the organization has no spaces', () async {
      // Arrange
      when(() => gateway.getSpacesByOrganization(organizationId: any(named: 'organizationId')))
          .thenAnswer((_) async => []);
      final query = GetSpacesByOrganizationQuery(organizationId: OrganizationId('org-1'));

      // Act
      final result = await sut.handleGetSpacesByOrganization(query);

      // Assert
      final spaces = result.fold((_) => null, (value) => value);
      expect(spaces, isEmpty);
    });

    test('should translate each mapped dio status code into its failure message', () async {
      // Arrange
      const expected = <int, String>{
        401: 'Session expired. Please sign in again.',
        403: 'Access denied.',
        404: 'Not found.',
        500: 'Server error. Please try again later.',
        502: 'Server error. Please try again later.',
        503: 'Server error. Please try again later.',
        400: 'Network error. Please check your connection.',
      };
      final query = GetSpacesByOrganizationQuery(organizationId: OrganizationId('org-1'));

      for (final entry in expected.entries) {
        when(() => gateway.getSpacesByOrganization(organizationId: any(named: 'organizationId')))
            .thenThrow(dioError(entry.key));

        // Act
        final result = await sut.handleGetSpacesByOrganization(query);

        // Assert
        final failure = result.fold((f) => f, (_) => null);
        expect(failure!.message, entry.value, reason: 'status ${entry.key}');
      }
    });

    test('should surface the gateway exception message as the failure', () async {
      // Arrange
      when(() => gateway.getSpacesByOrganization(organizationId: any(named: 'organizationId')))
          .thenThrow(Exception('Unexpected spaces response format'));
      final query = GetSpacesByOrganizationQuery(organizationId: OrganizationId('org-1'));

      // Act
      final result = await sut.handleGetSpacesByOrganization(query);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Unexpected spaces response format');
    });

    test('should never write while listing spaces', () async {
      // Arrange
      when(() => gateway.getSpacesByOrganization(organizationId: any(named: 'organizationId')))
          .thenAnswer((_) async => []);
      final query = GetSpacesByOrganizationQuery(organizationId: OrganizationId('org-1'));

      // Act
      await sut.handleGetSpacesByOrganization(query);

      // Assert
      verifyNever(
        () => gateway.createSpace(organizationId: any(named: 'organizationId'), resource: any(named: 'resource')),
      );
      verifyNever(() => gateway.deleteSpace(any()));
      verifyNever(() => gateway.updateSpaceName(any(), any()));
    });
  });

  group('SpacesQueryServiceImpl.handleGetSpaceById', () {
    test('should return the space read model when the gateway answers', () async {
      // Arrange
      when(() => gateway.getSpaceById(any())).thenAnswer(
        (_) async => SpaceResponseResource.fromJson(spaceResourceJson(id: 'space-3', name: 'Attic')),
      );

      // Act
      final result = await sut.handleGetSpaceById('space-3');

      // Assert
      final space = result.fold((_) => null, (value) => value);
      expect(space!.id, 'space-3');
      expect(space.name, 'Attic');
      expect(space.organizationId, 'org-1');
      expect(space.ownerUserId, 'user-1');
    });

    test('should ask the gateway for the given space id', () async {
      // Arrange
      when(() => gateway.getSpaceById(any())).thenAnswer(
        (_) async => SpaceResponseResource.fromJson(spaceResourceJson()),
      );

      // Act
      await sut.handleGetSpaceById('space-3');

      // Assert
      final captured = verify(() => gateway.getSpaceById(captureAny())).captured;
      expect(captured.single, 'space-3');
    });

    test('should report a not found failure for a missing space', () async {
      // Arrange
      when(() => gateway.getSpaceById(any())).thenThrow(dioError(404));

      // Act
      final result = await sut.handleGetSpaceById('missing');

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Not found.');
    });
  });
}