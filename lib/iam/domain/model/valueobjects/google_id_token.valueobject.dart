class GoogleIdToken {
  final String token;

  factory GoogleIdToken(String token) {
    if (token.trim().isEmpty) {
      throw ArgumentError('Google ID token is required');
    }
    return GoogleIdToken._(token);
  }

  const GoogleIdToken._(this.token);
}
