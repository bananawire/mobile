import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';

class GetSpacesByOrganizationQuery {
  final OrganizationId organizationId;

  const GetSpacesByOrganizationQuery({required this.organizationId});
}
