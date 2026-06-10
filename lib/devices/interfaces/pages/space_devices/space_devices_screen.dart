import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/app_router.dart';
import 'package:mobile/devices/interfaces/pages/space_devices/space_devices_cubit.dart';
import 'package:mobile/devices/interfaces/widgets/claim_device_form.dart';
import 'package:mobile/devices/interfaces/widgets/device_card.dart';
import 'package:mobile/devices/interfaces/widgets/device_layout_toggle.dart';
import 'package:mobile/devices/interfaces/widgets/device_list_tile.dart';
import 'package:mobile/devices/interfaces/widgets/pair_device_form.dart';
import 'package:mobile/shared/interfaces/widgets/widgets.dart';

class SpaceDevicesScreen extends StatefulWidget {
  final String spaceId;
  final String? spaceName;

  const SpaceDevicesScreen({
    super.key,
    required this.spaceId,
    this.spaceName,
  });

  @override
  State<SpaceDevicesScreen> createState() => _SpaceDevicesScreenState();
}

class _SpaceDevicesScreenState extends State<SpaceDevicesScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      AppRouter.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    context.read<SpaceDevicesCubit>().loadDevices(spaceId: widget.spaceId);
  }

  @override
  void initState() {
    super.initState();
    context.read<SpaceDevicesCubit>().loadDevices(spaceId: widget.spaceId);
  }

  Future<void> _openClaimDeviceSheet(BuildContext context) async {
    final cubit = context.read<SpaceDevicesCubit>();
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
            child: BlocBuilder<SpaceDevicesCubit, SpaceDevicesState>(
              builder: (context, state) {
                return ClaimDeviceForm(
                  isLoading: state.isLoading,
                  onSubmit: (token) async {
                    final claimed = await cubit.claimDeviceToSpace(
                      claimToken: token,
                      spaceId: widget.spaceId,
                    );
                    if (claimed != null && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _openPairDeviceSheet(BuildContext context) async {
    final cubit = context.read<SpaceDevicesCubit>();
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
            child: BlocBuilder<SpaceDevicesCubit, SpaceDevicesState>(
              builder: (context, state) {
                return PairDeviceForm(
                  isLoading: state.isLoading,
                  onSubmit: (hardwareId) async {
                    final pairing = await cubit.pairDevice(hardwareId: hardwareId);
                    if (!context.mounted) return;

                    if (pairing != null) {
                      Navigator.of(context).pop();
                      await showDialog<void>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Pairing started'),
                            content: Text(
                              pairing.claimToken == null || pairing.claimToken!.isEmpty
                                  ? 'No claim token returned.'
                                  : 'Claim token: ${pairing.claimToken}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.spaceName ?? 'Space';

    return Scaffold(
      appBar: const ClairAppBar(),
      body: SafeArea(
        child: BlocBuilder<SpaceDevicesCubit, SpaceDevicesState>(
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
                  const SizedBox(height: 6),
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
                        tooltip: 'Add device',
                        onPressed: state.isLoading ? null : () => _openClaimDeviceSheet(context),
                        icon: const Icon(Icons.add, color: Colors.black),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF21D07A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        tooltip: 'Pair device',
                        onPressed: state.isLoading ? null : () => _openPairDeviceSheet(context),
                        icon: const Icon(Icons.wifi_tethering_outlined, color: Colors.white70),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DeviceLayoutToggle(
                    isGrid: state.isGrid,
                    onGrid: () => context.read<SpaceDevicesCubit>().setLayoutGrid(true),
                    onList: () => context.read<SpaceDevicesCubit>().setLayoutGrid(false),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                      if (state.isLoading && state.devices.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.errorMessage != null && state.devices.isEmpty) {
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

                      if (state.devices.isEmpty) {
                        return const Center(
                          child: Text(
                            'No devices yet',
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }

                        return RefreshIndicator(
                          onRefresh: () => context.read<SpaceDevicesCubit>().loadDevices(
                                spaceId: widget.spaceId,
                              ),
                          child: state.isGrid
                              ? GridView.builder(
                                  padding: const EdgeInsets.only(top: 2),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.12,
                                  ),
                                  itemCount: state.devices.length,
                                  itemBuilder: (context, index) {
                                    return DeviceCard(device: state.devices[index]);
                                  },
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.only(top: 2),
                                  itemCount: state.devices.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    return DeviceListTile(device: state.devices[index]);
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
