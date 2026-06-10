import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/commands/create_space.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_space.command.dart';
import 'package:mobile/devices/domain/model/commands/update_space_name.command.dart';
import 'package:mobile/devices/domain/model/readmodels/space.read_model.dart';
import 'package:mobile/devices/domain/services/spaces.command-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/spaces.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/space_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/transform/spaces_transform.dart';

class SpacesCommandServiceImpl implements SpacesCommandService {
  final SpacesGateway _gateway;

  SpacesCommandServiceImpl(this._gateway);

  @override
  Future<Either<Failure, SpaceReadModel>> handleCreateSpace(CreateSpaceCommand command) async {
    try {
      final resource = toCreateSpaceRequestResource(command);
      final result = await _gateway.createSpace(
        organizationId: command.organizationId.value,
        resource: resource,
      );
      return Right(_toReadModel(result));
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  SpaceReadModel _toReadModel(SpaceResponseResource resource) {
    return SpaceReadModel(
      id: resource.id,
      name: resource.name,
      organizationId: resource.organizationId,
      ownerUserId: resource.ownerUserId,
      createdAt: resource.createdAt,
      updatedAt: resource.updatedAt,
    );
  }

  @override
  Future<Either<Failure, void>> handleDeleteSpace(DeleteSpaceCommand command) async {
    try {
      await _gateway.deleteSpace(command.spaceId.value);
      return const Right(null);
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> handleUpdateSpaceName(UpdateSpaceNameCommand command) async {
    try {
      final resource = toUpdateSpaceNameRequestResource(command);
      await _gateway.updateSpaceName(command.spaceId.value, resource);
      return const Right(null);
    } catch (e) {
      return Left(Failure(_mapError(e)));
    }
  }

  String _mapError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      switch (statusCode) {
        case 400:
          return 'Invalid request.';
        case 401:
          return 'Session expired. Please sign in again.';
        case 403:
          return 'Access denied.';
        case 404:
          return 'Not found.';
        case 409:
          return 'Conflict.';
        case 500:
        case 502:
        case 503:
          return 'Server error. Please try again later.';
        default:
          return 'Network error. Please check your connection.';
      }
    }
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
