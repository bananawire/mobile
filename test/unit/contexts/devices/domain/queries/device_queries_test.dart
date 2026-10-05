import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/queries/get_device_threshold_by_metric.query.dart';
import 'package:mobile/devices/domain/model/queries/get_device_thresholds.query.dart';
import 'package:mobile/devices/domain/model/queries/get_devices_by_space.query.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';

void main() {
  group('GetDevicesBySpaceQuery', () {
    test('should default to the first page of twenty items when paging is omitted', () {
      // Arrange
      final spaceId = SpaceId('space-1');

      // Act
      final query = GetDevicesBySpaceQuery(spaceId: spaceId);

      // Assert
      expect(query.page, 0);
      expect(query.size, 20);
      expect(query.spaceId.value, 'space-1');
    });

    test('should keep the requested paging when it is provided', () {
      // Arrange
      final spaceId = SpaceId('space-1');

      // Act
      final query = GetDevicesBySpaceQuery(spaceId: spaceId, page: 3, size: 50);

      // Assert
      expect(query.page, 3);
      expect(query.size, 50);
    });

    test('should throw ArgumentError when the page is negative', () {
      // Arrange
      final spaceId = SpaceId('space-1');

      // Act / Assert
      expect(
        () => GetDevicesBySpaceQuery(spaceId: spaceId, page: -1),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'page must be >= 0')),
      );
    });

    test('should throw ArgumentError when the size is zero', () {
      // Arrange
      final spaceId = SpaceId('space-1');

      // Act / Assert
      expect(
        () => GetDevicesBySpaceQuery(spaceId: spaceId, size: 0),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', 'size must be between 1 and 200'),
        ),
      );
    });

    test('should throw ArgumentError when the size exceeds two hundred', () {
      // Arrange
      final spaceId = SpaceId('space-1');

      // Act / Assert
      expect(
        () => GetDevicesBySpaceQuery(spaceId: spaceId, size: 201),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', 'size must be between 1 and 200'),
        ),
      );
    });

    test('should accept the size boundaries of one and two hundred', () {
      // Arrange
      final spaceId = SpaceId('space-1');

      // Act / Assert
      expect(GetDevicesBySpaceQuery(spaceId: spaceId, size: 1).size, 1);
      expect(GetDevicesBySpaceQuery(spaceId: spaceId, size: 200).size, 200);
    });
  });

  group('GetDeviceThresholdsQuery', () {
    test('should keep the provided device id', () {
      // Arrange
      const deviceId = 'dev-1';

      // Act
      final query = GetDeviceThresholdsQuery(deviceId: deviceId);

      // Assert
      expect(query.deviceId, deviceId);
    });

    test('should throw ArgumentError when the device id is blank', () {
      // Arrange
      const deviceId = '  ';

      // Act / Assert
      expect(
        () => GetDeviceThresholdsQuery(deviceId: deviceId),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'deviceId cannot be empty')),
      );
    });
  });

  group('GetDeviceThresholdByMetricQuery', () {
    test('should keep the provided device id and metric', () {
      // Arrange
      const deviceId = 'dev-1';

      // Act
      final query = GetDeviceThresholdByMetricQuery(
        deviceId: deviceId,
        metric: MetricThreshold.temperature,
      );

      // Assert
      expect(query.deviceId, deviceId);
      expect(query.metric, MetricThreshold.temperature);
    });

    test('should throw ArgumentError when the device id is blank', () {
      // Arrange
      const deviceId = '';

      // Act / Assert
      expect(
        () => GetDeviceThresholdByMetricQuery(
          deviceId: deviceId,
          metric: MetricThreshold.pm25,
        ),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'deviceId cannot be empty')),
      );
    });
  });
}