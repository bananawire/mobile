import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/evaluation/domain/model/readmodels/telemetry_evaluation.read_model.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/connectivity.valueobject.dart';
import 'package:mobile/evaluation/interfaces/rest/resources/telemetry_evaluation_response.resource.dart';

void main() {
  group('ConnectivityResponseResource', () {
    test('should parse correctly fromJson with all fields populated', () {
      // Arrange
      final json = <String, dynamic>{
        'status': 'ONLINE',
        'network': 'WiFi-Office',
        'signalStrength': -50,
      };

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.status, equals('ONLINE'));
      expect(resource.network, equals('WiFi-Office'));
      expect(resource.signalStrength, equals(-50));
    });

    test('should parse signalStrength when provided as numeric or string', () {
      // Arrange
      final jsonWithNum = {'status': 'ONLINE', 'signalStrength': 85.0};
      final jsonWithString = {'status': 'ONLINE', 'signalStrength': '75'};
      final jsonWithInvalid = {
        'status': 'ONLINE',
        'signalStrength': 'not-a-number',
      };

      // Act
      final resNum = ConnectivityResponseResource.fromJson(jsonWithNum);
      final resString = ConnectivityResponseResource.fromJson(jsonWithString);
      final resInvalid = ConnectivityResponseResource.fromJson(jsonWithInvalid);

      // Assert
      expect(resNum.signalStrength, equals(85));
      expect(resString.signalStrength, equals(75));
      expect(resInvalid.signalStrength, isNull);
    });

    test('should serialize to JSON correctly via toJson', () {
      // Arrange
      const resource = ConnectivityResponseResource(
        status: 'CONNECTED',
        network: 'CELLULAR',
        signalStrength: 3,
      );

      // Act
      final json = resource.toJson();

      // Assert
      expect(
        json,
        equals({
          'status': 'CONNECTED',
          'network': 'CELLULAR',
          'signalStrength': 3,
        }),
      );
    });

    test(
      'should map to domain Connectivity value object correctly via toDomain',
      () {
        // Arrange
        const resource = ConnectivityResponseResource(
          status: 'CONNECTED',
          network: 'CELLULAR',
          signalStrength: 3,
        );

        // Act
        final domain = resource.toDomain();

        // Assert
        expect(domain, isA<Connectivity>());
        expect(domain.status, equals('CONNECTED'));
        expect(domain.network, equals('CELLULAR'));
        expect(domain.signalStrength, equals(3));
      },
    );
  });

  group('TelemetryEvaluationResponseResource', () {
    const validJson = {
      'id': 'eval-001',
      'deviceId': 'device-xyz-123',
      'uptime': 3600,
      'connectivity': {
        'status': 'ONLINE',
        'network': 'WIFI',
        'signalStrength': -45,
      },
      'healthStatus': 1,
      'status': 'NORMAL',
      'recordedAt': '2026-10-02T15:30:00.000Z',
    };

    test('should deserialize valid JSON correctly via fromJson', () {
      // Arrange & Act
      final resource = TelemetryEvaluationResponseResource.fromJson(validJson);

      // Assert
      expect(resource.id, equals('eval-001'));
      expect(resource.deviceId, equals('device-xyz-123'));
      expect(resource.uptime, equals(3600));
      expect(resource.connectivity.status, equals('ONLINE'));
      expect(resource.connectivity.network, equals('WIFI'));
      expect(resource.connectivity.signalStrength, equals(-45));
      expect(resource.healthStatus, equals(1));
      expect(resource.status, equals('NORMAL'));
      expect(
        resource.recordedAt,
        equals(DateTime.parse('2026-10-02T15:30:00.000Z')),
      );
    });

    test(
      'should handle various uptime and healthStatus value types via _asInt',
      () {
        // Arrange
        final jsonWithNumbers = {
          'id': 'eval-002',
          'deviceId': 'device-456',
          'uptime': 7200.0,
          'connectivity': null,
          'healthStatus': '2',
          'status': 'WARNING',
          'recordedAt': '2026-10-02T16:00:00.000Z',
        };

        // Act
        final resource = TelemetryEvaluationResponseResource.fromJson(
          jsonWithNumbers,
        );

        // Assert
        expect(resource.uptime, equals(7200));
        expect(resource.healthStatus, equals(2));
        expect(resource.connectivity.status, equals(''));
        expect(resource.connectivity.network, isNull);
        expect(resource.connectivity.signalStrength, isNull);
      },
    );

    test(
      'should fall back to zero for non-numeric uptime and healthStatus values',
      () {
        // Arrange
        final jsonWithInvalid = {
          'id': 'eval-003',
          'deviceId': 'device-789',
          'uptime': 'invalid-uptime',
          'healthStatus': null,
          'status': 'UNKNOWN',
          'recordedAt': '2026-10-02T17:00:00.000Z',
        };

        // Act
        final resource = TelemetryEvaluationResponseResource.fromJson(
          jsonWithInvalid,
        );

        // Assert
        expect(resource.uptime, equals(0));
        expect(resource.healthStatus, equals(0));
      },
    );

    test('should serialize to JSON map correctly via toJson', () {
      // Arrange
      final recordedAt = DateTime.parse('2026-10-02T12:00:00.000Z');
      final resource = TelemetryEvaluationResponseResource(
        id: 'eval-123',
        deviceId: 'dev-1',
        uptime: 5000,
        connectivity: const ConnectivityResponseResource(
          status: 'ONLINE',
          network: 'ETH0',
          signalStrength: 100,
        ),
        healthStatus: 1,
        status: 'HEALTHY',
        recordedAt: recordedAt,
      );

      // Act
      final json = resource.toJson();

      // Assert
      expect(
        json,
        equals({
          'id': 'eval-123',
          'deviceId': 'dev-1',
          'uptime': 5000,
          'connectivity': {
            'status': 'ONLINE',
            'network': 'ETH0',
            'signalStrength': 100,
          },
          'healthStatus': 1,
          'status': 'HEALTHY',
          'recordedAt': '2026-10-02T12:00:00.000Z',
        }),
      );
    });

    test(
      'should map to domain TelemetryEvaluationReadModel correctly via toDomain',
      () {
        // Arrange
        final recordedAt = DateTime.parse('2026-10-02T12:00:00.000Z');
        final resource = TelemetryEvaluationResponseResource(
          id: 'eval-123',
          deviceId: 'dev-1',
          uptime: 5000,
          connectivity: const ConnectivityResponseResource(
            status: 'ONLINE',
            network: 'ETH0',
            signalStrength: 100,
          ),
          healthStatus: 1,
          status: 'HEALTHY',
          recordedAt: recordedAt,
        );

        // Act
        final readModel = resource.toDomain();

        // Assert
        expect(readModel, isA<TelemetryEvaluationReadModel>());
        expect(readModel.id, equals('eval-123'));
        expect(readModel.deviceId, equals('dev-1'));
        expect(readModel.uptimeSeconds, equals(5000));
        expect(readModel.connectivity.status, equals('ONLINE'));
        expect(readModel.connectivity.network, equals('ETH0'));
        expect(readModel.connectivity.signalStrength, equals(100));
        expect(readModel.healthStatus, equals(1));
        expect(readModel.status, equals('HEALTHY'));
        expect(readModel.recordedAt, equals(recordedAt));
      },
    );
  });
}
