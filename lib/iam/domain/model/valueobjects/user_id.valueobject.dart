class UserId {
  final String id;

  factory UserId(String id) {
    if (id.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    if (!uuidPattern.hasMatch(id)) {
      throw ArgumentError('User ID must be a valid UUID');
    }
    return UserId._(id);
  }

  const UserId._(this.id);

  @override
  String toString() => id;
}
