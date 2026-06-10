class NotificationId {
  final String value;

  factory NotificationId(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Notification ID is required');
    }
    return NotificationId._(value);
  }

  const NotificationId._(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
