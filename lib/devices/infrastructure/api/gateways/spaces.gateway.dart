import 'package:mobile/devices/interfaces/rest/resources/create_space_request.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/space_response.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_space_name_request.resource.dart';

abstract class SpacesGateway {
  Future<SpaceResponseResource> createSpace({
    required String organizationId,
    required CreateSpaceRequestResource resource,
  });

  Future<List<SpaceResponseResource>> getSpacesByOrganization({
    required String organizationId,
  });

  Future<SpaceResponseResource> getSpaceById(String spaceId);

  Future<void> deleteSpace(String spaceId);

  Future<void> updateSpaceName(String spaceId, UpdateSpaceNameRequestResource resource);
}
