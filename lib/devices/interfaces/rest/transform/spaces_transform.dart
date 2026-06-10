import 'package:mobile/devices/domain/model/commands/create_space.command.dart';
import 'package:mobile/devices/domain/model/commands/update_space_name.command.dart';
import 'package:mobile/devices/interfaces/rest/resources/create_space_request.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_space_name_request.resource.dart';

CreateSpaceRequestResource toCreateSpaceRequestResource(CreateSpaceCommand command) {
  return CreateSpaceRequestResource(
    organizationId: command.organizationId.value,
    name: command.name.value,
  );
}

UpdateSpaceNameRequestResource toUpdateSpaceNameRequestResource(UpdateSpaceNameCommand command) {
  return UpdateSpaceNameRequestResource(name: command.name.value);
}
