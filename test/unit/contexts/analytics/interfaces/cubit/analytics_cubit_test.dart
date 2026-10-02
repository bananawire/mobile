import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/analytics/domain/model/queries/get_dashboard_metrics.query.dart';
import 'package:mobile/analytics/domain/model/queries/get_trends.query.dart';
import 'package:mobile/analytics/domain/model/valueobjects/aqi.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/dashboard_metrics.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/live_telemetry.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/metric_delta.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';
import 'package:mobile/analytics/domain/services/analytics.query-service.dart';
import 'package:mobile/analytics/interfaces/pages/analytics_cubit.dart';
import 'package:mobile/devices/domain/model/queries/get_devices_by_space.query.dart';
import 'package:mobile/devices/domain/model/queries/get_spaces_by_organization.query.dart';
import 'package:mobile/devices/domain/model/queries/get_user_organizations.query.dart';
import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/device_page.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/space.read_model.dart';
import 'package:mobile/devices/domain/services/devices.query-service.dart';
import 'package:mobile/devices/domain/services/organizations.query-service.dart';
import 'package:mobile/devices/domain/services/spaces.query-service.dart';

class MockAnalyticsQueryService extends Mock implements AnalyticsQueryService {}

class MockOrganizationsQueryService extends Mock
    implements OrganizationsQueryService {}

class MockSpacesQueryService extends Mock implements SpacesQueryService {}

class MockDevicesQueryService extends Mock implements DevicesQueryService {}

class FakeGetDashboardMetricsQuery extends Fake
    implements GetDashboardMetricsQuery {}

class FakeGetTrendsQuery extends Fake implements GetTrendsQuery {}

class FakeGetUserOrganizationsQuery extends Fake
    implements GetUserOrganizationsQuery {}

class FakeGetSpacesByOrganizationQuery extends Fake
    implements GetSpacesByOrganizationQuery {}

class FakeGetDevicesBySpaceQuery extends Fake
    implements GetDevicesBySpaceQuery {}

