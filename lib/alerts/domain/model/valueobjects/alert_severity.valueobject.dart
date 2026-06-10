enum AlertSeverity {
  critical,
  warning,
  low;

  String get apiValue => name.toUpperCase();

  static AlertSeverity? fromString(String value) {
    try {
      return AlertSeverity.values.firstWhere(
            (e) => e.apiValue == value.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
