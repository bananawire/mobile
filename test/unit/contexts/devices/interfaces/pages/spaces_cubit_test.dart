import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/create_space.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_space.command.dart';
import 'package:mobile/devices/domain/model/commands/update_space_name.command.dart';
import 'package:mobile/devices/domain/model/queries/get_spaces_by_organization.query.dart';
import 'package:mobile/devices/domain/model/readmodels/space.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_name.valueobject.dart';
import 'package:mobile/devices/domain/services/spaces.command-service.dart';
import 'package:mobile/devices/domain/services/spaces.query-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/devices.gateway.dart';
import 'package:mobile/devices/interfaces/pages/spaces/spaces_cubit.dart';

class _MockSpacesQueryService extends Mock implements SpacesQueryService {}

class _MockSpacesCommandService extends Mock implements SpacesCommandService {}

class _MockDevicesGateway extends Mock implements DevicesGateway {}

SpaceReadModel _space({
  String id = 'space-1',
  String name = 'Main Bedroom',
  String organizationId = 'org-1',
}) {
  return SpaceReadModel(
    id: id,
    name: name,
    organizationId: organizationId,
    ownerUserId: 'user-1',
    createdAt: DateTime.utc(2024, 1, 15, 10),
    updatedAt: null,
  );
}

void main() {
  late SpacesQueryService queryService;
  late SpacesCommandService commandService;
  late DevicesGateway devicesGateway;
  late SpacesCubit cubit;
  late List<SpacesState> emitted;

  setUpAll(() {
    registerFallbackValue(GetSpacesByOrganizationQuery(organizationId: OrganizationId('org')));
    registerFallbackValue(
      CreateSpaceCommand(
        organizationId: OrganizationId('org'),
        name: SpaceName('nm'),
      ),
    );
    registerFallbackValue(
      UpdateSpaceNameCommand(spaceId: SpaceId('space'), name: SpaceName('nm')),
    );
    registerFallbackValue(DeleteSpaceCommand(spaceId: SpaceId('space')));
  });

  setUp(() {
    queryService = _MockSpacesQueryService();
    commandService = _MockSpacesCommandService();
    devicesGateway = _MockDevicesGateway();
    cubit = SpacesCubit(queryService, commandService, devicesGateway);
    emitted = <SpacesState>[];
    cubit.stream.listen(emitted.add);
    when(() => devicesGateway.getDeviceCountBySpace(any())).thenAnswer((_) async => 0);
  });

  tearDown(() {
    cubit.close();
  });

  Future<void> loadTwoSpaces() async {
    when(() => queryService.handleGetSpacesByOrganization(any())).thenAnswer(
      (_) async => Right([_space(), _space(id: 'space-2', name: 'Garage')]),
    );
    await cubit.loadSpaces(organizationId: 'org-1');
  }

  group('SpacesCubit initial state', () {
    test('should start idle without spaces, counts or error', () {
      // Arrange / Act
      final state = cubit.state;

      // Assert
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.spaces, isEmpty);
      expect(state.deviceCountsBySpaceId, isEmpty);
    });
  });

  group('SpacesCubit.loadSpaces', () {
    test('should emit loading then the spaces with their device counts on success', () async {
      // Arrange
      when(() => queryService.handleGetSpacesByOrganization(any())).thenAnswer(
        (_) async => Right([_space(), _space(id: 'space-2', name: 'Garage')]),
      );
      when(() => devicesGateway.getDeviceCountBySpace('space-1')).thenAnswer((_) async => 3);
      when(() => devicesGateway.getDeviceCountBySpace('space-2')).thenAnswer((_) async => 0);

      // Act
      await cubit.loadSpaces(organizationId: 'org-1');

      // Assert
      expect(emitted.first.isLoading, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.spaces.map((s) => s.id), ['space-1', 'space-2']);
      expect(cubit.state.deviceCountsBySpaceId, {'space-1': 3, 'space-2': 0});
    });

    test('should query the spaces of the given organization', () async {
      // Arrange
      when(() => queryService.handleGetSpacesByOrganization(any()))
          .thenAnswer((_) async => const Right(<SpaceReadModel>[]));

      // Act
      await cubit.loadSpaces(organizationId: 'org-1');

      // Assert
      final captured =
          verify(() => queryService.handleGetSpacesByOrganization(captureAny())).captured;
      final query = captured.single as GetSpacesByOrganizationQuery;
      expect(query.organizationId.value, 'org-1');
    });

    test('should emit the failure message and no spaces when the query fails', () async {
      // Arrange
      when(() => queryService.handleGetSpacesByOrganization(any()))
          .thenAnswer((_) async => const Left(Failure('Not found.')));

      // Act
      await cubit.loadSpaces(organizationId: 'org-1');

      // Assert
      expect(emitted.first.isLoading, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, 'Not found.');
      expect(cubit.state.spaces, isEmpty);
    });

    test('should clear a previous error message on the next successful load', () async {
      // Arrange
      when(() => queryService.handleGetSpacesByOrganization(any()))
          .thenAnswer((_) async => const Left(Failure('Not found.')));
      await cubit.loadSpaces(organizationId: 'org-1');
      expect(cubit.state.errorMessage, 'Not found.');

      // Act
      await loadTwoSpaces();

      // Assert
      expect(cubit.state.errorMessage, isNull);
    });

    test('should default the device count to zero when the count lookup throws', () async {
      // Arrange
      when(() => queryService.handleGetSpacesByOrganization(any()))
          .thenAnswer((_) async => Right([_space()]));
      when(() => devicesGateway.getDeviceCountBySpace(any())).thenThrow(Exception('count failed'));

      // Act
      await cubit.loadSpaces(organizationId: 'org-1');

      // Assert
      expect(cubit.state.spaces, hasLength(1));
      expect(cubit.state.deviceCountsBySpaceId, {'space-1': 0});
      expect(cubit.state.errorMessage, isNull);
    });

    test('should propagate an argument error when the organization id is blank', () async {
      // Arrange: loadSpaces has no validation guard around the value object.

      // Act / Assert
      await expectLater(
        cubit.loadSpaces(organizationId: '   '),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => queryService.handleGetSpacesByOrganization(any()));
    });
  });

  group('SpacesCubit.createSpace', () {
    test('should prepend the created space and load its device count', () async {
      // Arrange
      await loadTwoSpaces();
      when(() => commandService.handleCreateSpace(any()))
          .thenAnswer((_) async => Right(_space(id: 'space-9', name: 'Garage')));
      when(() => devicesGateway.getDeviceCountBySpace('space-9')).thenAnswer((_) async => 1);

      // Act
      await cubit.createSpace(organizationId: 'org-1', name: '  Garage  ');

      // Assert
      expect(cubit.state.spaces.map((s) => s.id), ['space-9', 'space-1', 'space-2']);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.deviceCountsBySpaceId['space-9'], 1);
      final captured = verify(() => commandService.handleCreateSpace(captureAny())).captured;
      final command = captured.single as CreateSpaceCommand;
      expect(command.name.value, 'Garage');
      expect(command.organizationId.value, 'org-1');
    });

    test('should emit the failure message when the creation is rejected', () async {
      // Arrange
      when(() => commandService.handleCreateSpace(any()))
          .thenAnswer((_) async => const Left(Failure('Conflict.')));

      // Act
      await cubit.createSpace(organizationId: 'org-1', name: 'Garage');

      // Assert
      expect(cubit.state.errorMessage, 'Conflict.');
      expect(cubit.state.spaces, isEmpty);
      expect(cubit.state.isLoading, isFalse);
    });

    test('should emit the validation message and never call the service for an invalid name', () async {
      // Arrange: an unstubbed mock throws if the cubit ever reaches the service.

      // Act
      await cubit.createSpace(organizationId: 'org-1', name: 'x');
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(cubit.state.errorMessage, 'Space name is too short');
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.spaces, isEmpty);
      verifyNever(() => commandService.handleCreateSpace(any()));
    });
  });

  group('SpacesCubit.deleteSpace', () {
    test('should remove the space and its device count on success', () async {
      // Arrange
      when(() => devicesGateway.getDeviceCountBySpace(any())).thenAnswer((_) async => 2);
      await loadTwoSpaces();
      when(() => commandService.handleDeleteSpace(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await cubit.deleteSpace('space-1');

      // Assert
      expect(cubit.state.spaces.map((s) => s.id), ['space-2']);
      expect(cubit.state.deviceCountsBySpaceId.containsKey('space-1'), isFalse);
      final captured = verify(() => commandService.handleDeleteSpace(captureAny())).captured;
      expect((captured.single as DeleteSpaceCommand).spaceId.value, 'space-1');
    });

    test('should keep the space and show the failure message when the deletion is rejected', () async {
      // Arrange
      await loadTwoSpaces();
      when(() => commandService.handleDeleteSpace(any()))
          .thenAnswer((_) async => const Left(Failure('Access denied.')));

      // Act
      await cubit.deleteSpace('space-1');

      // Assert
      expect(cubit.state.spaces.map((s) => s.id), ['space-1', 'space-2']);
      expect(cubit.state.errorMessage, 'Access denied.');
    });

    test('should emit the validation message and never call the service for a blank space id', () async {
      // Arrange / Act
      await cubit.deleteSpace('   ');

      // Assert
      expect(cubit.state.errorMessage, 'Space id is required');
      verifyNever(() => commandService.handleDeleteSpace(any()));
    });
  });

  group('SpacesCubit.updateSpaceName', () {
    test('should replace the name of the target space on success', () async {
      // Arrange
      await loadTwoSpaces();
      when(() => commandService.handleUpdateSpaceName(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await cubit.updateSpaceName(spaceId: 'space-1', name: '  Master Bedroom  ');

      // Assert
      expect(cubit.state.spaces.map((s) => s.name), ['  Master Bedroom  ', 'Garage']);
      expect(cubit.state.spaces.first.id, 'space-1');
      expect(cubit.state.spaces.first.organizationId, 'org-1');
      expect(cubit.state.errorMessage, isNull);
      final captured =
          verify(() => commandService.handleUpdateSpaceName(captureAny())).captured;
      final command = captured.single as UpdateSpaceNameCommand;
      expect(command.name.value, 'Master Bedroom');
    });

    test('should show the failure message and keep the old name when the rename is rejected', () async {
      // Arrange
      await loadTwoSpaces();
      when(() => commandService.handleUpdateSpaceName(any()))
          .thenAnswer((_) async => const Left(Failure('Conflict.')));

      // Act
      await cubit.updateSpaceName(spaceId: 'space-1', name: 'Master Bedroom');

      // Assert
      expect(cubit.state.errorMessage, 'Conflict.');
      expect(cubit.state.spaces.first.name, 'Main Bedroom');
    });

    test('should emit the validation message and never call the service for an invalid name', () async {
      // Arrange / Act
      await cubit.updateSpaceName(spaceId: 'space-1', name: 'x');

      // Assert
      expect(cubit.state.errorMessage, 'Space name is too short');
      verifyNever(() => commandService.handleUpdateSpaceName(any()));
    });
  });
}