import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';

class DeleteOrganizationCommand {
  final OrganizationId organizationId;

  const DeleteOrganizationCommand({required this.organizationId});
}
