class VerificationCode {
  final String code;

  factory VerificationCode(String code) {
    if (code.isEmpty) {
      throw ArgumentError('Verification code cannot be empty');
    }
    final pattern = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}$');
    if (!pattern.hasMatch(code)) {
      throw ArgumentError('Verification code must be in format XXXX-XXXX (uppercase alphanumeric)');
    }
    return VerificationCode._(code);
  }

  const VerificationCode._(this.code);

  @override
  String toString() => code;
}
