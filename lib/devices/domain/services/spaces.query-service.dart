import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/readmodels/space.read_model.dart';
import 'package:mobile/devices/domain/model/queries/get_spaces_by_organization.query.dart';

abstract class SpacesQueryService {
  Future<Either<Failure, List<SpaceReadModel>>> handleGetSpacesByOrganization(
    GetSpacesByOrganizationQuery query,
  );

  Future<Either<Failure, SpaceReadModel>> handleGetSpaceById(String spaceId);
}
