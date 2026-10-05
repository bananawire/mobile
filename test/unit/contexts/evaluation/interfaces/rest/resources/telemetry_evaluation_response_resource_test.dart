import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/evaluation/interfaces/rest/resources/telemetry_evaluation_response.resource.dart';

import '../../../helpers/evaluation_fixtures.dart';

void main() {
  group('TelemetryEvaluationResponseResource.fromJson', () {
    test('should map every field of a well-formed payload', () {
      // Arrange
      final json = buildEvaluationJson();

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.id, 'eval-1');
      expect(resource.deviceId, 'device-1');
      expect(resource.uptime, 7200);
      expect(resource.connectivity.status, 'ONLINE');
      expect(resource.connectivity.network, 'wifi');
      expect(resource.connectivity.signalStrength, -57);
      expect(resource.healthStatus, 92);
      expect(resource.status, 'HEALTHY');
      expect(resource.recordedAt, evaluationRecordedAt);
      expect(resource.recordedAt.isUtc, isTrue);
    });

    test('should parse the recorded-at timestamp as UTC when the payload ends '
        'with the Z designator', () {
      // Arrange
      final json = buildEvaluationJson(recordedAt: '2024-05-01T10:15:30Z');

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.recordedAt, DateTime.utc(2024, 5, 1, 10, 15, 30));
      expect(resource.recordedAt.isUtc, isTrue);
    });

    test(
      'should parse the recorded-at timestamp with millisecond precision',
      () {
        // Arrange
        final json = buildEvaluationJson(
          recordedAt: '2024-05-01T10:15:30.123Z',
        );

        // Act
        final resource = TelemetryEvaluationResponseResource.fromJson(json);

        // Assert
        expect(resource.recordedAt.millisecond, 123);
        expect(resource.recordedAt.isUtc, isTrue);
      },
    );

    test(
      'should parse a timestamp without a zone designator as local time',
      () {
        // Arrange
        final json = buildEvaluationJson(recordedAt: '2024-05-01T10:15:30');

        // Act
        final resource = TelemetryEvaluationResponseResource.fromJson(json);

        // Assert
        expect(resource.recordedAt.isUtc, isFalse);
        expect(resource.recordedAt, DateTime(2024, 5, 1, 10, 15, 30));
      },
    );

    test('should ignore unknown extra fields because parsing is field by '
        'field', () {
      // Arrange
      final json = buildEvaluationJson()
        ..['extraField'] = 'ignored'
        ..['nested'] = <String, dynamic>{
          'anything': <int>[1, 2],
        };

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.id, 'eval-1');
      expect(resource.status, 'HEALTHY');
    });

    test(
      'should ignore unknown extra fields inside the connectivity object',
      () {
        // Arrange
        final json = buildEvaluationJson(
          connectivity: buildConnectivityJson()
            ..['rssi'] = -70
            ..['carrier'] = ' Claro',
        );

        // Act
        final resource = TelemetryEvaluationResponseResource.fromJson(json);

        // Assert
        expect(resource.connectivity.status, 'ONLINE');
        expect(resource.connectivity.network, 'wifi');
        expect(resource.connectivity.signalStrength, -57);
      },
    );

    test('should default a missing id to an empty string', () {
      // Arrange
      final json = buildEvaluationJson()..remove('id');

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.id, isEmpty);
    });

    test('should default a null id to an empty string', () {
      // Arrange
      final json = buildEvaluationJson(id: null);

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.id, isEmpty);
    });

    test('should default a missing device id to an empty string', () {
      // Arrange
      final json = buildEvaluationJson()..remove('deviceId');

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.deviceId, isEmpty);
    });

    test('should default a missing status to an empty string', () {
      // Arrange
      final json = buildEvaluationJson()..remove('status');

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.status, isEmpty);
    });

    test('should stringify a non-string id instead of failing', () {
      // Arrange
      final json = buildEvaluationJson(id: 42, deviceId: 7, status: true);

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.id, '42');
      expect(resource.deviceId, '7');
      expect(resource.status, 'true');
    });

    test('should default a missing uptime to zero', () {
      // Arrange
      final json = buildEvaluationJson()..remove('uptime');

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.uptime, 0);
    });

    test('should default a null uptime to zero', () {
      // Arrange
      final json = buildEvaluationJson(uptime: null);

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.uptime, 0);
    });

    test('should coerce a double uptime to an int', () {
      // Arrange
      final json = buildEvaluationJson(uptime: 7200.9);

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.uptime, 7200);
    });

    test('should coerce a numeric string uptime to an int', () {
      // Arrange
      final json = buildEvaluationJson(uptime: '7200');

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.uptime, 7200);
    });

    test('should default an unparsable uptime to zero', () {
      // Arrange
      final json = buildEvaluationJson(uptime: 'not-a-number');

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.uptime, 0);
    });

    test(
      'should default a boolean uptime to zero because it is not parsable',
      () {
        // Arrange
        final json = buildEvaluationJson(uptime: true);

        // Act
        final resource = TelemetryEvaluationResponseResource.fromJson(json);

        // Assert
        expect(resource.uptime, 0);
      },
    );

    test('should keep a negative uptime because no range validation is '
        'implemented', () {
      // Arrange
      final json = buildEvaluationJson(uptime: -5);

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.uptime, -5);
    });

    test('should coerce a double health status to an int', () {
      // Arrange
      final json = buildEvaluationJson(healthStatus: 92.7);

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.healthStatus, 92);
    });

    test('should default an unparsable health status to zero instead of '
        'rejecting the payload', () {
      // Arrange
      final json = buildEvaluationJson(healthStatus: 'N/A');

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.healthStatus, 0);
    });

    test('should keep an out-of-range health status because clamping belongs '
        'to the consuming ACL', () {
      // Arrange
      final json = buildEvaluationJson(healthStatus: 150);

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.healthStatus, 150);
    });

    test('should default a missing connectivity object to empty values', () {
      // Arrange
      final json = buildEvaluationJson()..remove('connectivity');

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.connectivity.status, isEmpty);
      expect(resource.connectivity.network, isNull);
      expect(resource.connectivity.signalStrength, isNull);
    });

    test('should default a null connectivity object to empty values', () {
      // Arrange
      final json = buildEvaluationJson()..['connectivity'] = null;

      // Act
      final resource = TelemetryEvaluationResponseResource.fromJson(json);

      // Assert
      expect(resource.connectivity.status, isEmpty);
      expect(resource.connectivity.signalStrength, isNull);
    });

    test('should throw a TypeError when the connectivity field is not an '
        'object', () {
      // Arrange
      final json = buildEvaluationJson(connectivity: 'ONLINE');

      // Act / Assert
      expect(
        () => TelemetryEvaluationResponseResource.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });

    test('should throw a TypeError when the connectivity field is a list', () {
      // Arrange
      final json = buildEvaluationJson(connectivity: <dynamic>['ONLINE', -57]);

      // Act / Assert
      expect(
        () => TelemetryEvaluationResponseResource.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });

    test('should throw a FormatException when the recorded-at timestamp is '
        'missing', () {
      // Arrange
      final json = buildEvaluationJson()..remove('recordedAt');

      // Act / Assert
      expect(
        () => TelemetryEvaluationResponseResource.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw a FormatException when the recorded-at timestamp is '
        'null', () {
      // Arrange
      final json = buildEvaluationJson(recordedAt: null);

      // Act / Assert
      expect(
        () => TelemetryEvaluationResponseResource.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw a FormatException when the recorded-at timestamp is '
        'not a date', () {
      // Arrange
      final json = buildEvaluationJson(recordedAt: 'yesterday');

      // Act / Assert
      expect(
        () => TelemetryEvaluationResponseResource.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw a FormatException when the recorded-at timestamp is a '
        'numeric epoch instead of an ISO string', () {
      // Arrange
      final json = buildEvaluationJson(recordedAt: 1714558530000);

      // Act / Assert
      expect(
        () => TelemetryEvaluationResponseResource.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should stringify a non-string recorded-at value before parsing so '
        'the failure surfaces as a FormatException', () {
      // Arrange
      final json = buildEvaluationJson(recordedAt: <String>['2024-05-01']);

      // Act / Assert
      expect(
        () => TelemetryEvaluationResponseResource.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ConnectivityResponseResource.fromJson', () {
    test('should map every field of a well-formed payload', () {
      // Arrange
      final json = buildConnectivityJson(
        status: 'DEGRADED',
        network: 'cellular',
        signalStrength: -98,
      );

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.status, 'DEGRADED');
      expect(resource.network, 'cellular');
      expect(resource.signalStrength, -98);
    });

    test('should default a missing status to an empty string', () {
      // Arrange
      final json = buildConnectivityJson()..remove('status');

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.status, isEmpty);
    });

    test('should keep a null status as an empty string', () {
      // Arrange
      final json = buildConnectivityJson(status: null);

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.status, isEmpty);
    });

    test('should keep any status string verbatim because no wire-code codec '
        'is implemented', () {
      // Arrange
      const statuses = <String>[
        'ONLINE',
        'OFFLINE',
        'DEGRADED',
        'NEW_CODE',
        '',
      ];

      // Act
      final resources = statuses
          .map(
            (status) => ConnectivityResponseResource.fromJson(
              buildConnectivityJson(status: status),
            ),
          )
          .toList();

      // Assert
      expect(resources.map((resource) => resource.status), statuses);
    });

    test('should stringify a non-string status', () {
      // Arrange
      final json = buildConnectivityJson(status: 2);

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.status, '2');
    });

    test('should default a missing network to null', () {
      // Arrange
      final json = buildConnectivityJson()..remove('network');

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.network, isNull);
    });

    test('should keep a null network as null', () {
      // Arrange
      final json = buildConnectivityJson(network: null);

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.network, isNull);
    });

    test('should stringify a non-string network', () {
      // Arrange
      final json = buildConnectivityJson(network: 5);

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.network, '5');
    });

    test('should default a missing signal strength to null instead of zero '
        'because the ACL treats null as no reading', () {
      // Arrange
      final json = buildConnectivityJson()..remove('signalStrength');

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.signalStrength, isNull);
    });

    test('should keep a null signal strength as null', () {
      // Arrange
      final json = buildConnectivityJson(signalStrength: null);

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.signalStrength, isNull);
    });

    test('should coerce a double signal strength to an int', () {
      // Arrange
      final json = buildConnectivityJson(signalStrength: -57.8);

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.signalStrength, -57);
    });

    test('should coerce a numeric string signal strength to an int', () {
      // Arrange
      final json = buildConnectivityJson(signalStrength: '-57');

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.signalStrength, -57);
    });

    test(
      'should keep an unparsable signal strength as null instead of zero',
      () {
        // Arrange
        final json = buildConnectivityJson(signalStrength: 'weak');

        // Act
        final resource = ConnectivityResponseResource.fromJson(json);

        // Assert
        expect(resource.signalStrength, isNull);
      },
    );

    test('should keep a boolean signal strength as null', () {
      // Arrange
      final json = buildConnectivityJson(signalStrength: true);

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.signalStrength, isNull);
    });

    test('should keep an out-of-band signal strength because no range '
        'validation is implemented', () {
      // Arrange
      final json = buildConnectivityJson(signalStrength: 999);

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.signalStrength, 999);
    });

    test('should accept an empty payload and expose empty defaults', () {
      // Arrange
      const json = <String, dynamic>{};

      // Act
      final resource = ConnectivityResponseResource.fromJson(json);

      // Assert
      expect(resource.status, isEmpty);
      expect(resource.network, isNull);
      expect(resource.signalStrength, isNull);
    });
  });
}
