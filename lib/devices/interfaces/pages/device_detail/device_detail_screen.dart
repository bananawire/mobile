import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/devices/interfaces/pages/device_detail/device_detail_cubit.dart';
import 'package:mobile/devices/interfaces/widgets/device_detail_header.dart';
import 'package:mobile/devices/interfaces/widgets/device_detail_metrics_grid.dart';
import 'package:mobile/devices/interfaces/widgets/device_thresholds_editor_dialog.dart';
import 'package:mobile/devices/interfaces/widgets/device_thresholds_section.dart';
import 'package:mobile/devices/interfaces/widgets/edit_device_name_form.dart';
import 'package:mobile/shared/interfaces/widgets/widgets.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String deviceId;

  const DeviceDetailScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DeviceDetailCubit>().loadDeviceDetail(widget.deviceId);
  }

  Future<void> _openEditDeviceNameSheet(BuildContext context, String deviceId, String currentName) async {
    final cubit = context.read<DeviceDetailCubit>();
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
            child: BlocBuilder<DeviceDetailCubit, DeviceDetailState>(
              builder: (context, state) {
                return EditDeviceNameForm(
                  isLoading: state.isLoading,
                  initialName: currentName,
                  onSubmit: (name) async {
                    await cubit.updateDeviceName(deviceId, name);
                    if (context.mounted) {
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

  Future<void> _confirmDeleteDevice(BuildContext context, String deviceId, String deviceName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Delete device', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to delete "$deviceName"? This action will reset the device assignment.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<DeviceDetailCubit>().deleteDevice(deviceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ClairAppBar(),
      body: SafeArea(
        child: BlocConsumer<DeviceDetailCubit, DeviceDetailState>(
          listenWhen: (previous, current) {
            return previous.errorMessage != current.errorMessage ||
                previous.notificationMessage != current.notificationMessage;
          },
          listener: (context, state) {
            final error = state.errorMessage;
            if (error != null && error.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                _clairSnackBar(
                  context,
                  message: error,
                  variant: _ClairSnackBarVariant.error,
                ),
              );
            }

            final note = state.notificationMessage;
            if (note != null && note.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                _clairSnackBar(context, message: note),
              );
              context.read<DeviceDetailCubit>().clearNotification();
            }
          },
          buildWhen: (previous, current) {
            // Avoid rebuilding the whole page for transient snackbars.
            return previous.isTogglingPower != current.isTogglingPower ||
                previous.isSavingThresholds != current.isSavingThresholds ||
                previous.isLoading != current.isLoading ||
                previous.deleted != current.deleted ||
                previous.device != current.device;
          },
          builder: (context, state) {
            if (state.deleted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go('/spaces');
                }
              });
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isLoading && state.device == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final device = state.device;
            if (device == null) {
              return const Center(
                child: Text(
                  'Device not found',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                  const SizedBox(height: 12),
                  DeviceDetailHeader(
                    device: device,
                    onPowerToggle: state.isTogglingPower
                        ? null
                        : () => context.read<DeviceDetailCubit>().toggleDevicePower(device.id),
                    onEdit: () {
                      final device = state.device;
                      if (device != null) {
                        _openEditDeviceNameSheet(context, device.id, device.name);
                      }
                    },
                    onDelete: () {
                      final device = state.device;
                      if (device != null) {
                        _confirmDeleteDevice(context, device.id, device.name);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  DeviceDetailMetricsGrid(device: device),
                  const SizedBox(height: 28),
                  DeviceThresholdsSection(
                    thresholds: device.thresholds,
                    onEditTap: () async {
                      final saved = await showDialog<bool>(
                        context: context,
                        barrierDismissible: !state.isSavingThresholds,
                        builder: (_) => DeviceThresholdsEditorDialog(
                          initialThresholds: device.thresholds,
                          onSave: (thresholds) {
                            return context.read<DeviceDetailCubit>().saveThresholds(
                                  deviceId: device.id,
                                  thresholds: thresholds,
                                );
                          },
                        ),
                      );

                      if (saved == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Thresholds saved successfully.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  SnackBar _clairSnackBar(
    BuildContext context, {
    required String message,
    _ClairSnackBarVariant variant = _ClairSnackBarVariant.info,
  }) {
    final bg = switch (variant) {
      _ClairSnackBarVariant.info => const Color(0xFF151515),
      _ClairSnackBarVariant.error => const Color(0xFF2A1111),
    };

    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      backgroundColor: bg,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.white70,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
  }
}

enum _ClairSnackBarVariant {
  info,
  error,
}
