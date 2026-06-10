class DeviceName {
  final String value;

  factory DeviceName(String value) {
    final v = value.trim();
    if (v.isEmpty) {
      throw ArgumentError('Device name is required');
    }
    return DeviceName._(v);
  }

  const DeviceName._(this.value);
}
