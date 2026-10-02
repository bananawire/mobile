import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/commands/acknowledge_alert.command.dart';
import 'package:mobile/alerts/domain/model/commands/refresh_alerts.command.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_device.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_space.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_daily_summary.query.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';

void main() {
  group('AcknowledgeAlertCommand', () {
    test('should construct command when valid AlertId is provided', () {
      // Arrange & Act
      final alertId = AlertId('alert-100');
      final command = AcknowledgeAlertCommand(alertId: alertId);

      // Assert
      expect(command.alertId, equals(alertId));
      expect(command.alertId.value, equals('alert-100'));
    });
  });

  group('RefreshAlertsCommand', () {
    test('should construct command with default values when not provided', () {
      // Arrange & Act
      final command = RefreshAlertsCommand();

      // Assert
      expect(command.page, equals(0));
      expect(command.size, equals(20));
    });

    test('should construct command with custom page and size', () {
      // Arrange & Act
      final command = RefreshAlertsCommand(page: 3, size: 50);

      // Assert
      expect(command.page, equals(3));
      expect(command.size, equals(50));
    });

    test('should throw ArgumentError when page is negative', () {
      // Arrange, Act & Assert
      expect(
        () => RefreshAlertsCommand(page: -1),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('page must be >= 0'))),
      );
    });

    test('should throw ArgumentError when size is less than 1', () {
      // Arrange, Act & Assert
      expect(
        () => RefreshAlertsCommand(size: 0),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('size must be between 1 and 100'))),
      );
    });

    test('should throw ArgumentError when size is greater than 100', () {
      // Arrange, Act & Assert
      expect(
        () => RefreshAlertsCommand(size: 101),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('size must be between 1 and 100'))),
      );
    });
  });

  group('GetAlertsQuery', () {
    test('should construct query with default values when not provided', () {
      // Arrange & Act
      final query = GetAlertsQuery();

      // Assert
      expect(query.page, equals(0));
      expect(query.size, equals(20));
    });

    test('should construct query with custom page and size', () {
      // Arrange & Act
      final query = GetAlertsQuery(page: 2, size: 10);

      // Assert
      expect(query.page, equals(2));
      expect(query.size, equals(10));
    });

    test('should throw ArgumentError when page is negative', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertsQuery(page: -1),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('page must be >= 0'))),
      );
    });

    test('should throw ArgumentError when size is less than 1', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertsQuery(size: 0),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('size must be between 1 and 100'))),
      );
    });

    test('should throw ArgumentError when size is greater than 100', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertsQuery(size: 101),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('size must be between 1 and 100'))),
      );
    });
  });

  group('GetAlertsByDeviceQuery', () {
    test('should construct query when valid parameters are provided', () {
      // Arrange & Act
      final query = GetAlertsByDeviceQuery(
        deviceId: 'device-xyz',
        page: 1,
        size: 15,
      );

      // Assert
      expect(query.deviceId, equals('device-xyz'));
      expect(query.page, equals(1));
      expect(query.size, equals(15));
    });

    test('should construct query with default page and size', () {
      // Arrange & Act
      final query = GetAlertsByDeviceQuery(deviceId: 'device-xyz');

      // Assert
      expect(query.deviceId, equals('device-xyz'));
      expect(query.page, equals(0));
      expect(query.size, equals(20));
    });

    test('should throw ArgumentError when deviceId is empty', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertsByDeviceQuery(deviceId: ''),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('deviceId cannot be empty'))),
      );
    });

    test('should throw ArgumentError when deviceId is whitespace only', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertsByDeviceQuery(deviceId: '   '),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('deviceId cannot be empty'))),
      );
    });

    test('should throw ArgumentError when page is negative', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertsByDeviceQuery(deviceId: 'dev-1', page: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError when size is out of bounds', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertsByDeviceQuery(deviceId: 'dev-1', size: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => GetAlertsByDeviceQuery(deviceId: 'dev-1', size: 101),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('GetAlertsBySpaceQuery', () {
    test('should construct query when valid parameters are provided', () {
      // Arrange & Act
      final query = GetAlertsBySpaceQuery(
        spaceId: 'space-abc',
        page: 2,
        size: 25,
      );

      // Assert
      expect(query.spaceId, equals('space-abc'));
      expect(query.page, equals(2));
      expect(query.size, equals(25));
    });

    test('should construct query with default page and size', () {
      // Arrange & Act
      final query = GetAlertsBySpaceQuery(spaceId: 'space-abc');

      // Assert
      expect(query.spaceId, equals('space-abc'));
      expect(query.page, equals(0));
      expect(query.size, equals(20));
    });

    test('should throw ArgumentError when spaceId is empty', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertsBySpaceQuery(spaceId: ''),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('spaceId cannot be empty'))),
      );
    });

    test('should throw ArgumentError when spaceId is whitespace only', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertsBySpaceQuery(spaceId: '   '),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('spaceId cannot be empty'))),
      );
    });

    test('should throw ArgumentError when page is negative', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertsBySpaceQuery(spaceId: 'space-1', page: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError when size is out of bounds', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertsBySpaceQuery(spaceId: 'space-1', size: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => GetAlertsBySpaceQuery(spaceId: 'space-1', size: 101),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('GetAlertDailySummaryQuery', () {
    test('should construct query with default days when not specified', () {
      // Arrange & Act
      final query = GetAlertDailySummaryQuery();

      // Assert
      expect(query.days, equals(30));
    });

    test('should construct query with custom days within valid range', () {
      // Arrange & Act
      final query = GetAlertDailySummaryQuery(days: 7);

      // Assert
      expect(query.days, equals(7));
    });

    test('should throw ArgumentError when days is less than 1', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertDailySummaryQuery(days: 0),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('days must be between 1 and 365'))),
      );
    });

    test('should throw ArgumentError when days is greater than 365', () {
      // Arrange, Act & Assert
      expect(
        () => GetAlertDailySummaryQuery(days: 366),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('days must be between 1 and 365'))),
      );
    });
  });
}
