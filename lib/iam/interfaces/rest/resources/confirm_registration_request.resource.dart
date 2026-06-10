class ConfirmRegistrationRequestResource {
  final String sessionId;
  final String verificationCode;

  const ConfirmRegistrationRequestResource({
    required this.sessionId,
    required this.verificationCode,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'verificationCode': verificationCode,
      };
}
