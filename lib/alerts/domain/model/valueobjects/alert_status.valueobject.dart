enum AlertStatus {
  active,
  acknowledged,
  resolved;

  String get apiValue => name.toUpperCase();

  static AlertStatus? fromString(String value) {
    try {
      return AlertStatus.values.firstWhere(
            (e) => e.apiValue == value.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
