import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';

void main() {
  tearDown(() => AuthSession().setAuthenticated(false));

  group('AuthSession', () {
    test('should expose the same instance on every access', () {
      // Act
      final first = AuthSession();
      final second = AuthSession();

      // Assert
      expect(identical(first, second), isTrue);
    });

    test('should start unauthenticated', () {
      // Assert
      expect(AuthSession().isAuthenticated, isFalse);
    });

    test('should notify listeners only when the flag actually changes', () {
      // Arrange
      var notifications = 0;
      AuthSession().addListener(() => notifications++);

      // Act
      AuthSession().setAuthenticated(true);
      AuthSession().setAuthenticated(true);
      AuthSession().setAuthenticated(false);
      AuthSession().setAuthenticated(false);

      // Assert
      expect(notifications, 2);
      expect(AuthSession().isAuthenticated, isFalse);
    });

    test('should keep the authenticated flag across reads', () {
      // Act
      AuthSession().setAuthenticated(true);

      // Assert
      expect(AuthSession().isAuthenticated, isTrue);
    });
  });
}