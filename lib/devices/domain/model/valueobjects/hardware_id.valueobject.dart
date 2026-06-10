class HardwareId {
  final String value;

  factory HardwareId(String value) {
    final v = value.trim();
    if (v.isEmpty) {
      throw ArgumentError('Hardware ID is required');
    }
    return HardwareId._(v);
  }

  const HardwareId._(this.value);
}
