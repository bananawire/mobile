import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';

class GetDevicesBySpaceQuery {
  final SpaceId spaceId;
  final int page;
  final int size;

  GetDevicesBySpaceQuery({
    required this.spaceId,
    this.page = 0,
    this.size = 20,
  }) {
    if (page < 0) throw ArgumentError('page must be >= 0');
    if (size < 1 || size > 200) throw ArgumentError('size must be between 1 and 200');
  }
}
