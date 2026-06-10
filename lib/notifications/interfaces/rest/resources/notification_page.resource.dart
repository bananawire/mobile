import 'notification_response.resource.dart';

class NotificationPageResource {
  final List<NotificationResponseResource> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;

  NotificationPageResource({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
  });

  factory NotificationPageResource.fromJson(Map<String, dynamic> json) {
    final contentRaw = json['content'];
    return NotificationPageResource(
      content: contentRaw is List
          ? contentRaw
              .whereType<Map>()
              .map(
                (e) => NotificationResponseResource.fromJson(
                  e.cast<String, dynamic>(),
                ),
              )
              .toList()
          : const [],
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      number: (json['number'] as num?)?.toInt() ?? 0,
    );
  }
}
