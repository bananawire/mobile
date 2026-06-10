import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/create_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/update_organization_name.command.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';

abstract class OrganizationsCommandService {
  Future<Either<Failure, OrganizationReadModel>> handleCreateOrganization(
    CreateOrganizationCommand command,
  );

  Future<Either<Failure, void>> handleDeleteOrganization(
    DeleteOrganizationCommand command,
  );

  Future<Either<Failure, void>> handleUpdateOrganizationName(
    UpdateOrganizationNameCommand command,
  );
}
