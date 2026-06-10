class SpaceName {
  final String value;

  factory SpaceName(String value) {
    final v = value.trim();
    if (v.isEmpty) {
      throw ArgumentError('Space name is required');
    }
    if (v.length < 2) {
      throw ArgumentError('Space name is too short');
    }
    if (v.length > 64) {
      throw ArgumentError('Space name is too long');
    }
    return SpaceName._(v);
  }

  const SpaceName._(this.value);
}
