class CreateSpaceRequestResource {
  final String organizationId;
  final String name;

  const CreateSpaceRequestResource({
    required this.organizationId,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'organizationId': organizationId,
      'name': name,
    };
  }
}
