import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/model/queries/get_user_organizations.query.dart';

abstract class OrganizationsQueryService {
  Future<Either<Failure, List<OrganizationReadModel>>> handleGetUserOrganizations(
    GetUserOrganizationsQuery query,
  );

  Future<Either<Failure, OrganizationReadModel>> handleGetOrganizationById(String organizationId);
}
