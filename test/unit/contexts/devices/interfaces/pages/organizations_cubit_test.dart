import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/create_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/update_organization_name.command.dart';
import 'package:mobile/devices/domain/model/queries/get_user_organizations.query.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_name.valueobject.dart';
import 'package:mobile/devices/domain/services/organizations.command-service.dart';
import 'package:mobile/devices/domain/services/organizations.query-service.dart';
import 'package:mobile/devices/interfaces/pages/organizations/organizations_cubit.dart';

class _MockOrganizationsQueryService extends Mock implements OrganizationsQueryService {}

class _MockOrganizationsCommandService extends Mock implements OrganizationsCommandService {}

OrganizationReadModel _organization({
  String id = 'org-1',
  String name = 'Acme Corp',
}) {
  return OrganizationReadModel(
    id: id,
    name: name,
    ownerUserId: 'user-1',
    createdAt: DateTime.utc(2024, 1, 15, 10),
    updatedAt: null,
  );
}

void main() {
  late OrganizationsQueryService queryService;
  late OrganizationsCommandService commandService;
  late OrganizationsCubit cubit;
  late List<OrganizationsState> emitted;

  setUpAll(() {
    registerFallbackValue(const GetUserOrganizationsQuery());
    registerFallbackValue(CreateOrganizationCommand(name: OrganizationName('nm')));
    registerFallbackValue(DeleteOrganizationCommand(organizationId: OrganizationId('org')));
    registerFallbackValue(
      UpdateOrganizationNameCommand(
        organizationId: OrganizationId('org'),
        name: OrganizationName('nm'),
      ),
    );
  });

  setUp(() {
    queryService = _MockOrganizationsQueryService();
    commandService = _MockOrganizationsCommandService();
    cubit = OrganizationsCubit(queryService, commandService);
    emitted = <OrganizationsState>[];
    cubit.stream.listen(emitted.add);
  });

  tearDown(() {
    cubit.close();
  });

  Future<void> loadTwoOrganizations() async {
    when(() => queryService.handleGetUserOrganizations(any())).thenAnswer(
      (_) async => Right([_organization(), _organization(id: 'org-2', name: 'Umbrella')]),
    );
    await cubit.loadOrganizations();
  }

  group('OrganizationsCubit initial state', () {
    test('should start idle without organizations or error', () {
      // Arrange / Act
      final state = cubit.state;

      // Assert
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.organizations, isEmpty);
    });
  });

  group('OrganizationsCubit.loadOrganizations', () {
    test('should emit loading then the organizations on success', () async {
      // Arrange
      await loadTwoOrganizations();

      // Assert
      expect(emitted.first.isLoading, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.organizations.map((o) => o.id), ['org-1', 'org-2']);
    });

    test('should query the organizations of the current user', () async {
      // Arrange
      when(() => queryService.handleGetUserOrganizations(any()))
          .thenAnswer((_) async => const Right(<OrganizationReadModel>[]));

      // Act
      await cubit.loadOrganizations();

      // Assert
      final captured =
          verify(() => queryService.handleGetUserOrganizations(captureAny())).captured;
      expect(captured.single, isA<GetUserOrganizationsQuery>());
    });

    test('should emit the failure message and no organizations when the query fails', () async {
      // Arrange
      when(() => queryService.handleGetUserOrganizations(any()))
          .thenAnswer((_) async => const Left(Failure('Session expired. Please sign in again.')));

      // Act
      await cubit.loadOrganizations();

      // Assert
      expect(emitted.first.isLoading, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, 'Session expired. Please sign in again.');
      expect(cubit.state.organizations, isEmpty);
    });

    test('should clear a previous error message on the next successful load', () async {
      // Arrange
      when(() => queryService.handleGetUserOrganizations(any()))
          .thenAnswer((_) async => const Left(Failure('Not found.')));
      await cubit.loadOrganizations();
      expect(cubit.state.errorMessage, 'Not found.');

      // Act
      await loadTwoOrganizations();

      // Assert
      expect(cubit.state.errorMessage, isNull);
    });
  });

  group('OrganizationsCubit.createOrganization', () {
    test('should prepend the created organization to the list', () async {
      // Arrange
      await loadTwoOrganizations();
      when(() => commandService.handleCreateOrganization(any()))
          .thenAnswer((_) async => Right(_organization(id: 'org-9', name: 'Globex')));

      // Act
      await cubit.createOrganization('  Globex  ');

      // Assert
      expect(cubit.state.organizations.map((o) => o.id), ['org-9', 'org-1', 'org-2']);
      expect(cubit.state.errorMessage, isNull);
      final captured =
          verify(() => commandService.handleCreateOrganization(captureAny())).captured;
      expect((captured.single as CreateOrganizationCommand).name.value, 'Globex');
    });

    test('should emit the failure message when the creation is rejected', () async {
      // Arrange
      when(() => commandService.handleCreateOrganization(any()))
          .thenAnswer((_) async => const Left(Failure('Name must be unique.')));

      // Act
      await cubit.createOrganization('Acme Corp');

      // Assert
      expect(cubit.state.errorMessage, 'Name must be unique.');
      expect(cubit.state.organizations, isEmpty);
      expect(cubit.state.isLoading, isFalse);
    });

    test('should emit the validation message and never call the service for a too short name', () async {
      // Arrange: an unstubbed mock throws if the cubit ever reaches the service.

      // Act
      await cubit.createOrganization('A');
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(cubit.state.errorMessage, 'Organization name is too short');
      expect(cubit.state.isLoading, isFalse);
      verifyNever(() => commandService.handleCreateOrganization(any()));
    });

    test('should emit the validation message and never call the service for a blank name', () async {
      // Arrange / Act
      await cubit.createOrganization('   ');
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(cubit.state.errorMessage, 'Organization name is required');
      verifyNever(() => commandService.handleCreateOrganization(any()));
    });
  });

  group('OrganizationsCubit.deleteOrganization', () {
    test('should remove the organization from the list on success', () async {
      // Arrange
      await loadTwoOrganizations();
      when(() => commandService.handleDeleteOrganization(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await cubit.deleteOrganization('org-1');

      // Assert
      expect(cubit.state.organizations.map((o) => o.id), ['org-2']);
      expect(cubit.state.errorMessage, isNull);
      final captured =
          verify(() => commandService.handleDeleteOrganization(captureAny())).captured;
      expect((captured.single as DeleteOrganizationCommand).organizationId.value, 'org-1');
    });

    test('should keep the organization and show the failure message when the deletion is rejected', () async {
      // Arrange
      await loadTwoOrganizations();
      when(() => commandService.handleDeleteOrganization(any()))
          .thenAnswer((_) async => const Left(Failure('Organization still has spaces.')));

      // Act
      await cubit.deleteOrganization('org-1');

      // Assert
      expect(cubit.state.organizations.map((o) => o.id), ['org-1', 'org-2']);
      expect(cubit.state.errorMessage, 'Organization still has spaces.');
    });

    test('should emit the validation message and never call the service for a blank id', () async {
      // Arrange / Act
      await cubit.deleteOrganization('  ');

      // Assert
      expect(cubit.state.errorMessage, 'Organization id is required');
      verifyNever(() => commandService.handleDeleteOrganization(any()));
    });
  });

  group('OrganizationsCubit.updateOrganizationName', () {
    test('should replace the name of the target organization on success', () async {
      // Arrange
      await loadTwoOrganizations();
      when(() => commandService.handleUpdateOrganizationName(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await cubit.updateOrganizationName(organizationId: 'org-1', name: '  Acme Holdings  ');

      // Assert
      expect(cubit.state.organizations.map((o) => o.name), ['  Acme Holdings  ', 'Umbrella']);
      expect(cubit.state.organizations.first.id, 'org-1');
      expect(cubit.state.organizations.first.ownerUserId, 'user-1');
      expect(cubit.state.errorMessage, isNull);
      final captured =
          verify(() => commandService.handleUpdateOrganizationName(captureAny())).captured;
      final command = captured.single as UpdateOrganizationNameCommand;
      expect(command.name.value, 'Acme Holdings');
    });

    test('should show the failure message and keep the old name when the rename is rejected', () async {
      // Arrange
      await loadTwoOrganizations();
      when(() => commandService.handleUpdateOrganizationName(any()))
          .thenAnswer((_) async => const Left(Failure('Name must be unique.')));

      // Act
      await cubit.updateOrganizationName(organizationId: 'org-1', name: 'Acme Holdings');

      // Assert
      expect(cubit.state.errorMessage, 'Name must be unique.');
      expect(cubit.state.organizations.first.name, 'Acme Corp');
    });

    test('should emit the validation message and never call the service for a too long name', () async {
      // Arrange / Act
      await cubit.updateOrganizationName(organizationId: 'org-1', name: 'x' * 65);

      // Assert
      expect(cubit.state.errorMessage, 'Organization name is too long');
      verifyNever(() => commandService.handleUpdateOrganizationName(any()));
    });
  });
}