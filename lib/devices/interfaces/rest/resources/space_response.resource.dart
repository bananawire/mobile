class SpaceResponseResource {
  final String id;
  final String name;
  final String organizationId;
  final String? ownerUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SpaceResponseResource({
    required this.id,
    required this.name,
    required this.organizationId,
    required this.ownerUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpaceResponseResource.fromJson(Map<String, dynamic> json) {
    return SpaceResponseResource(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      organizationId: (json['organizationId'] ?? '').toString(),
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
