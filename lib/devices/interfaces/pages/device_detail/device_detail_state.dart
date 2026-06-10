part of 'device_detail_cubit.dart';

class DeviceDetailState {
  final bool isLoading;
  final bool isSavingThresholds;
  final bool isTogglingPower;
  final bool deleted;
  final DeviceDetailViewModel? device;
  final String? errorMessage;
  final String? notificationMessage;

  const DeviceDetailState({
    this.isLoading = false,
    this.isSavingThresholds = false,
    this.isTogglingPower = false,
    this.deleted = false,
    this.device,
    this.errorMessage,
    this.notificationMessage,
  });

  DeviceDetailState copyWith({
    bool? isLoading,
    bool? isSavingThresholds,
    bool? isTogglingPower,
    bool? deleted,
    DeviceDetailViewModel? device,
    String? errorMessage,
    String? notificationMessage,
  }) {
    return DeviceDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSavingThresholds: isSavingThresholds ?? this.isSavingThresholds,
      isTogglingPower: isTogglingPower ?? this.isTogglingPower,
      deleted: deleted ?? this.deleted,
      device: device ?? this.device,
      errorMessage: errorMessage,
      notificationMessage: notificationMessage,
    );
  }
}
