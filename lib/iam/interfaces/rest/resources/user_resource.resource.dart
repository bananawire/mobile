class UserResource {
  final String id;
  final String email;

  const UserResource({
    required this.id,
    required this.email,
  });

  factory UserResource.fromJson(Map<String, dynamic> json) {
    return UserResource(
      id: json['id'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
      };
}
