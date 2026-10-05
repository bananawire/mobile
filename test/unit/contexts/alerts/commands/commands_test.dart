import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/commands/acknowledge_alert.command.dart';
import 'package:mobile/alerts/domain/model/commands/refresh_alerts.command.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';

void main() {
  group('AcknowledgeAlertCommand', () {
    test('should carry the alert identifier when built for an active alert',
        () {
      // Arrange
      final alertId = AlertId('alert-1');

      // Act
      final command = AcknowledgeAlertCommand(alertId: alertId);

      // Assert
      expect(command.alertId.value, 'alert-1');
    });

    test('should expose the alert identifier as an AlertId value object', () {
      // Arrange
      final alertId = AlertId('alert-9');

      // Act
      final command = AcknowledgeAlertCommand(alertId: alertId);

      // Assert
      expect(command.alertId, alertId);
    });
  });

  group('RefreshAlertsCommand', () {
    test('should default to the first page with twenty items when no arguments '
        'are provided', () {
      // Arrange / Act
      final command = RefreshAlertsCommand();

      // Assert
      expect(command.page, 0);
      expect(command.size, 20);
    });

    test('should expose the requested pagination when valid arguments are '
        'provided', () {
      // Arrange / Act
      final command = RefreshAlertsCommand(page: 2, size: 5);

      // Assert
      expect(command.page, 2);
      expect(command.size, 5);
    });

    test('should accept the pagination boundaries when page is zero and size is '
        'one hundred', () {
      // Arrange / Act
      final command = RefreshAlertsCommand(page: 0, size: 100);

      // Assert
      expect(command.page, 0);
      expect(command.size, 100);
    });

    test('should throw ArgumentError when the page is negative', () {
      // Arrange / Act / Assert
      expect(
        () => RefreshAlertsCommand(page: -1),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'page must be >= 0',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the size is zero', () {
      // Arrange / Act / Assert
      expect(
        () => RefreshAlertsCommand(size: 0),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'size must be between 1 and 100',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the size exceeds one hundred', () {
      // Arrange / Act / Assert
      expect(
        () => RefreshAlertsCommand(size: 101),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'size must be between 1 and 100',
          ),
        ),
      );
    });

    test('should report the page violation first when both page and size are '
        'invalid', () {
      // Arrange / Act / Assert
      expect(
        () => RefreshAlertsCommand(page: -3, size: 0),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'page must be >= 0',
          ),
        ),
      );
    });
  });
}