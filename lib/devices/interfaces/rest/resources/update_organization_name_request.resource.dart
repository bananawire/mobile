class UpdateOrganizationNameRequestResource {
  final String name;

  const UpdateOrganizationNameRequestResource({required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
