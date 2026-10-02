import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/evaluation/domain/model/readmodels/telemetry_evaluation.read_model.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/connectivity.valueobject.dart';

void main() {
  group('TelemetryEvaluationReadModel', () {
    test(
      'should hold all telemetry evaluation properties when constructed',
      () {
        // Arrange
        const id = 'eval-1001';
        const deviceId = 'dev-999';
        const uptimeSeconds = 86400;
        const connectivity = Connectivity(
          status: 'ONLINE',
          network: 'LTE',
          signalStrength: 4,
        );
        const healthStatus = 1;
        const status = 'OPTIMAL';
        final recordedAt = DateTime.parse('2026-10-02T12:00:00Z');

        // Act
        final readModel = TelemetryEvaluationReadModel(
          id: id,
          deviceId: deviceId,
          uptimeSeconds: uptimeSeconds,
          connectivity: connectivity,
          healthStatus: healthStatus,
          status: status,
          recordedAt: recordedAt,
        );

        // Assert
        expect(readModel.id, equals(id));
        expect(readModel.deviceId, equals(deviceId));
        expect(readModel.uptimeSeconds, equals(uptimeSeconds));
        expect(readModel.connectivity, equals(connectivity));
        expect(readModel.connectivity.status, equals('ONLINE'));
        expect(readModel.connectivity.network, equals('LTE'));
        expect(readModel.connectivity.signalStrength, equals(4));
        expect(readModel.healthStatus, equals(healthStatus));
        expect(readModel.status, equals(status));
        expect(readModel.recordedAt, equals(recordedAt));
      },
    );
  });
}
