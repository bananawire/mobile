import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/devices/domain/model/commands/delete_device.command.dart';
import 'package:mobile/devices/domain/model/commands/queue_device_command.command.dart';
import 'package:mobile/devices/domain/model/commands/update_device_name.command.dart';
import 'package:mobile/devices/domain/model/commands/write_device_threshold.command.dart';
import 'package:mobile/devices/domain/model/queries/get_device_by_id.query.dart';
import 'package:mobile/devices/domain/model/queries/get_device_thresholds.query.dart';
import 'package:mobile/devices/domain/model/readmodels/device_threshold.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_command_type.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_name.valueobject.dart';
import 'package:mobile/devices/domain/services/device_threshold.command-service.dart';
import 'package:mobile/devices/domain/services/device_threshold.query-service.dart';
import 'package:mobile/devices/domain/services/devices.command-service.dart';
import 'package:mobile/devices/domain/services/devices.query-service.dart';
import 'package:mobile/devices/domain/services/device_commands.command-service.dart';
import 'package:mobile/devices/application/internal/acl/device_vitals_acl.dart';
import 'package:mobile/devices/interfaces/pages/device_detail/device_detail_view_model.dart';
import 'package:mobile/devices/interfaces/rest/transform/device_detail_threshold_defaults_transform.dart';
import 'package:mobile/devices/interfaces/rest/transform/device_thresholds_transform.dart';

part 'device_detail_state.dart';

class DeviceDetailCubit extends Cubit<DeviceDetailState> {
  final DevicesQueryService _devicesQueryService;
  final DevicesCommandService _devicesCommandService;
  final DeviceThresholdQueryService _thresholdQueryService;
  final DeviceThresholdCommandService _thresholdCommandService;
  final DeviceVitalsAcl _vitalsAcl;
  final DeviceCommandsCommandService _deviceCommandsCommandService;
  String? _currentDeviceId;

  DeviceDetailCubit(
    this._devicesQueryService,
    this._devicesCommandService,
    this._thresholdQueryService,
    this._thresholdCommandService,
    this._vitalsAcl,
    this._deviceCommandsCommandService,
  ) : super(const DeviceDetailState());

