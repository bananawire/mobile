part of 'spaces_cubit.dart';

class SpacesState {
  final bool isLoading;
  final String? errorMessage;
  final List<SpaceReadModel> spaces;
  final Map<String, int> deviceCountsBySpaceId;

  const SpacesState({
    this.isLoading = false,
    this.errorMessage,
    this.spaces = const [],
    this.deviceCountsBySpaceId = const {},
  });

  SpacesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SpaceReadModel>? spaces,
    Map<String, int>? deviceCountsBySpaceId,
  }) {
    return SpacesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      spaces: spaces ?? this.spaces,
      deviceCountsBySpaceId: deviceCountsBySpaceId ?? this.deviceCountsBySpaceId,
    );
  }
}
