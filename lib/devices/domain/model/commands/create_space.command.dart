import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_name.valueobject.dart';

class CreateSpaceCommand {
  final OrganizationId organizationId;
  final SpaceName name;

  const CreateSpaceCommand({
    required this.organizationId,
    required this.name,
  });
}
