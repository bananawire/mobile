import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/devices/domain/model/commands/create_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/delete_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/update_organization_name.command.dart';
import 'package:mobile/devices/domain/model/queries/get_user_organizations.query.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_name.valueobject.dart';
import 'package:mobile/devices/domain/services/organizations.command-service.dart';
import 'package:mobile/devices/domain/services/organizations.query-service.dart';

part 'organizations_state.dart';

class OrganizationsCubit extends Cubit<OrganizationsState> {
  final OrganizationsQueryService _queryService;
  final OrganizationsCommandService _commandService;

  OrganizationsCubit(this._queryService, this._commandService) : super(const OrganizationsState());

  Future<void> loadOrganizations() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _queryService.handleGetUserOrganizations(const GetUserOrganizationsQuery());
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (orgs) => emit(state.copyWith(isLoading: false, organizations: orgs)),
    );
  }

  Future<void> createOrganization(String name) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final command = CreateOrganizationCommand(name: OrganizationName(name));
      final result = await _commandService.handleCreateOrganization(command);
      await result.fold(
        (failure) async {
          emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        },
        (created) async {
          final updated = [created, ...state.organizations];
          emit(state.copyWith(isLoading: false, organizations: updated));
        },
      );
    } on ArgumentError catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message as String?));
    }
  }

  Future<void> deleteOrganization(String organizationId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final command = DeleteOrganizationCommand(
        organizationId: OrganizationId(organizationId),
      );
      final result = await _commandService.handleDeleteOrganization(command);
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (_) {
          final updated = state.organizations.where((o) => o.id != organizationId).toList();
          emit(state.copyWith(isLoading: false, organizations: updated));
        },
      );
    } on ArgumentError catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message as String?));
    }
  }

  Future<void> updateOrganizationName({
    required String organizationId,
    required String name,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final command = UpdateOrganizationNameCommand(
        organizationId: OrganizationId(organizationId),
        name: OrganizationName(name),
      );
      final result = await _commandService.handleUpdateOrganizationName(command);
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (_) {
          final updated = state.organizations
              .map((o) => o.id == organizationId
                  ? OrganizationReadModel(
                      id: o.id,
                      name: name,
                      ownerUserId: o.ownerUserId,
                      createdAt: o.createdAt,
                      updatedAt: o.updatedAt,
                    )
                  : o)
              .toList();
          emit(state.copyWith(isLoading: false, organizations: updated));
        },
      );
    } on ArgumentError catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message as String?));
    }
  }
}
