import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/application/internal/acl/device_vitals_acl.dart';
import 'package:mobile/devices/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/evaluation/domain/model/queries/get_latest_telemetry_evaluation_by_device.query.dart';
import 'package:mobile/evaluation/domain/model/readmodels/telemetry_evaluation.read_model.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/connectivity.valueobject.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/evaluation/domain/services/telemetry_evaluation.query-service.dart';

class _MockTelemetryEvaluationQueryService extends Mock
    implements TelemetryEvaluationQueryService {}

TelemetryEvaluationReadModel _evaluation({
  int uptimeSeconds = 7200,
  int? signalStrength = -55,
  int healthStatus = 87,
  DateTime? recordedAt,
}) {
  return TelemetryEvaluationReadModel(
    id: 'eval-1',
    deviceId: 'dev-1',
    uptimeSeconds: uptimeSeconds,
    connectivity: Connectivity(status: 'ONLINE', network: 'WIFI', signalStrength: signalStrength),
    healthStatus: healthStatus,
    status: 'HEALTHY',
    recordedAt: recordedAt ?? DateTime.now().subtract(const Duration(hours: 3)),
  );
}

void main() {
  late TelemetryEvaluationQueryService evaluationService;
  late DeviceVitalsAcl sut;

  setUpAll(() {
    registerFallbackValue(
      GetLatestTelemetryEvaluationByDeviceQuery(deviceId: EvaluationDeviceId('fallback')),
    );
  });

  setUp(() {
    evaluationService = _MockTelemetryEvaluationQueryService();
    sut = DeviceVitalsAcl(evaluationService);
  });

  group('DeviceVitalsAcl.fetchLatestVitals', () {
    test('should translate an evaluation snapshot into a vitals snapshot', () async {
      // Arrange
      when(() => evaluationService.handleGetLatestByDevice(any())).thenAnswer(
        (_) async => Right(_evaluation(uptimeSeconds: 7200, signalStrength: -55, healthStatus: 87)),
      );

      // Act
      final result = await sut.fetchLatestVitals(DeviceId('dev-1'));

      // Assert
      final snapshot = result.fold((_) => null, (value) => value);
      expect(snapshot, isA<DeviceVitalsSnapshot>());
      expect(snapshot!.connectivityDbm, -55.0);
      expect(snapshot.uptimeHours, 2);
      expect(snapshot.deviceHealthPercent, 87.0);
    });

    test('should convert the whole hour bucket of the uptime seconds', () async {
      // Arrange
      when(() => evaluationService.handleGetLatestByDevice(any()))
          .thenAnswer((_) async => Right(_evaluation(uptimeSeconds: 3599)));

      // Act
      final result = await sut.fetchLatestVitals(DeviceId('dev-1'));

      // Assert
      expect(result.fold((_) => null, (value) => value)!.uptimeHours, 0);
    });

    test('should treat a missing signal strength as zero dBm', () async {
      // Arrange
      when(() => evaluationService.handleGetLatestByDevice(any()))
          .thenAnswer((_) async => Right(_evaluation(signalStrength: null)));

      // Act
      final result = await sut.fetchLatestVitals(DeviceId('dev-1'));

      // Assert
      expect(result.fold((_) => null, (value) => value)!.connectivityDbm, 0.0);
    });

    test('should clamp the health percentage into the zero to hundred range', () async {
      // Arrange
      when(() => evaluationService.handleGetLatestByDevice(any()))
          .thenAnswer((_) async => Right(_evaluation(healthStatus: 140)));

      // Act
      final high = await sut.fetchLatestVitals(DeviceId('dev-1'));

      // Assert
      expect(high.fold((_) => null, (value) => value)!.deviceHealthPercent, 100.0);
    });

    test('should clamp a negative health percentage to zero', () async {
      // Arrange
      when(() => evaluationService.handleGetLatestByDevice(any()))
          .thenAnswer((_) async => Right(_evaluation(healthStatus: -5)));

      // Act
      final result = await sut.fetchLatestVitals(DeviceId('dev-1'));

      // Assert
      expect(result.fold((_) => null, (value) => value)!.deviceHealthPercent, 0.0);
    });

    test('should report zero hours since a future recording timestamp', () async {
      // Arrange
      when(() => evaluationService.handleGetLatestByDevice(any())).thenAnswer(
        (_) async => Right(
          _evaluation(recordedAt: DateTime.now().add(const Duration(hours: 5))),
        ),
      );

      // Act
      final result = await sut.fetchLatestVitals(DeviceId('dev-1'));

      // Assert
      expect(result.fold((_) => null, (value) => value)!.lastUpdateHours, 0);
    });

    test('should report the elapsed whole hours since the recording timestamp', () async {
      // Arrange
      when(() => evaluationService.handleGetLatestByDevice(any())).thenAnswer(
        (_) async => Right(
          _evaluation(recordedAt: DateTime.now().subtract(const Duration(hours: 26))),
        ),
      );

      // Act
      final result = await sut.fetchLatestVitals(DeviceId('dev-1'));

      // Assert
      final hours = result.fold((_) => null, (value) => value)!.lastUpdateHours;
      expect(hours, 26);
    });

    test('should query the external context with the trimmed local device id', () async {
      // Arrange
      when(() => evaluationService.handleGetLatestByDevice(any()))
          .thenAnswer((_) async => Right(_evaluation()));

      // Act
      await sut.fetchLatestVitals(DeviceId(' dev-1 '));

      // Assert
      final captured =
          verify(() => evaluationService.handleGetLatestByDevice(captureAny())).captured;
      final query = captured.single as GetLatestTelemetryEvaluationByDeviceQuery;
      expect(query.deviceId.value, 'dev-1');
    });

    test('should propagate the external failure unchanged when no telemetry exists', () async {
      // Arrange
      const failure = Failure('No telemetry for device');
      when(() => evaluationService.handleGetLatestByDevice(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await sut.fetchLatestVitals(DeviceId('dev-1'));

      // Assert
      final actual = result.fold((f) => f, (_) => null);
      expect(actual!.message, 'No telemetry for device');
    });

    test('should reject a blank device id before calling the external context', () {
      // Arrange / Act
      DeviceId buildDeviceId() => DeviceId('   ');

      // Assert
      expect(buildDeviceId, throwsA(isA<ArgumentError>()));
      verifyNever(() => evaluationService.handleGetLatestByDevice(any()));
    });
  });
}