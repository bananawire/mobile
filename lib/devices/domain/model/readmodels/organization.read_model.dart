class OrganizationReadModel {
  final String id;
  final String name;
  final String? ownerUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrganizationReadModel({
    required this.id,
    required this.name,
    required this.ownerUserId,
    required this.createdAt,
    required this.updatedAt,
  });
}
