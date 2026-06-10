import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_name.valueobject.dart';

class UpdateOrganizationNameCommand {
  final OrganizationId organizationId;
  final OrganizationName name;

  const UpdateOrganizationNameCommand({
    required this.organizationId,
    required this.name,
  });
}
