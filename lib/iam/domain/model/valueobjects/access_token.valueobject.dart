class AccessToken {
  final String token;

  factory AccessToken(String token) {
    if (token.isEmpty) {
      throw ArgumentError('Access token cannot be empty');
    }
    return AccessToken._(token);
  }

  const AccessToken._(this.token);

  @override
  String toString() => token;
}
