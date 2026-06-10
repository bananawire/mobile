import 'package:mobile/devices/domain/model/valueobjects/organization_name.valueobject.dart';

class CreateOrganizationCommand {
  final OrganizationName name;

  const CreateOrganizationCommand({required this.name});
}
