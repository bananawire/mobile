class AlertId {
  final String value;

  factory AlertId(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Alert ID is required');
    }
    return AlertId._(trimmed);
  }

  const AlertId._(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

