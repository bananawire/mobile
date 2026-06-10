class AlertId {
  final String value;

  factory AlertId(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Alert ID is required');
    }
    return AlertId._(value);
  }

  const AlertId._(this.value);
}
