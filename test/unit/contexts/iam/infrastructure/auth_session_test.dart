import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';

void main() {
  late AuthSession authSession;

  setUp(() {
    authSession = AuthSession();
    authSession.setAuthenticated(false);
  });

  tearDown(() {
    authSession.setAuthenticated(false);
  });

  group('AuthSession', () {
    test('should return singleton instance when constructor is called', () {
      // Act
      final instance1 = AuthSession();
      final instance2 = AuthSession();

      // Assert
      expect(identical(instance1, instance2), isTrue);
    });

    test('should initialize with isAuthenticated as false', () {
      // Assert
      expect(authSession.isAuthenticated, isFalse);
    });

    test('should update isAuthenticated to true and notify listeners', () {
      // Arrange
      var notified = false;
      authSession.addListener(() {
        notified = true;
      });

      // Act
      authSession.setAuthenticated(true);

      // Assert
      expect(authSession.isAuthenticated, isTrue);
      expect(notified, isTrue);
    });

    test('should update isAuthenticated to false and notify listeners', () {
      // Arrange
      authSession.setAuthenticated(true);
      var notified = false;
      authSession.addListener(() {
        notified = true;
      });

      // Act
      authSession.setAuthenticated(false);

      // Assert
      expect(authSession.isAuthenticated, isFalse);
      expect(notified, isTrue);
    });

    test('should not notify listeners when state does not change', () {
      // Arrange
      authSession.setAuthenticated(true);
      var notifyCount = 0;
      authSession.addListener(() {
        notifyCount++;
      });

      // Act
      authSession.setAuthenticated(true);

      // Assert
      expect(authSession.isAuthenticated, isTrue);
      expect(notifyCount, equals(0));
    });
  });
}
