class RegistrationInitiatedResource {
  final String sessionId;
  final String message;

  const RegistrationInitiatedResource({
    required this.sessionId,
    required this.message,
  });

  factory RegistrationInitiatedResource.fromJson(Map<String, dynamic> json) {
    return RegistrationInitiatedResource(
      sessionId: json['sessionId'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'message': message,
      };
}
