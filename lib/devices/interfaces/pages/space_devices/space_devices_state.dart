part of 'space_devices_cubit.dart';

class SpaceDevicesState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool isGrid;
  final List<DeviceReadModel> devices;
  final int totalDevices;
  final int currentPage;
  final bool hasMore;

  const SpaceDevicesState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.isGrid = true,
    this.devices = const [],
    this.totalDevices = 0,
    this.currentPage = 0,
    this.hasMore = false,
  });

  SpaceDevicesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool? isGrid,
    List<DeviceReadModel>? devices,
    int? totalDevices,
    int? currentPage,
    bool? hasMore,
  }) {
    return SpaceDevicesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      isGrid: isGrid ?? this.isGrid,
      devices: devices ?? this.devices,
      totalDevices: totalDevices ?? this.totalDevices,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
