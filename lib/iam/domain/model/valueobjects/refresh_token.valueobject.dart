class RefreshToken {
  final String token;

  factory RefreshToken(String token) {
    if (token.isEmpty) {
      throw ArgumentError('Refresh token cannot be empty');
    }
    return RefreshToken._(token);
  }

  const RefreshToken._(this.token);

  @override
  String toString() => token;
}
