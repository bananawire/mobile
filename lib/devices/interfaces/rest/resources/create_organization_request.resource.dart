class CreateOrganizationRequestResource {
  final String name;

  const CreateOrganizationRequestResource({required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
