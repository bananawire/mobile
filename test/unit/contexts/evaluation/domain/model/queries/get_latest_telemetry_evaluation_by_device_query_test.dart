import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/evaluation/domain/model/queries/get_latest_telemetry_evaluation_by_device.query.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/device_id.valueobject.dart';

import '../../../helpers/evaluation_fixtures.dart';

void main() {
  group('GetLatestTelemetryEvaluationByDeviceQuery', () {
    test('should expose the device id it was built with', () {
      // Arrange
      final deviceId = buildEvaluationDeviceId('device-42');

      // Act
      final query = GetLatestTelemetryEvaluationByDeviceQuery(
        deviceId: deviceId,
      );

      // Assert
      expect(query.deviceId.value, 'device-42');
      expect(identical(query.deviceId, deviceId), isTrue);
    });

    test('should keep the trimmed identifier of the value object instead of '
        're-reading the raw input', () {
      // Arrange
      final deviceId = EvaluationDeviceId('  device-42  ');

      // Act
      final query = GetLatestTelemetryEvaluationByDeviceQuery(
        deviceId: deviceId,
      );

      // Assert
      expect(query.deviceId.value, 'device-42');
    });

    test('should not be constructible as a compile-time constant because '
        'EvaluationDeviceId only has a non-const factory', () {
      // Arrange / Act
      final query = GetLatestTelemetryEvaluationByDeviceQuery(
        deviceId: buildEvaluationDeviceId(),
      );

      // Assert: the declared `const` constructor is unreachable in practice.
      expect(query, isA<GetLatestTelemetryEvaluationByDeviceQuery>());
    });

    test('should not provide value equality because the class does not use '
        'Equatable', () {
      // Arrange
      final first = GetLatestTelemetryEvaluationByDeviceQuery(
        deviceId: buildEvaluationDeviceId(),
      );
      final second = GetLatestTelemetryEvaluationByDeviceQuery(
        deviceId: buildEvaluationDeviceId(),
      );

      // Assert
      expect(first == second, isFalse);
    });
  });
}
