import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/devices/infrastructure/api/gateways/organizations.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/create_organization_request.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/organization_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_organization_name_request.resource.dart';

class OrganizationsHttpGateway implements OrganizationsGateway {
  final Dio _dio;

  OrganizationsHttpGateway(this._dio);

  @override
  Future<OrganizationResponseResource> createOrganization(
    CreateOrganizationRequestResource resource,
  ) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/organizations',
      data: resource.toJson(),
    );
    return OrganizationResponseResource.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<List<OrganizationResponseResource>> getUserOrganizations() async {
    final response = await _dio.get('${ApiConstants.apiPrefix}/organizations');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => OrganizationResponseResource.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrganizationResponseResource> getOrganizationById(String organizationId) async {
    final response = await _dio.get('${ApiConstants.apiPrefix}/organizations/$organizationId');
    return OrganizationResponseResource.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteOrganization(String organizationId) async {
    await _dio.delete('${ApiConstants.apiPrefix}/organizations/$organizationId');
  }

  @override
  Future<void> updateOrganizationName(
    String organizationId,
    UpdateOrganizationNameRequestResource resource,
  ) async {
    await _dio.patch(
      '${ApiConstants.apiPrefix}/organizations/$organizationId/name',
      data: resource.toJson(),
    );
  }
}
