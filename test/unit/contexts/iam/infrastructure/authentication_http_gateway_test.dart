import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/infrastructure/api/gateways/authentication_http.gateway.dart';

import '../helpers/fake_http_client_adapter.dart';
import '../helpers/iam_test_doubles.dart';

void main() {
  AuthenticationHttpGateway gatewayWith(FakeHttpClientAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    return AuthenticationHttpGateway(dio);
  }

  group('AuthenticationHttpGateway.initiateRegistration', () {
    test('should post the sign-up payload and deserialize the session id', () async {
      // Arrange
      final adapter = FakeHttpClientAdapter(
        statusCode: 201,
        body: jsonEncode({
          'sessionId': IamFixtures.sessionId,
          'message': 'A verification code was sent to your email.',
        }),
      );
      final subject = gatewayWith(adapter);

      // Act
      final resource = await subject.initiateRegistration(
        IamFixtures.initiateRegistrationRequest,
      );

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v1/auth/sign-up');
      expect(jsonDecode(adapter.rawBodies.last!), <String, dynamic>{
        'email': IamFixtures.email,
        'password': IamFixtures.password,
      });
      expect(request.headers['content-type'], contains('application/json'));
      expect(resource.sessionId, IamFixtures.sessionId);
      expect(resource.message, 'A verification code was sent to your email.');
    });
  });

  group('AuthenticationHttpGateway.confirmRegistration', () {
    test('should post the confirm payload and deserialize the user', () async {
      // Arrange
      final adapter = FakeHttpClientAdapter(
        statusCode: 200,
        body: jsonEncode({
          'id': IamFixtures.userId,
          'email': IamFixtures.email,
        }),
      );
      final subject = gatewayWith(adapter);

      // Act
      final resource =
          await subject.confirmRegistration(IamFixtures.confirmRegistrationRequest);

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v1/auth/confirm');
      expect(jsonDecode(adapter.rawBodies.last!), <String, dynamic>{
        'sessionId': IamFixtures.sessionId,
        'verificationCode': IamFixtures.verificationCode,
      });
      expect(resource.id, IamFixtures.userId);
      expect(resource.email, IamFixtures.email);
    });
  });

  group('AuthenticationHttpGateway.signIn', () {
    test('should post the sign-in payload and deserialize the tokens', () async {
      // Arrange
      final adapter = FakeHttpClientAdapter(
        statusCode: 200,
        body: jsonEncode({
          'id': IamFixtures.userId,
          'email': IamFixtures.email,
          'token': IamFixtures.accessToken,
          'refreshToken': IamFixtures.refreshToken,
        }),
      );
      final subject = gatewayWith(adapter);

      // Act
      final resource = await subject.signIn(IamFixtures.signInRequest);

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v1/auth/sign-in');
      expect(jsonDecode(adapter.rawBodies.last!), <String, dynamic>{
        'email': IamFixtures.email,
        'password': IamFixtures.password,
      });
      expect(resource.token, IamFixtures.accessToken);
      expect(resource.refreshToken, IamFixtures.refreshToken);
      expect(resource.id, IamFixtures.userId);
      expect(resource.email, IamFixtures.email);
    });

    test('should send the sign-in request without query parameters', () async {
      // Arrange
      final adapter = FakeHttpClientAdapter(
        statusCode: 200,
        body: jsonEncode({
          'id': IamFixtures.userId,
          'email': IamFixtures.email,
          'token': IamFixtures.accessToken,
          'refreshToken': IamFixtures.refreshToken,
        }),
      );
      final subject = gatewayWith(adapter);

      // Act
      await subject.signIn(IamFixtures.signInRequest);

      // Assert
      expect(adapter.singleRequest.queryParameters, isEmpty);
    });
  });

  group('AuthenticationHttpGateway.googleSignIn', () {
    test('should post the id token to the google endpoint', () async {
      // Arrange
      final adapter = FakeHttpClientAdapter(
        statusCode: 200,
        body: jsonEncode({
          'id': IamFixtures.userId,
          'email': IamFixtures.email,
          'token': IamFixtures.accessToken,
          'refreshToken': IamFixtures.refreshToken,
        }),
      );
      final subject = gatewayWith(adapter);

      // Act
      final resource = await subject.googleSignIn(IamFixtures.googleSignInRequest);

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v1/auth/google/sign-in');
      expect(jsonDecode(adapter.rawBodies.last!), <String, dynamic>{
        'idToken': IamFixtures.googleIdToken,
      });
      expect(resource.token, IamFixtures.accessToken);
    });
  });

  group('AuthenticationHttpGateway.signOut', () {
    test('should delete the sign-out endpoint with a bearer authorization header', () async {
      // Arrange
      final adapter = FakeHttpClientAdapter(statusCode: 204);
      final subject = gatewayWith(adapter);

      // Act
      await subject.signOut(IamFixtures.accessToken);

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'DELETE');
      expect(request.uri.path, '/api/v1/auth/sign-out');
      expect(request.headers['Authorization'], 'Bearer ${IamFixtures.accessToken}');
      expect(adapter.rawBodies.last, isNull);
    });
  });

  group('AuthenticationHttpGateway.refreshToken', () {
    test('should post the refresh token and deserialize the rotated credentials', () async {
      // Arrange
      final adapter = FakeHttpClientAdapter(
        statusCode: 200,
        body: jsonEncode({
          'id': IamFixtures.userId,
          'email': IamFixtures.email,
          'token': 'rotated-access-token',
          'refreshToken': 'rotated-refresh-token',
        }),
      );
      final subject = gatewayWith(adapter);

      // Act
      final resource = await subject.refreshToken(IamFixtures.refreshTokenRequest);

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v1/auth/refresh');
      expect(jsonDecode(adapter.rawBodies.last!), <String, dynamic>{
        'refreshToken': IamFixtures.refreshToken,
      });
      expect(resource.token, 'rotated-access-token');
      expect(resource.refreshToken, 'rotated-refresh-token');
    });
  });

  group('AuthenticationHttpGateway.verifyToken', () {
    test('should get the verify endpoint with a bearer authorization header', () async {
      // Arrange
      final adapter = FakeHttpClientAdapter(
        statusCode: 200,
        body: jsonEncode({
          'valid': true,
          'userId': IamFixtures.userId,
          'expiresAt': '2026-01-01T00:00:00Z',
        }),
      );
      final subject = gatewayWith(adapter);

      // Act
      final resource = await subject.verifyToken(IamFixtures.accessToken);

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'GET');
      expect(request.uri.path, '/api/v1/auth/verify');
      expect(request.headers['Authorization'], 'Bearer ${IamFixtures.accessToken}');
      expect(adapter.rawBodies.last, isNull);
      expect(resource.valid, isTrue);
      expect(resource.userId, IamFixtures.userId);
      expect(resource.expiresAt, '2026-01-01T00:00:00Z');
    });
  });

  group('AuthenticationHttpGateway error handling', () {
    test('should surface a DioException carrying the failing status code', () async {
      // Arrange
      for (final status in <int>[400, 401, 403, 404, 409, 500]) {
        final adapter = FakeHttpClientAdapter(
          statusCode: status,
          body: jsonEncode({'message': 'error'}),
        );
        final subject = gatewayWith(adapter);

        // Act
        final call = subject.signIn(IamFixtures.signInRequest);

        // Assert
        await expectLater(
          call,
          throwsA(
            isA<DioException>()
                .having((e) => e.response?.statusCode, 'statusCode', status),
          ),
        );
      }
    });

    test('should surface a timeout raised by the transport', () async {
      // Arrange
      final adapter = FakeHttpClientAdapter(
        statusCode: 200,
        error: DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/api/v1/auth/sign-in'),
        ),
      );
      final subject = gatewayWith(adapter);

      // Act
      final call = subject.signIn(IamFixtures.signInRequest);

      // Assert
      await expectLater(
        call,
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.connectionTimeout,
          ),
        ),
      );
    });

    test('should throw a type error when a successful body is not a JSON object', () async {
      // Arrange
      final adapter = FakeHttpClientAdapter(
        statusCode: 200,
        body: jsonEncode('plain-text-not-an-object'),
      );
      final subject = gatewayWith(adapter);

      // Act
      final call = subject.signIn(IamFixtures.signInRequest);

      // Assert
      await expectLater(call, throwsA(isA<TypeError>()));
    });

    test('should throw a type error when a required field of the body is missing', () async {
      // Arrange
      final adapter = FakeHttpClientAdapter(
        statusCode: 200,
        body: jsonEncode({
          'id': IamFixtures.userId,
          'email': IamFixtures.email,
        }),
      );
      final subject = gatewayWith(adapter);

      // Act
      final call = subject.signIn(IamFixtures.signInRequest);

      // Assert
      await expectLater(call, throwsA(isA<TypeError>()));
    });
  });
}