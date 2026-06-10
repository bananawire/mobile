import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/devices/infrastructure/api/gateways/devices.gateway.dart';
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

part 'spaces_state.dart';

class SpacesCubit extends Cubit<SpacesState> {
  final SpacesQueryService _queryService;
  final SpacesCommandService _commandService;
  final DevicesGateway _devicesGateway;

  SpacesCubit(this._queryService, this._commandService, this._devicesGateway)
      : super(const SpacesState());

  Future<void> loadSpaces({required String organizationId}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final query = GetSpacesByOrganizationQuery(
      organizationId: OrganizationId(organizationId),
    );
    final result = await _queryService.handleGetSpacesByOrganization(query);
    await result.fold(
      (failure) async {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (spaces) async {
        emit(state.copyWith(isLoading: false, spaces: spaces));
        await _loadDeviceCounts(spaces);
      },
    );
  }

  Future<void> createSpace({required String organizationId, required String name}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final command = CreateSpaceCommand(
        organizationId: OrganizationId(organizationId),
        name: SpaceName(name),
      );
      final result = await _commandService.handleCreateSpace(command);
      await result.fold(
        (failure) async {
          emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        },
        (created) async {
          final updated = [created, ...state.spaces];
          emit(state.copyWith(isLoading: false, spaces: updated));
          // fetch count for new space
          await _loadDeviceCounts([created]);
        },
      );
    } on ArgumentError catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message as String?));
    }
  }

  Future<void> deleteSpace(String spaceId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final command = DeleteSpaceCommand(spaceId: SpaceId(spaceId));
      final result = await _commandService.handleDeleteSpace(command);
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (_) {
          final updated = state.spaces.where((s) => s.id != spaceId).toList();
          final counts = Map<String, int>.from(state.deviceCountsBySpaceId)..remove(spaceId);
          emit(state.copyWith(isLoading: false, spaces: updated, deviceCountsBySpaceId: counts));
        },
      );
    } on ArgumentError catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message as String?));
    }
  }

  Future<void> updateSpaceName({required String spaceId, required String name}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final command = UpdateSpaceNameCommand(spaceId: SpaceId(spaceId), name: SpaceName(name));
      final result = await _commandService.handleUpdateSpaceName(command);
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (_) {
          final updated = state.spaces
              .map((s) => s.id == spaceId
                  ? SpaceReadModel(
                      id: s.id,
                      name: name,
                      organizationId: s.organizationId,
                      ownerUserId: s.ownerUserId,
                      createdAt: s.createdAt,
                      updatedAt: s.updatedAt,
                    )
                  : s)
              .toList();
          emit(state.copyWith(isLoading: false, spaces: updated));
        },
      );
    } on ArgumentError catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message as String?));
    }
  }

  Future<void> _loadDeviceCounts(List<SpaceReadModel> spaces) async {
    final counts = Map<String, int>.from(state.deviceCountsBySpaceId);

    final futures = spaces.map((space) async {
      try {
        final count = await _devicesGateway.getDeviceCountBySpace(space.id);
        return MapEntry(space.id, count);
      } catch (_) {
        return MapEntry(space.id, 0);
      }
    });

    final results = await Future.wait(futures);
    for (final entry in results) {
      counts[entry.key] = entry.value;
    }

    emit(state.copyWith(deviceCountsBySpaceId: counts));
  }
}
