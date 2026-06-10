class SpaceId {
  final String value;

  factory SpaceId(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Space id is required');
    }
    return SpaceId._(value);
  }

  const SpaceId._(this.value);
}
