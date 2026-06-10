class OrganizationId {
  final String value;

  factory OrganizationId(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Organization id is required');
    }
    return OrganizationId._(value);
  }

  const OrganizationId._(this.value);
}
