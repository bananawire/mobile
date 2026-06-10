class SpaceReadModel {
  final String id;
  final String name;
  final String organizationId;
  final String? ownerUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SpaceReadModel({
    required this.id,
    required this.name,
    required this.organizationId,
    required this.ownerUserId,
    required this.createdAt,
    required this.updatedAt,
  });
}
