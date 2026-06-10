class EmailAddress {
  final String address;

  factory EmailAddress(String address) {
    if (address.isEmpty) {
      throw ArgumentError('Email address cannot be empty');
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(address)) {
      throw ArgumentError('Invalid email address format');
    }
    return EmailAddress._(address);
  }

  const EmailAddress._(this.address);

  @override
  String toString() => address;
}
