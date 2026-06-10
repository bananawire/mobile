class Password {
  final String value;

  factory Password(String value) {
    if (value.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }
    if (value.length < 8 || value.length > 128) {
      throw ArgumentError('Password must be between 8 and 128 characters');
    }
    final pattern = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$');
    if (!pattern.hasMatch(value)) {
      throw ArgumentError(
        'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character',
      );
    }
    return Password._(value);
  }

  const Password._(this.value);

  @override
  String toString() => value;
}
