import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/create_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/update_organization_name.command.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/services/organizations.command-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/organizations.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/organization_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/transform/organizations_transform.dart';

class OrganizationsCommandServiceImpl implements OrganizationsCommandService {
  final OrganizationsGateway _gateway;

  OrganizationsCommandServiceImpl(this._gateway);

  @override
  Future<Either<Failure, OrganizationReadModel>> handleCreateOrganization(
    CreateOrganizationCommand command,
  ) async {
    try {
      final resource = toCreateOrganizationRequestResource(command);
      final result = await _gateway.createOrganization(resource);
      return Right(_toReadModel(result));
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  OrganizationReadModel _toReadModel(OrganizationResponseResource resource) {
    return OrganizationReadModel(
      id: resource.id,
      name: resource.name,
      ownerUserId: resource.ownerUserId,
      createdAt: resource.createdAt,
      updatedAt: resource.updatedAt,
    );
  }

  @override
  Future<Either<Failure, void>> handleDeleteOrganization(
    DeleteOrganizationCommand command,
  ) async {
    try {
      await _gateway.deleteOrganization(command.organizationId.value);
      return const Right(null);
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> handleUpdateOrganizationName(
    UpdateOrganizationNameCommand command,
  ) async {
    try {
      final resource = toUpdateOrganizationNameRequestResource(command);
      await _gateway.updateOrganizationName(command.organizationId.value, resource);
      return const Right(null);
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  String _mapError(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
