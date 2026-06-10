import 'package:mobile/devices/interfaces/rest/resources/device_response.resource.dart';

class DevicePageResponseResource {
  final List<DeviceResponseResource> content;
  final int totalElements;
  final int number;
  final int size;

  const DevicePageResponseResource({
    required this.content,
    required this.totalElements,
    required this.number,
    required this.size,
  });

  factory DevicePageResponseResource.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    final content = <DeviceResponseResource>[];
    if (rawContent is List) {
      for (final item in rawContent) {
        if (item is Map<String, dynamic>) {
          content.add(DeviceResponseResource.fromJson(item));
        }
      }
    }

    return DevicePageResponseResource(
      content: content,
      totalElements: _asInt(json['totalElements']),
      number: _asInt(json['number']),
      size: _asInt(json['size']),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
