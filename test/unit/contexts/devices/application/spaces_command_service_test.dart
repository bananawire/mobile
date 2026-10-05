import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/devices/application/internal/commandservices/spaces_command_service_impl.dart';
import 'package:mobile/devices/domain/model/commands/create_space.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_space.command.dart';
import 'package:mobile/devices/domain/model/commands/update_space_name.command.dart';
import 'package:mobile/devices/domain/model/readmodels/space.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_name.valueobject.dart';
import 'package:mobile/devices/infrastructure/api/gateways/spaces.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/create_space_request.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/space_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_space_name_request.resource.dart';

import '../helpers/device_fixtures.dart';

class _MockSpacesGateway extends Mock implements SpacesGateway {}

void main() {
  late SpacesGateway gateway;
  late SpacesCommandServiceImpl sut;

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
    sut = SpacesCommandServiceImpl(gateway);
  });

  group('SpacesCommandServiceImpl.handleCreateSpace', () {
    test('should return the created space read model when the gateway answers', () async {
      // Arrange
      when(
        () => gateway.createSpace(
          organizationId: any(named: 'organizationId'),
          resource: any(named: 'resource'),
        ),
      ).thenAnswer(
        (_) async => SpaceResponseResource.fromJson(spaceResourceJson(id: 'space-9', name: 'Garage')),
      );
      final command = CreateSpaceCommand(
        organizationId: OrganizationId('org-1'),
        name: SpaceName(' Garage '),
      );

      // Act
      final result = await sut.handleCreateSpace(command);

      // Assert
      final space = result.fold((_) => null, (value) => value);
      expect(space, isA<SpaceReadModel>());
      expect(space!.id, 'space-9');
      expect(space.name, 'Garage');
      expect(space.organizationId, 'org-1');
      expect(space.ownerUserId, 'user-1');
      expect(space.createdAt, DateTime.utc(2024, 1, 15, 10));
      expect(space.updatedAt, DateTime.utc(2024, 2, 20, 8, 5));
    });

    test('should create the space under the command organization id and trimmed name', () async {
      // Arrange
      when(
        () => gateway.createSpace(
          organizationId: any(named: 'organizationId'),
          resource: any(named: 'resource'),
        ),
      ).thenAnswer((_) async => SpaceResponseResource.fromJson(spaceResourceJson()));
      final command = CreateSpaceCommand(
        organizationId: OrganizationId(' org-1 '),
        name: SpaceName(' Garage '),
      );

      // Act
      await sut.handleCreateSpace(command);

      // Assert
      final captured = verify(
        () => gateway.createSpace(
          organizationId: captureAny(named: 'organizationId'),
          resource: captureAny(named: 'resource'),
        ),
      ).captured;
      expect(captured[0], ' org-1 ');
      final resource = captured[1] as CreateSpaceRequestResource;
      expect(resource.organizationId, ' org-1 ');
      expect(resource.name, 'Garage');
    });

    test('should translate each dio status code into its documented failure message', () async {
      // Arrange
      const expected = <int, String>{
        400: 'Invalid request.',
        401: 'Session expired. Please sign in again.',
        403: 'Access denied.',
        404: 'Not found.',
        409: 'Conflict.',
        500: 'Server error. Please try again later.',
        502: 'Server error. Please try again later.',
        503: 'Server error. Please try again later.',
        429: 'Network error. Please check your connection.',
      };
      final command = CreateSpaceCommand(
        organizationId: OrganizationId('org-1'),
        name: SpaceName('Garage'),
      );

      for (final entry in expected.entries) {
        when(
          () => gateway.createSpace(
            organizationId: any(named: 'organizationId'),
            resource: any(named: 'resource'),
          ),
        ).thenThrow(dioError(entry.key));

        // Act
        final result = await sut.handleCreateSpace(command);

        // Assert
        final failure = result.fold((f) => f, (_) => null);
        expect(failure!.message, entry.value, reason: 'status ${entry.key}');
      }
    });

    test('should never reach the gateway when the space name is invalid', () {
      // Arrange
      final organizationId = OrganizationId('org-1');

      // Act
      CreateSpaceCommand buildCommand() =>
          CreateSpaceCommand(organizationId: organizationId, name: SpaceName('x'));

      // Assert
      expect(buildCommand, throwsA(isA<ArgumentError>()));
      verifyNever(
        () => gateway.createSpace(
          organizationId: any(named: 'organizationId'),
          resource: any(named: 'resource'),
        ),
      );
    });

    test('should never perform a read while creating a space', () async {
      // Arrange
      when(
        () => gateway.createSpace(
          organizationId: any(named: 'organizationId'),
          resource: any(named: 'resource'),
        ),
      ).thenAnswer((_) async => SpaceResponseResource.fromJson(spaceResourceJson()));
      final command = CreateSpaceCommand(
        organizationId: OrganizationId('org-1'),
        name: SpaceName('Garage'),
      );

      // Act
      await sut.handleCreateSpace(command);

      // Assert
      verifyNever(() => gateway.getSpacesByOrganization(organizationId: any(named: 'organizationId')));
      verifyNever(() => gateway.getSpaceById(any()));
    });
  });

  group('SpacesCommandServiceImpl.handleDeleteSpace', () {
    test('should return a successful right carrying no value when the space is deleted', () async {
      // Arrange
      when(() => gateway.deleteSpace(any())).thenAnswer((_) async {});
      final command = DeleteSpaceCommand(spaceId: SpaceId('space-1'));

      // Act
      final result = await sut.handleDeleteSpace(command);

      // Assert
      expect(result.fold((_) => 'left', (_) => 'right'), 'right');
    });

    test('should delete the space id exactly once', () async {
      // Arrange
      when(() => gateway.deleteSpace(any())).thenAnswer((_) async {});
      final command = DeleteSpaceCommand(spaceId: SpaceId('space-1'));

      // Act
      await sut.handleDeleteSpace(command);

      // Assert
      final verification = verify(() => gateway.deleteSpace(captureAny()));
      expect(verification.captured.single, 'space-1');
      expect(verification.callCount, 1);
    });

    test('should report an access denied failure when the space belongs to someone else', () async {
      // Arrange
      when(() => gateway.deleteSpace(any())).thenThrow(dioError(403));
      final command = DeleteSpaceCommand(spaceId: SpaceId('space-1'));

      // Act
      final result = await sut.handleDeleteSpace(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Access denied.');
    });
  });

  group('SpacesCommandServiceImpl.handleUpdateSpaceName', () {
    test('should return a successful right carrying no value when the rename is accepted', () async {
      // Arrange
      when(() => gateway.updateSpaceName(any(), any())).thenAnswer((_) async {});
      final command = UpdateSpaceNameCommand(
        spaceId: SpaceId('space-1'),
        name: SpaceName('Renamed'),
      );

      // Act
      final result = await sut.handleUpdateSpaceName(command);

      // Assert
      expect(result.fold((_) => 'left', (_) => 'right'), 'right');
    });

    test('should send the trimmed new name for the requested space', () async {
      // Arrange
      when(() => gateway.updateSpaceName(any(), any())).thenAnswer((_) async {});
      final command = UpdateSpaceNameCommand(
        spaceId: SpaceId('space-1'),
        name: SpaceName(' Renamed '),
      );

      // Act
      await sut.handleUpdateSpaceName(command);

      // Assert
      final captured =
          verify(() => gateway.updateSpaceName(captureAny(), captureAny())).captured;
      expect(captured[0], 'space-1');
      expect((captured[1] as UpdateSpaceNameRequestResource).name, 'Renamed');
    });

    test('should report an invalid request failure for a rejected rename', () async {
      // Arrange
      when(() => gateway.updateSpaceName(any(), any())).thenThrow(dioError(400));
      final command = UpdateSpaceNameCommand(
        spaceId: SpaceId('space-1'),
        name: SpaceName('Renamed'),
      );

      // Act
      final result = await sut.handleUpdateSpaceName(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Invalid request.');
    });
  });
}