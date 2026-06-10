import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';

class DeleteSpaceCommand {
  final SpaceId spaceId;

  const DeleteSpaceCommand({required this.spaceId});
}
