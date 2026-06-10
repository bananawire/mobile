import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/model/queries/get_user_organizations.query.dart';
import 'package:mobile/devices/domain/services/organizations.query-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/organizations.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/organization_response.resource.dart';

class OrganizationsQueryServiceImpl implements OrganizationsQueryService {
  final OrganizationsGateway _gateway;

  OrganizationsQueryServiceImpl(this._gateway);

  @override
  Future<Either<Failure, List<OrganizationReadModel>>> handleGetUserOrganizations(
    GetUserOrganizationsQuery query,
  ) async {
    try {
      final result = await _gateway.getUserOrganizations();
      return Right(result.map(_toReadModel).toList());
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, OrganizationReadModel>> handleGetOrganizationById(String organizationId) async {
    try {
      final result = await _gateway.getOrganizationById(organizationId);
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

  String _mapError(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
