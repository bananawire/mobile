class OrganizationName {
  final String value;

  factory OrganizationName(String value) {
    final v = value.trim();
    if (v.isEmpty) {
      throw ArgumentError('Organization name is required');
    }
    if (v.length < 2) {
      throw ArgumentError('Organization name is too short');
    }
    if (v.length > 64) {
      throw ArgumentError('Organization name is too long');
    }
    return OrganizationName._(v);
  }

  const OrganizationName._(this.value);
}
