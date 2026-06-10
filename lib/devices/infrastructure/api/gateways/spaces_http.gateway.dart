import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/devices/infrastructure/api/gateways/spaces.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/create_space_request.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/space_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_space_name_request.resource.dart';

class SpacesHttpGateway implements SpacesGateway {
  final Dio _dio;

  SpacesHttpGateway(this._dio);

  @override
  Future<SpaceResponseResource> createSpace({
    required String organizationId,
    required CreateSpaceRequestResource resource,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.apiPrefix}/spaces',
      queryParameters: {'organizationId': organizationId},
      data: resource.toJson(),
    );
    return SpaceResponseResource.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<SpaceResponseResource>> getSpacesByOrganization({
    required String organizationId,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.apiPrefix}/spaces',
      queryParameters: {'organizationId': organizationId},
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => SpaceResponseResource.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<SpaceResponseResource> getSpaceById(String spaceId) async {
    final response = await _dio.get('${ApiConstants.apiPrefix}/spaces/$spaceId');
    return SpaceResponseResource.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSpace(String spaceId) async {
    await _dio.delete('${ApiConstants.apiPrefix}/spaces/$spaceId');
  }

  @override
  Future<void> updateSpaceName(String spaceId, UpdateSpaceNameRequestResource resource) async {
    await _dio.patch(
      '${ApiConstants.apiPrefix}/spaces/$spaceId/name',
      data: resource.toJson(),
    );
  }
}
