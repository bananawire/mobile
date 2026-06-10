class OrganizationResponseResource {
  final String id;
  final String name;
  final String? ownerUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrganizationResponseResource({
    required this.id,
    required this.name,
    required this.ownerUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganizationResponseResource.fromJson(Map<String, dynamic> json) {
    return OrganizationResponseResource(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      ownerUserId: json['ownerUserId']?.toString(),
      createdAt: _tryParseDateTime(json['createdAt']),
      updatedAt: _tryParseDateTime(json['updatedAt']),
    );
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
