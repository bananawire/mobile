import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_device.query.dart';

void main() {
  group('GetAlertsByDeviceQuery', () {
    test('should expose the device identifier with default pagination when only '
        'the device is provided', () {
      // Arrange / Act
      final query = GetAlertsByDeviceQuery(deviceId: 'device-1');

      // Assert
      expect(query.deviceId, 'device-1');
      expect(query.page, 0);
      expect(query.size, 20);
    });

    test('should expose the requested pagination when valid arguments are '
        'provided', () {
      // Arrange / Act
      final query = GetAlertsByDeviceQuery(
        deviceId: 'device-42',
        page: 2,
        size: 75,
      );

      // Assert
      expect(query.deviceId, 'device-42');
      expect(query.page, 2);
      expect(query.size, 75);
    });

    test('should keep the device identifier verbatim because it is not trimmed',
        () {
      // Arrange / Act
      final query = GetAlertsByDeviceQuery(deviceId: ' device-9 ');

      // Assert
      expect(query.deviceId, ' device-9 ');
    });

    test('should throw ArgumentError when the device identifier is empty', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertsByDeviceQuery(deviceId: ''),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'deviceId cannot be empty',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the device identifier is only '
        'whitespace', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertsByDeviceQuery(deviceId: '   '),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'deviceId cannot be empty',
          ),
        ),
      );
    });

    test('should throw ArgumentError when the page is negative', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertsByDeviceQuery(deviceId: 'device-1', page: -1),
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
        () => GetAlertsByDeviceQuery(deviceId: 'device-1', size: 0),
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
        () => GetAlertsByDeviceQuery(deviceId: 'device-1', size: 101),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'size must be between 1 and 100',
          ),
        ),
      );
    });

    test('should report the device violation first when the identifier and the '
        'pagination are invalid', () {
      // Arrange / Act / Assert
      expect(
        () => GetAlertsByDeviceQuery(deviceId: ' ', page: -1, size: 0),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'deviceId cannot be empty',
          ),
        ),
      );
    });
  });
}