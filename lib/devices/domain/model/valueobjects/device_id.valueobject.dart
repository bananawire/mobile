class DeviceId {
  final String value;

  factory DeviceId(String value) {
    final v = value.trim();
    if (v.isEmpty) {
      throw ArgumentError('Device id is required');
    }
    return DeviceId._(v);
  }

  const DeviceId._(this.value);
}
