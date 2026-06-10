class RefreshTokenRequestResource {
  final String refreshToken;

  const RefreshTokenRequestResource({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}
