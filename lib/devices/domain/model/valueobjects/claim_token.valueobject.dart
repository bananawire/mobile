class ClaimToken {
  final String value;

  factory ClaimToken(String value) {
    final v = value.trim();
    if (v.isEmpty) {
      throw ArgumentError('Claim token is required');
    }
    return ClaimToken._(v);
  }

  const ClaimToken._(this.value);
}
