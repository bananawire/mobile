import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/api_constants.dart';

/// Only the compile-time constants are covered here.
///
/// `ApiConstants.baseUrl` and `ApiConstants.googleServerClientId` are
/// dotenv-backed getters, so testing them would mean standing up environment
/// configuration. That is out of scope for this suite: it reads no `.env`
/// file, no asset bundle, no real backend URL and no real OAuth client id.
/// `DioClient` needs a base URL to be constructible at all, so those two
/// getters are satisfied by the in-memory `FakeDotEnv` stub in
/// `dio_test_doubles.dart` rather than by an environment-driven test.
void main() {
  group('ApiConstants', () {
    test('should expose the versioned api prefix', () {
      // Arrange & Act
      const apiPrefix = ApiConstants.apiPrefix;

      // Assert
      expect(apiPrefix, '/api/v1');
    });

    test('should derive the auth base from the api prefix', () {
      // Arrange & Act
      const authBase = ApiConstants.authBase;

      // Assert
      expect(authBase, '/api/v1/auth');
      expect(authBase, '${ApiConstants.apiPrefix}/auth');
    });

    test('should keep the auth base nested under the api prefix', () {
      // Arrange & Act
      final refreshPath = '${ApiConstants.authBase}/refresh';

      // Assert
      expect(refreshPath, '/api/v1/auth/refresh');
      expect(refreshPath, startsWith(ApiConstants.apiPrefix));
    });
  });
}