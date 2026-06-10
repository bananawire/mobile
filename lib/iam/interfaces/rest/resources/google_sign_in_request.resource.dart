class GoogleSignInRequestResource {
  final String idToken;

  const GoogleSignInRequestResource({
    required this.idToken,
  });

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
      };
}
