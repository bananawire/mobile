import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/devices/interfaces/pages/spaces/spaces_cubit.dart';
import 'package:mobile/devices/interfaces/widgets/create_space_form.dart';
import 'package:mobile/devices/interfaces/widgets/edit_space_name_form.dart';
import 'package:mobile/devices/interfaces/widgets/space_card.dart';
import 'package:mobile/shared/interfaces/widgets/widgets.dart';

class SpacesScreen extends StatefulWidget {
  final String organizationId;
  final String? organizationName;

  const SpacesScreen({
    super.key,
    required this.organizationId,
    this.organizationName,
  });

  @override
  State<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends State<SpacesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SpacesCubit>().loadSpaces(organizationId: widget.organizationId);
  }

  Future<void> _openCreateSpaceSheet(BuildContext context) async {
    final cubit = context.read<SpacesCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: BlocBuilder<SpacesCubit, SpacesState>(
              builder: (context, state) {
                return CreateSpaceForm(
                  isLoading: state.isLoading,
                  onSubmit: (name) async {
                    await cubit.createSpace(
                      organizationId: widget.organizationId,
                      name: name,
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEditSpaceSheet({
    required BuildContext context,
    required String spaceId,
    required String currentName,
  }) async {
    final cubit = context.read<SpacesCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: BlocBuilder<SpacesCubit, SpacesState>(
              builder: (context, state) {
                return EditSpaceNameForm(
                  isLoading: state.isLoading,
                  initialName: currentName,
                  onSubmit: (name) async {
                    await cubit.updateSpaceName(spaceId: spaceId, name: name);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteSpace({
    required BuildContext context,
    required String spaceId,
    required String spaceName,
  }) async {
    final cubit = context.read<SpacesCubit>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete space?'),
          content: Text('This will delete "$spaceName".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await cubit.deleteSpace(spaceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.organizationName ?? 'Spaces';
    return Scaffold(
      appBar: const ClairAppBar(),
      body: SafeArea(
        child: BlocBuilder<SpacesCubit, SpacesState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // When this route is reached via `go()`, there may be nothing to pop.
                          if (context.canPop()) {
                            context.pop();
                            return;
                          }
                          context.go('/spaces');
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Create space',
                        onPressed: state.isLoading ? null : () => _openCreateSpaceSheet(context),
                        icon: const Icon(Icons.add, color: Colors.white70),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state.isLoading && state.spaces.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                      if (state.errorMessage != null && state.spaces.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              state.errorMessage!,
                              style: const TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (state.spaces.isEmpty) {
                        return const Center(
                          child: Text(
                            'No spaces yet',
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }

                        return RefreshIndicator(
                          onRefresh: () => context.read<SpacesCubit>().loadSpaces(
                                organizationId: widget.organizationId,
                              ),
                          child: ListView.separated(
                            padding: const EdgeInsets.only(top: 4),
                            itemCount: state.spaces.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final space = state.spaces[index];
                              final count = state.deviceCountsBySpaceId[space.id];
                              return SpaceCard(
                                name: space.name,
                                deviceCount: count,
                                onEdit: () => _openEditSpaceSheet(
                                  context: context,
                                  spaceId: space.id,
                                  currentName: space.name,
                                ),
                                onDelete: () => _confirmDeleteSpace(
                                  context: context,
                                  spaceId: space.id,
                                  spaceName: space.name,
                                ),
                                onOpen: () => context.go(
                                  '/spaces/${widget.organizationId}/${space.id}',
                                  extra: space.name,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