void main() {
  late MockAnalyticsQueryService mockAnalytics;
  late MockOrganizationsQueryService mockOrganizations;
  late MockSpacesQueryService mockSpaces;
  late MockDevicesQueryService mockDevices;
  late AnalyticsCubit cubit;
  late StreamController<LiveTelemetry> liveTelemetryController;

  final sampleOrgs = [
    const OrganizationReadModel(
      id: 'org-1',
      name: 'Main Company',
      ownerUserId: 'u1',
      createdAt: null,
      updatedAt: null,
    ),
  ];

  final sampleSpaces = [
    const SpaceReadModel(
      id: 'space-1',
      name: 'Office Room',
      organizationId: 'org-1',
      ownerUserId: 'u1',
      createdAt: null,
      updatedAt: null,
    ),
  ];

  final sampleDevice = const DeviceReadModel(
    id: 'dev-1',
    serialNumber: 'SN-001',
    name: 'Sensor 01',
    status: 'ONLINE',
    spaceId: 'space-1',
    ownerUserId: 'u1',
    configuration: {},
    thresholds: [],
    hardwareId: 'hw-01',
    deviceType: 'AIR_QUALITY',
    activatedAt: null,
    lastSeenAt: null,
    createdAt: null,
    updatedAt: null,
  );

  final sampleDevicePage = DevicePageReadModel(
    content: [sampleDevice],
    totalElements: 1,
    number: 0,
    size: 100,
  );

  final sampleMetrics = DashboardMetrics(
    aqi: Aqi(42.0, 'Good'),
    co2: MetricDelta(480.0, 1.5),
    pm2_5: MetricDelta(10.0, -0.5),
    temperature: MetricDelta(22.0, 0.0),
    humidity: MetricDelta(45.0, 0.0),
    calculatedAt: '2026-10-02T12:00:00Z',
  );

  final sampleTrends = [
    TrendPoint(
      timestamp: '2026-10-02T11:00:00Z',
      aqiValue: 40.0,
      co2: 470.0,
      pm2_5: 9.5,
      temperature: 21.5,
      humidity: 44.0,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeGetDashboardMetricsQuery());
    registerFallbackValue(FakeGetTrendsQuery());
    registerFallbackValue(FakeGetUserOrganizationsQuery());
    registerFallbackValue(FakeGetSpacesByOrganizationQuery());
    registerFallbackValue(FakeGetDevicesBySpaceQuery());
  });

  setUp(() {
    mockAnalytics = MockAnalyticsQueryService();
    mockOrganizations = MockOrganizationsQueryService();
    mockSpaces = MockSpacesQueryService();
    mockDevices = MockDevicesQueryService();
    liveTelemetryController = StreamController<LiveTelemetry>.broadcast();

    when(
      () => mockAnalytics.handleStreamLiveTelemetry(any()),
    ).thenAnswer((_) => liveTelemetryController.stream);

    cubit = AnalyticsCubit(
      mockAnalytics,
      mockOrganizations,
      mockSpaces,
      mockDevices,
    );
  });

  tearDown(() async {
    await cubit.close();
    await liveTelemetryController.close();
  });

  group('AnalyticsCubit - Initial State', () {
    test('should have initial state with default values', () {
      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.liveUnavailable, isFalse);
      expect(cubit.state.selectedPeriod, equals('LIVE'));
      expect(cubit.state.selectedMetric, equals('aqiValue'));
      expect(cubit.state.organizations, isEmpty);
      expect(cubit.state.spaces, isEmpty);
      expect(cubit.state.devices, isEmpty);
      expect(cubit.state.liveData, isNull);
      expect(cubit.state.trendDataPoints, isEmpty);
      expect(cubit.state.hasData, isFalse);
      expect(cubit.state.isLive, isTrue);
    });
  });

  group('AnalyticsCubit - load() hierarchy', () {
    test(
      'should cascade load organizations, spaces, devices and telemetry successfully',
      () async {
        // Arrange
        when(
          () => mockOrganizations.handleGetUserOrganizations(any()),
        ).thenAnswer((_) async => Right(sampleOrgs));
        when(
          () => mockSpaces.handleGetSpacesByOrganization(any()),
        ).thenAnswer((_) async => Right(sampleSpaces));
        when(
          () => mockDevices.handleGetDevicesBySpace(any()),
        ).thenAnswer((_) async => Right(sampleDevicePage));
        when(
          () => mockAnalytics.handleGetDashboardMetrics(any()),
        ).thenAnswer((_) async => Right(sampleMetrics));
        when(
          () => mockAnalytics.handleGetTrends(any()),
        ).thenAnswer((_) async => Right(sampleTrends));

        // Act
        await cubit.load();

        // Assert
        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.selectedOrgId, equals('org-1'));
        expect(cubit.state.organizations.length, equals(1));
        expect(cubit.state.organizations.first.name, equals('Main Company'));
        expect(cubit.state.selectedSpaceId, equals('space-1'));
        expect(cubit.state.spaces.length, equals(1));
        expect(cubit.state.selectedDeviceId, equals('dev-1'));
        expect(cubit.state.devices.length, equals(1));
        expect(cubit.state.liveData, equals(sampleMetrics));
        expect(cubit.state.trendDataPoints, equals(sampleTrends));
        expect(cubit.state.hasData, isTrue);
      },
    );

    test('should emit error message when organizations query fails', () async {
      // Arrange
      when(
        () => mockOrganizations.handleGetUserOrganizations(any()),
      ).thenAnswer((_) async => const Left(Failure('Connection timeout')));

      // Act
      await cubit.load();

      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(
        cubit.state.errorMessage,
        equals('Failed to load organizations. Please try again.'),
      );
      expect(cubit.state.organizations, isEmpty);
    });

    test('should stop cascading when user has no organizations', () async {
      // Arrange
      when(
        () => mockOrganizations.handleGetUserOrganizations(any()),
      ).thenAnswer((_) async => const Right([]));

      // Act
      await cubit.load();

      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.organizations, isEmpty);
      expect(cubit.state.selectedOrgId, isNull);
    });

    test('should emit error message when spaces query fails', () async {
      // Arrange
      when(
        () => mockOrganizations.handleGetUserOrganizations(any()),
      ).thenAnswer((_) async => Right(sampleOrgs));
      when(
        () => mockSpaces.handleGetSpacesByOrganization(any()),
      ).thenAnswer((_) async => const Left(Failure('Spaces error')));

      // Act
      await cubit.load();

      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, equals('Failed to load spaces.'));
      expect(cubit.state.spaces, isEmpty);
      expect(cubit.state.selectedSpaceId, isNull);
    });

    test('should stop cascading when organization has no spaces', () async {
      // Arrange
      when(
        () => mockOrganizations.handleGetUserOrganizations(any()),
      ).thenAnswer((_) async => Right(sampleOrgs));
      when(
        () => mockSpaces.handleGetSpacesByOrganization(any()),
      ).thenAnswer((_) async => const Right([]));

      // Act
      await cubit.load();

      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.spaces, isEmpty);
      expect(cubit.state.selectedSpaceId, isNull);
    });

    test('should emit error message when devices query fails', () async {
      // Arrange
      when(
        () => mockOrganizations.handleGetUserOrganizations(any()),
      ).thenAnswer((_) async => Right(sampleOrgs));
      when(
        () => mockSpaces.handleGetSpacesByOrganization(any()),
      ).thenAnswer((_) async => Right(sampleSpaces));
      when(
        () => mockDevices.handleGetDevicesBySpace(any()),
      ).thenAnswer((_) async => const Left(Failure('Devices error')));

      // Act
      await cubit.load();

      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, equals('Failed to load devices.'));
      expect(cubit.state.devices, isEmpty);
    });
  });

  group('AnalyticsCubit - Filtering and Selection', () {
    test(
      'should update selectedSpace and fetch devices when selectSpace is called',
      () async {
        // Arrange
        when(
          () => mockDevices.handleGetDevicesBySpace(any()),
        ).thenAnswer((_) async => Right(sampleDevicePage));
        when(
          () => mockAnalytics.handleGetDashboardMetrics(any()),
        ).thenAnswer((_) async => Right(sampleMetrics));
        when(
          () => mockAnalytics.handleGetTrends(any()),
        ).thenAnswer((_) async => Right(sampleTrends));

        // Act
        await cubit.selectSpace('space-2');

        // Assert
        expect(cubit.state.selectedSpaceId, equals('space-2'));
        expect(cubit.state.selectedDeviceId, equals('dev-1'));
      },
    );

    test(
      'should update selectedPeriod and refetch data when selectPeriod is called',
      () async {
        // Arrange
        when(
          () => mockOrganizations.handleGetUserOrganizations(any()),
        ).thenAnswer((_) async => Right(sampleOrgs));
        when(
          () => mockSpaces.handleGetSpacesByOrganization(any()),
        ).thenAnswer((_) async => Right(sampleSpaces));
        when(
          () => mockDevices.handleGetDevicesBySpace(any()),
        ).thenAnswer((_) async => Right(sampleDevicePage));
        when(
          () => mockAnalytics.handleGetDashboardMetrics(any()),
        ).thenAnswer((_) async => Right(sampleMetrics));
        when(
          () => mockAnalytics.handleGetTrends(any()),
        ).thenAnswer((_) async => Right(sampleTrends));
        await cubit.load();

        // Act
        cubit.selectPeriod('DAY');
        await pumpEventQueue();

        // Assert
        expect(cubit.state.selectedPeriod, equals('DAY'));
        expect(cubit.state.isLive, isFalse);
      },
    );

    test('should update selectedMetric when selectMetric is called', () {
      // Act
      cubit.selectMetric('co2');

      // Assert
      expect(cubit.state.selectedMetric, equals('co2'));
    });
  });

  group('AnalyticsCubit - Data Fetching and Errors', () {
    test(
      'should set liveUnavailable true when metrics query returns 404',
      () async {
        // Arrange
        when(
          () => mockOrganizations.handleGetUserOrganizations(any()),
        ).thenAnswer((_) async => Right(sampleOrgs));
        when(
          () => mockSpaces.handleGetSpacesByOrganization(any()),
        ).thenAnswer((_) async => Right(sampleSpaces));
        when(
          () => mockDevices.handleGetDevicesBySpace(any()),
        ).thenAnswer((_) async => Right(sampleDevicePage));
        when(() => mockAnalytics.handleGetDashboardMetrics(any())).thenAnswer(
          (_) async => const Left(
            Failure('Device dev-1 telemetry is not available', statusCode: 404),
          ),
        );
        when(
          () => mockAnalytics.handleGetTrends(any()),
        ).thenAnswer((_) async => const Right([]));

        // Act
        await cubit.load();

        // Assert
        expect(cubit.state.liveUnavailable, isTrue);
        expect(cubit.state.liveUnavailableMessage, contains('"Sensor 01"'));
        expect(cubit.state.liveData, isNull);
      },
    );

    test(
      'should clear liveData when metrics query returns non-404 failure',
      () async {
        // Arrange
        when(
          () => mockOrganizations.handleGetUserOrganizations(any()),
        ).thenAnswer((_) async => Right(sampleOrgs));
        when(
          () => mockSpaces.handleGetSpacesByOrganization(any()),
        ).thenAnswer((_) async => Right(sampleSpaces));
        when(
          () => mockDevices.handleGetDevicesBySpace(any()),
        ).thenAnswer((_) async => Right(sampleDevicePage));
        when(() => mockAnalytics.handleGetDashboardMetrics(any())).thenAnswer(
          (_) async =>
              const Left(Failure('Internal server error', statusCode: 500)),
        );
        when(
          () => mockAnalytics.handleGetTrends(any()),
        ).thenAnswer((_) async => const Right([]));

        // Act
        await cubit.load();

        // Assert
        expect(cubit.state.liveUnavailable, isFalse);
        expect(cubit.state.liveData, isNull);
      },
    );
  });

  group('AnalyticsCubit - Live Telemetry SSE stream', () {
    test(
      'should update liveData and trendDataPoints when SSE event arrives',
      () async {
        // Arrange
        when(
          () => mockOrganizations.handleGetUserOrganizations(any()),
        ).thenAnswer((_) async => Right(sampleOrgs));
        when(
          () => mockSpaces.handleGetSpacesByOrganization(any()),
        ).thenAnswer((_) async => Right(sampleSpaces));
        when(
          () => mockDevices.handleGetDevicesBySpace(any()),
        ).thenAnswer((_) async => Right(sampleDevicePage));
        when(
          () => mockAnalytics.handleGetDashboardMetrics(any()),
        ).thenAnswer((_) async => Right(sampleMetrics));
        when(
          () => mockAnalytics.handleGetTrends(any()),
        ).thenAnswer((_) async => Right(sampleTrends));

        await cubit.load();

        // Act - simulate live SSE telemetry packet
        const telemetry = LiveTelemetry(
          deviceId: 'dev-1',
          co2: 620.0,
          pm2_5: 15.0,
          temperature: 24.0,
          humidity: 52.0,
          timestamp: '2026-10-02T12:05:00Z',
        );
        liveTelemetryController.add(telemetry);

        // Wait a microtask for stream event processing
        await pumpEventQueue();

        // Assert
        expect(cubit.state.liveData, isNotNull);
        expect(cubit.state.liveData!.co2.value, equals(620.0));
        expect(cubit.state.liveData!.pm2_5.value, equals(15.0));
        expect(cubit.state.liveData!.temperature.value, equals(24.0));
        expect(cubit.state.liveData!.humidity.value, equals(52.0));
        expect(cubit.state.trendDataPoints.length, equals(2));
        expect(cubit.state.trendDataPoints.last.co2, equals(620.0));
        expect(cubit.state.secondsSinceUpdate, equals(0));
      },
    );
  });
}
