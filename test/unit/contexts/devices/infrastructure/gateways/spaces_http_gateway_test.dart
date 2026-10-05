import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/infrastructure/api/gateways/spaces_http.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/create_space_request.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_space_name_request.resource.dart';

import '../../helpers/device_fixtures.dart';
import '../../helpers/fake_http_client_adapter.dart';

void main() {
  late Dio dio;
  late FakeHttpClientAdapter adapter;
  late SpacesHttpGateway sut;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://clair.test'));
    dio.httpClientAdapter = adapter;
    sut = SpacesHttpGateway(dio);
  });

  tearDown(() {
    dio.close(force: true);
  });

  group('SpacesHttpGateway.createSpace', () {
    test('should POST the space body with the organization id as a query parameter', () async {
      // Arrange
      adapter.enqueueJson(spaceResourceJson(id: 'space-9', name: 'Garage'));

      // Act
      final space = await sut.createSpace(
        organizationId: 'org-1',
        resource: const CreateSpaceRequestResource(organizationId: 'org-1', name: 'Garage'),
      );

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'POST');
      expect(request.path, '/api/v1/spaces');
      expect(request.queryParameters, {'organizationId': 'org-1'});
      expect(request.data, <String, dynamic>{'organizationId': 'org-1', 'name': 'Garage'});
      expect(space.id, 'space-9');
      expect(space.name, 'Garage');
    });

    test('should parse the created timestamps of the response', () async {
      // Arrange
      adapter.enqueueJson(spaceResourceJson());

      // Act
      final space = await sut.createSpace(
        organizationId: 'org-1',
        resource: const CreateSpaceRequestResource(organizationId: 'org-1', name: 'Garage'),
      );

      // Assert
      expect(space.organizationId, 'org-1');
      expect(space.createdAt, DateTime.utc(2024, 1, 15, 10));
      expect(space.updatedAt, DateTime.utc(2024, 2, 20, 8, 5));
    });

    test('should surface a forbidden response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'forbidden'}, statusCode: 403);

      // Act / Assert
      await expectLater(
        sut.createSpace(
          organizationId: 'org-1',
          resource: const CreateSpaceRequestResource(organizationId: 'org-1', name: 'Garage'),
        ),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 403),
        ),
      );
    });

    test('should throw a cast error when the response body is not a json object', () async {
      // Arrange
      adapter.enqueueJson(<dynamic>[]);

      // Act / Assert
      await expectLater(
        sut.createSpace(
          organizationId: 'org-1',
          resource: const CreateSpaceRequestResource(organizationId: 'org-1', name: 'Garage'),
        ),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('SpacesHttpGateway.getSpacesByOrganization', () {
    test('should GET the spaces collection filtered by organization id', () async {
      // Arrange
      adapter.enqueueJson(<dynamic>[
        spaceResourceJson(id: 'space-1'),
        spaceResourceJson(id: 'space-2', name: 'Garage'),
      ]);

      // Act
      final spaces = await sut.getSpacesByOrganization(organizationId: 'org-1');

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'GET');
      expect(request.path, '/api/v1/spaces');
      expect(request.queryParameters, {'organizationId': 'org-1'});
      expect(request.data, isNull);
      expect(spaces.map((s) => s.id), ['space-1', 'space-2']);
      expect(spaces.last.name, 'Garage');
    });

    test('should return an empty list when the organization has no spaces', () async {
      // Arrange
      adapter.enqueueJson(<dynamic>[]);

      // Act
      final spaces = await sut.getSpacesByOrganization(organizationId: 'org-1');

      // Assert
      expect(spaces, isEmpty);
    });

    test('should surface an unauthorised response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'unauthorised'}, statusCode: 401);

      // Act / Assert
      await expectLater(
        sut.getSpacesByOrganization(organizationId: 'org-1'),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 401),
        ),
      );
    });
  });

  group('SpacesHttpGateway.getSpaceById', () {
    test('should GET the single space resource by id', () async {
      // Arrange
      adapter.enqueueJson(spaceResourceJson(id: 'space-3', name: 'Attic'));

      // Act
      final space = await sut.getSpaceById('space-3');

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, '/api/v1/spaces/space-3');
      expect(space.id, 'space-3');
      expect(space.name, 'Attic');
    });

    test('should surface a not found response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'not found'}, statusCode: 404);

      // Act / Assert
      await expectLater(
        sut.getSpaceById('missing'),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 404),
        ),
      );
    });
  });

  group('SpacesHttpGateway.deleteSpace', () {
    test('should DELETE the space and accept an empty response', () async {
      // Arrange
      adapter.enqueueEmpty();

      // Act
      await sut.deleteSpace('space-3');

      // Assert
      expect(adapter.singleRequest.method, 'DELETE');
      expect(adapter.singleRequest.path, '/api/v1/spaces/space-3');
      expect(adapter.singleRequest.data, isNull);
    });

    test('should surface a conflict response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'space still holds devices'}, statusCode: 409);

      // Act / Assert
      await expectLater(
        sut.deleteSpace('space-3'),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 409),
        ),
      );
    });
  });

  group('SpacesHttpGateway.updateSpaceName', () {
    test('should PATCH the space name sub resource with the json body', () async {
      // Arrange
      adapter.enqueueEmpty();

      // Act
      await sut.updateSpaceName('space-3', const UpdateSpaceNameRequestResource(name: 'Renamed'));

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'PATCH');
      expect(request.path, '/api/v1/spaces/space-3/name');
      expect(request.data, <String, dynamic>{'name': 'Renamed'});
    });

    test('should surface a bad request response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'invalid name'}, statusCode: 400);

      // Act / Assert
      await expectLater(
        sut.updateSpaceName('space-3', const UpdateSpaceNameRequestResource(name: 'Renamed')),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 400),
        ),
      );
    });
  });
}