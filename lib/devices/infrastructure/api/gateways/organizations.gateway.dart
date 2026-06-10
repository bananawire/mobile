import 'package:mobile/devices/interfaces/rest/resources/create_organization_request.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/organization_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_organization_name_request.resource.dart';

abstract class OrganizationsGateway {
  Future<OrganizationResponseResource> createOrganization(
    CreateOrganizationRequestResource resource,
  );

  Future<List<OrganizationResponseResource>> getUserOrganizations();

  Future<OrganizationResponseResource> getOrganizationById(String organizationId);

  Future<void> deleteOrganization(String organizationId);

  Future<void> updateOrganizationName(
    String organizationId,
    UpdateOrganizationNameRequestResource resource,
  );
}
