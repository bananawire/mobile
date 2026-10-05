import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/evaluation/domain/model/readmodels/telemetry_evaluation.read_model.dart';

import '../../../helpers/evaluation_fixtures.dart';

void main() {
  group('TelemetryEvaluationReadModel', () {
    test('should expose every field it was built with', () {
      // Arrange / Act
      final TelemetryEvaluationReadModel readModel =
          buildTelemetryEvaluationReadModel();

      // Assert
      expect(readModel.id, 'eval-1');
      expect(readModel.deviceId, 'device-1');
      expect(readModel.uptimeSeconds, 7200);
      expect(readModel.connectivity.status, 'ONLINE');
      expect(readModel.connectivity.network, 'wifi');
      expect(readModel.connectivity.signalStrength, -57);
      expect(readModel.healthStatus, 92);
      expect(readModel.status, 'HEALTHY');
      expect(readModel.recordedAt, evaluationRecordedAt);
    });

    test('should keep the uptime in seconds without converting it to hours '
        'because the ACL owns the conversion', () {
      // Arrange
      const uptimeSeconds = 7500;

      // Act
      final readModel = buildTelemetryEvaluationReadModel(
        uptimeSeconds: uptimeSeconds,
      );

      // Assert
      expect(readModel.uptimeSeconds, 7500);
      expect(readModel.uptimeSeconds, isA<int>());
      expect(readModel.uptimeSeconds ~/ 3600, 2);
    });

    test('should keep a negative uptime without validation because no range '
        'rule is implemented', () {
      // Arrange / Act
      final readModel = buildTelemetryEvaluationReadModel(uptimeSeconds: -1);

      // Assert
      expect(readModel.uptimeSeconds, -1);
    });

    test('should not clamp the health percentage because clamping belongs to '
        'the consuming ACL', () {
      // Arrange / Act
      final tooHigh = buildTelemetryEvaluationReadModel(healthStatus: 150);
      final negative = buildTelemetryEvaluationReadModel(healthStatus: -20);

      // Assert
      expect(tooHigh.healthStatus, 150);
      expect(negative.healthStatus, -20);
    });

    test('should keep a zero health percentage because zero is a valid '
        'reading and must not be treated as missing', () {
      // Arrange / Act
      final readModel = buildTelemetryEvaluationReadModel(healthStatus: 0);

      // Assert
      expect(readModel.healthStatus, 0);
    });

    test('should preserve the evaluation status verbatim without mapping it '
        'to an enum', () {
      // Arrange
      const statuses = <String>['HEALTHY', 'DEGRADED', 'CRITICAL', 'UNKNOWN'];

      // Act
      final readModels = statuses
          .map((status) => buildTelemetryEvaluationReadModel(status: status))
          .toList();

      // Assert
      expect(readModels.map((model) => model.status), statuses);
    });

    test('should store the parsed timestamp with its UTC flag intact', () {
      // Arrange
      final utc = buildTelemetryEvaluationReadModel(
        recordedAt: DateTime.utc(2024, 5, 1, 10, 15, 30),
      );

      // Act
      final local = buildTelemetryEvaluationReadModel(
        recordedAt: DateTime(2024, 5, 1, 10, 15, 30),
      );

      // Assert
      expect(utc.recordedAt.isUtc, isTrue);
      expect(utc.recordedAt, DateTime.utc(2024, 5, 1, 10, 15, 30));
      expect(local.recordedAt.isUtc, isFalse);
      expect(local.recordedAt, DateTime(2024, 5, 1, 10, 15, 30));
    });

    test('should hold the same connectivity instance it was given instead of '
        'copying it', () {
      // Arrange
      final connectivity = buildConnectivity();

      // Act
      final readModel = buildTelemetryEvaluationReadModel(
        connectivity: connectivity,
      );

      // Assert
      expect(identical(readModel.connectivity, connectivity), isTrue);
    });

    test('should accept an evaluation with no connectivity details because '
        'signal strength is nullable', () {
      // Arrange / Act
      final readModel = buildTelemetryEvaluationReadModel(
        connectivity: buildConnectivity(network: null, signalStrength: null),
      );

      // Assert
      expect(readModel.connectivity.network, isNull);
      expect(readModel.connectivity.signalStrength, isNull);
    });

    test('should not provide value equality because the class does not use '
        'Equatable', () {
      // Arrange
      final first = buildTelemetryEvaluationReadModel();
      final second = buildTelemetryEvaluationReadModel();

      // Assert
      expect(first == second, isFalse);
    });
  });
}
