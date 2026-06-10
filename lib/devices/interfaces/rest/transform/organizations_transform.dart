import 'package:mobile/devices/domain/model/commands/create_organization.command.dart';
import 'package:mobile/devices/domain/model/commands/update_organization_name.command.dart';
import 'package:mobile/devices/interfaces/rest/resources/create_organization_request.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_organization_name_request.resource.dart';

CreateOrganizationRequestResource toCreateOrganizationRequestResource(
  CreateOrganizationCommand command,
) {
  return CreateOrganizationRequestResource(name: command.name.value);
}

UpdateOrganizationNameRequestResource toUpdateOrganizationNameRequestResource(
  UpdateOrganizationNameCommand command,
) {
  return UpdateOrganizationNameRequestResource(name: command.name.value);
}
