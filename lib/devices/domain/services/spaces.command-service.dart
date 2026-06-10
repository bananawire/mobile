import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/create_space.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_space.command.dart';
import 'package:mobile/devices/domain/model/commands/update_space_name.command.dart';
import 'package:mobile/devices/domain/model/readmodels/space.read_model.dart';

abstract class SpacesCommandService {
  Future<Either<Failure, SpaceReadModel>> handleCreateSpace(
    CreateSpaceCommand command,
  );

  Future<Either<Failure, void>> handleDeleteSpace(
    DeleteSpaceCommand command,
  );

  Future<Either<Failure, void>> handleUpdateSpaceName(
    UpdateSpaceNameCommand command,
  );
}
