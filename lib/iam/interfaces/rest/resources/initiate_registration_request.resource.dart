class InitiateRegistrationRequestResource {
  final String email;
  final String password;

  const InitiateRegistrationRequestResource({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
