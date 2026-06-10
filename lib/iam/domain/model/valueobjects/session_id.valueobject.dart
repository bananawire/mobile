class SessionId {
  final String id;

  factory SessionId(String id) {
    if (id.isEmpty) {
      throw ArgumentError('Session ID cannot be empty');
    }
    try {
      // Validate UUID format
      final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      if (!uuidPattern.hasMatch(id)) {
        throw ArgumentError('Session ID must be a valid UUID');
      }
    } catch (e) {
      throw ArgumentError('Session ID must be a valid UUID');
    }
    return SessionId._(id);
  }

  const SessionId._(this.id);

  @override
  String toString() => id;
}
