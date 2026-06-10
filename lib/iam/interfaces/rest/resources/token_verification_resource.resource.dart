class TokenVerificationResource {
  final bool valid;
  final String? userId;
  final String? expiresAt;

  const TokenVerificationResource({
    required this.valid,
    this.userId,
    this.expiresAt,
  });

  factory TokenVerificationResource.fromJson(Map<String, dynamic> json) {
    return TokenVerificationResource(
      valid: json['valid'] as bool,
      userId: json['userId'] as String?,
      expiresAt: json['expiresAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'valid': valid,
        'userId': userId,
        'expiresAt': expiresAt,
      };
}
