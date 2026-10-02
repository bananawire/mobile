import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late TokenLocalStorage tokenLocalStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    tokenLocalStorage = TokenLocalStorage(mockStorage);
  });

  group('TokenLocalStorage', () {
    test('should save access and refresh tokens to secure storage', () async {
      // Arrange
      when(
        () => mockStorage.write(
          key: 'access_token',
          value: 'sample-access-token',
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockStorage.write(
          key: 'refresh_token',
          value: 'sample-refresh-token',
        ),
      ).thenAnswer((_) async {});

      // Act
      await tokenLocalStorage.saveTokens(
        accessToken: 'sample-access-token',
        refreshToken: 'sample-refresh-token',
      );

      // Assert
      verify(
        () => mockStorage.write(
          key: 'access_token',
          value: 'sample-access-token',
        ),
      ).called(1);
      verify(
        () => mockStorage.write(
          key: 'refresh_token',
          value: 'sample-refresh-token',
        ),
      ).called(1);
    });

    test('should return access token when getAccessToken is called', () async {
      // Arrange
      when(
        () => mockStorage.read(key: 'access_token'),
      ).thenAnswer((_) async => 'stored-access-token');

      // Act
      final result = await tokenLocalStorage.getAccessToken();

      // Assert
      expect(result, equals('stored-access-token'));
      verify(() => mockStorage.read(key: 'access_token')).called(1);
    });

    test('should return null when getAccessToken finds no token', () async {
      // Arrange
      when(
        () => mockStorage.read(key: 'access_token'),
      ).thenAnswer((_) async => null);

      // Act
      final result = await tokenLocalStorage.getAccessToken();

      // Assert
      expect(result, isNull);
    });

    test(
      'should return refresh token when getRefreshToken is called',
      () async {
        // Arrange
        when(
          () => mockStorage.read(key: 'refresh_token'),
        ).thenAnswer((_) async => 'stored-refresh-token');

        // Act
        final result = await tokenLocalStorage.getRefreshToken();

        // Assert
        expect(result, equals('stored-refresh-token'));
        verify(() => mockStorage.read(key: 'refresh_token')).called(1);
      },
    );

    test('should save userId and email to secure storage', () async {
      // Arrange
      when(
        () => mockStorage.write(key: 'user_id', value: 'user-uuid-123'),
      ).thenAnswer((_) async {});
      when(
        () => mockStorage.write(key: 'email', value: 'user@example.com'),
      ).thenAnswer((_) async {});

      // Act
      await tokenLocalStorage.saveUser(
        userId: 'user-uuid-123',
        email: 'user@example.com',
      );

      // Assert
      verify(
        () => mockStorage.write(key: 'user_id', value: 'user-uuid-123'),
      ).called(1);
      verify(
        () => mockStorage.write(key: 'email', value: 'user@example.com'),
      ).called(1);
    });

    test('should return userId when getUserId is called', () async {
      // Arrange
      when(
        () => mockStorage.read(key: 'user_id'),
      ).thenAnswer((_) async => 'user-uuid-123');

      // Act
      final result = await tokenLocalStorage.getUserId();

      // Assert
      expect(result, equals('user-uuid-123'));
      verify(() => mockStorage.read(key: 'user_id')).called(1);
    });

    test('should return email when getEmail is called', () async {
      // Arrange
      when(
        () => mockStorage.read(key: 'email'),
      ).thenAnswer((_) async => 'user@example.com');

      // Act
      final result = await tokenLocalStorage.getEmail();

      // Assert
      expect(result, equals('user@example.com'));
      verify(() => mockStorage.read(key: 'email')).called(1);
    });

    test('should clear all tokens and user info from secure storage', () async {
      // Arrange
      when(
        () => mockStorage.delete(key: 'access_token'),
      ).thenAnswer((_) async {});
      when(
        () => mockStorage.delete(key: 'refresh_token'),
      ).thenAnswer((_) async {});
      when(() => mockStorage.delete(key: 'user_id')).thenAnswer((_) async {});
      when(() => mockStorage.delete(key: 'email')).thenAnswer((_) async {});

      // Act
      await tokenLocalStorage.clearAll();

      // Assert
      verify(() => mockStorage.delete(key: 'access_token')).called(1);
      verify(() => mockStorage.delete(key: 'refresh_token')).called(1);
      verify(() => mockStorage.delete(key: 'user_id')).called(1);
      verify(() => mockStorage.delete(key: 'email')).called(1);
    });

    test(
      'should return true for hasToken when accessToken exists and is non-empty',
      () async {
        // Arrange
        when(
          () => mockStorage.read(key: 'access_token'),
        ).thenAnswer((_) async => 'valid-access-token');

        // Act
        final result = await tokenLocalStorage.hasToken();

        // Assert
        expect(result, isTrue);
      },
    );

    test('should return false for hasToken when accessToken is null', () async {
      // Arrange
      when(
        () => mockStorage.read(key: 'access_token'),
      ).thenAnswer((_) async => null);

      // Act
      final result = await tokenLocalStorage.hasToken();

      // Assert
      expect(result, isFalse);
    });

    test(
      'should return false for hasToken when accessToken is empty',
      () async {
        // Arrange
        when(
          () => mockStorage.read(key: 'access_token'),
        ).thenAnswer((_) async => '');

        // Act
        final result = await tokenLocalStorage.hasToken();

        // Assert
        expect(result, isFalse);
      },
    );
  });
}
