class AuthenticatedUserResource {
  final String id;
  final String email;
  final String token;
  final String refreshToken;

  const AuthenticatedUserResource({
    required this.id,
    required this.email,
    required this.token,
    required this.refreshToken,
  });

  factory AuthenticatedUserResource.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUserResource(
      id: json['id'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'token': token,
        'refreshToken': refreshToken,
      };
}