  Future<void> loadDeviceDetail(String deviceId) async {
    _currentDeviceId = deviceId;
    emit(state.copyWith(isLoading: true, errorMessage: null, notificationMessage: null));

    final deviceIdVo = DeviceId(deviceId);
    final deviceResult = await _devicesQueryService.handleGetDeviceById(
      GetDeviceByIdQuery(deviceId: deviceIdVo),
    );
    await deviceResult.fold(
      (failure) async {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (device) async {
        final thresholds = await _loadThresholds(deviceId);
        final vitalsResult = await _vitalsAcl.fetchLatestVitals(deviceIdVo);
        final vitals = vitalsResult.getOrElse(
          (_) => const DeviceVitalsSnapshot(
            connectivityDbm: 0,
            uptimeHours: 0,
            deviceHealthPercent: 0,
            lastUpdateHours: 0,
          ),
        );

        final detail = DeviceDetailViewModel(
          id: device.id,
          name: device.name.isNotEmpty ? device.name : 'Device',
          status: device.status,
          isPoweredOn: device.status.toUpperCase() == 'ONLINE',
          connectivityDbm: vitals.connectivityDbm,
          uptimeHours: vitals.uptimeHours,
          deviceHealthPercent: vitals.deviceHealthPercent,
          lastUpdateHours: vitals.lastUpdateHours,
          thresholds: thresholds,
        );

        emit(state.copyWith(isLoading: false, device: detail, errorMessage: null));
      },
    );
  }

  Future<bool> saveThresholds({
    required String deviceId,
    required List<DeviceDetailThresholdViewModel> thresholds,
  }) async {
    if (thresholds.isEmpty) {
      emit(state.copyWith(errorMessage: 'No thresholds to save.'));
      return false;
    }

    emit(state.copyWith(isSavingThresholds: true, errorMessage: null));

    final existingResult = await _thresholdQueryService.handleGetDeviceThresholds(
      GetDeviceThresholdsQuery(deviceId: deviceId),
    );

    final existingMetrics = existingResult.fold(
      (_) => <MetricThreshold>{},
      (items) => items.map((e) => e.metric).toSet(),
    );

    for (final threshold in thresholds) {
      final intent = existingMetrics.contains(threshold.metric)
          ? DeviceThresholdWriteIntent.update
          : DeviceThresholdWriteIntent.create;

      final command = toWriteDeviceThresholdCommand(
        deviceId: deviceId,
        metric: threshold.metric,
        value: threshold.value,
        enabled: threshold.enabled,
        intent: intent,
      );

      final saveResult = await _thresholdCommandService.handleWriteThreshold(command);
      final failedMessage = saveResult.fold((failure) => failure.message, (_) => null);

      if (failedMessage != null) {
        emit(state.copyWith(isSavingThresholds: false, errorMessage: failedMessage));
        return false;
      }
    }

    await loadDeviceDetail(deviceId);
    emit(state.copyWith(isSavingThresholds: false, errorMessage: null));
    return true;
  }

  Future<List<DeviceDetailThresholdViewModel>> _loadThresholds(String deviceId) async {
    final query = GetDeviceThresholdsQuery(deviceId: deviceId);
    final result = await _thresholdQueryService.handleGetDeviceThresholds(query);

    return result.fold(
      (_) => buildDefaultDeviceDetailThresholdResources(),
      (items) => _mergeWithDefaults(items),
    );
  }

  List<DeviceDetailThresholdViewModel> _mergeWithDefaults(List<DeviceThresholdReadModel> backendItems) {
    final map = <MetricThreshold, DeviceDetailThresholdViewModel>{
      for (final t in buildDefaultDeviceDetailThresholdResources()) t.metric: t,
    };

    for (final item in backendItems) {
      map[item.metric] = DeviceDetailThresholdViewModel(
        metric: item.metric,
        label: item.metricLabel.isNotEmpty ? item.metricLabel : _labelFor(item.metric),
        value: item.value,
        unit: item.metricUnit.isNotEmpty ? item.metricUnit : item.metric.unit,
        enabled: item.enabled,
      );
    }

    return MetricThreshold.values
        .where(map.containsKey)
        .map((metric) => map[metric]!)
        .toList();
  }

  String _labelFor(MetricThreshold metric) {
    switch (metric) {
      case MetricThreshold.pm25:
        return 'PM2.5';
      case MetricThreshold.co2:
        return 'CO₂';
      case MetricThreshold.temperature:
        return 'TEMP';
      case MetricThreshold.humidity:
        return 'HUMIDITY';
    }
  }

  // vitals are provided by Evaluation BC via ACL

  Future<void> updateDeviceName(String deviceId, String name) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, notificationMessage: null));
    try {
      final result = await _devicesCommandService.handleUpdateDeviceName(
        UpdateDeviceNameCommand(
          deviceId: DeviceId(deviceId),
          name: DeviceName(name),
        ),
      );
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (_) async {
          if (_currentDeviceId != null) {
            await loadDeviceDetail(_currentDeviceId!);
          }
        },
      );
    } on ArgumentError catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message as String?));
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, notificationMessage: null));
    try {
      final result = await _devicesCommandService.handleDeleteDevice(
        DeleteDeviceCommand(deviceId: DeviceId(deviceId)),
      );
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (_) => emit(state.copyWith(isLoading: false, deleted: true)),
      );
    } on ArgumentError catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message as String?));
    }
  }

  Future<void> toggleDevicePower(String deviceId) async {
    final device = state.device;
    if (device == null) return;
    if (state.isTogglingPower) return;
    emit(state.copyWith(isTogglingPower: true, errorMessage: null, notificationMessage: null));

    final type = device.status.toUpperCase() == 'ONLINE'
        ? DeviceCommandType.standby
        : DeviceCommandType.wake;

    final result = await _deviceCommandsCommandService.handleQueueDeviceCommand(
      QueueDeviceCommandCommand(
        deviceId: DeviceId(deviceId),
        type: type,
        payload: null,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(isTogglingPower: false, errorMessage: failure.message)),
      (created) => emit(
        state.copyWith(
          isTogglingPower: false,
          notificationMessage: 'Command queued: ${created.type.apiValue}',
        ),
      ),
    );
  }

  void clearNotification() {
    if (state.notificationMessage == null) return;
    emit(state.copyWith(notificationMessage: null));
  }
}
