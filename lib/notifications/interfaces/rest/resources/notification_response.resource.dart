class NotificationResponseResource {
  final String id;
  final String userId;
  final String? alertId;
  final String title;
  final String message;
  final bool sent;
  final String? errorMessage;
  final String createdAt;
  final String updatedAt;

  NotificationResponseResource({
    required this.id,
    required this.userId,
    this.alertId,
    required this.title,
    required this.message,
    required this.sent,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationResponseResource.fromJson(Map<String, dynamic> json) {
    return NotificationResponseResource(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      alertId: json['alertId']?.toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      sent: json['sent'] == true,
      errorMessage: json['errorMessage']?.toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
    );
  }
}
