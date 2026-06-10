import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';

class DevicePageReadModel {
  final List<DeviceReadModel> content;
  final int totalElements;
  final int number;
  final int size;

  const DevicePageReadModel({
    required this.content,
    required this.totalElements,
    required this.number,
    required this.size,
  });
}
