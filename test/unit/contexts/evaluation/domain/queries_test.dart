import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/evaluation/domain/model/queries/get_latest_telemetry_evaluation_by_device.query.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/device_id.valueobject.dart';

void main() {
  group('GetLatestTelemetryEvaluationByDeviceQuery', () {
    test('should hold deviceId value object when query is instantiated', () {
      // Arrange
      final deviceId = EvaluationDeviceId('dev-abc-777');

      // Act
      final query = GetLatestTelemetryEvaluationByDeviceQuery(
        deviceId: deviceId,
      );

      // Assert
      expect(query.deviceId, equals(deviceId));
      expect(query.deviceId.value, equals('dev-abc-777'));
    });
  });
}
