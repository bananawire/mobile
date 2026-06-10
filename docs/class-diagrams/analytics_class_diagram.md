# Unified Class Diagram - Bounded Context: Analytics

This document contains the class diagrams for the **Analytics** Bounded Context structured across the 4 layers of Clean Architecture / DDD (Interfaces, Application, Domain, and Infrastructure).

---

## 1. Unified Class Diagram

```mermaid
---
title: DDD Class Diagram - Analytics Bounded Context (Unified)
---

classDiagram

namespace interfaces {
    class AnalyticsCubit {
        -_analytics: AnalyticsQueryService
        -_organizations: OrganizationsQueryService
        -_spaces: SpacesQueryService
        -_devices: DevicesQueryService
        -_pollTimer: Timer?
        -_secondsTimer: Timer?
        -_liveSub: StreamSubscription?
        +load() void
        +loadOrganizations() void
        +selectOrganization(orgId) void
        +selectSpace(spaceId) void
        +selectDevice(deviceId) void
        +selectPeriod(period) void
        +selectMetric(metric) void
        +fetchData() void
    }

    class AnalyticsState {
        +isLoading: bool
        +errorMessage: String?
        +organizations: List~AnalyticsSelectOption~
        +spaces: List~AnalyticsSelectOption~
        +devices: List~AnalyticsSelectOption~
        +selectedOrgId: String?
        +selectedSpaceId: String?
        +selectedDeviceId: String?
        +selectedPeriod: String
        +selectedMetric: String
        +liveData: DashboardMetrics?
        +trendDataPoints: List~TrendPoint~
        +liveUnavailable: bool
        +liveUnavailableMessage: String
        +secondsSinceUpdate: int
    }

    class AnalyticsSelectOption {
        +id: String
        +name: String
    }
}

namespace application {
    class AnalyticsQueryServiceImpl {
        -_gateway: AnalyticsGateway
        +handleGetDashboardMetrics(query) Either
        +handleGetTrends(query) Either
        +handleStreamLiveTelemetry(deviceId) Stream~LiveTelemetry~
    }
}

namespace domain {
    class AnalyticsQueryService {
        <<interface>>
        +handleGetDashboardMetrics(query) Either*
        +handleGetTrends(query) Either*
        +handleStreamLiveTelemetry(deviceId) Stream~LiveTelemetry~*
    }

    class DashboardMetrics {
        +aqi: Aqi
        +co2: MetricDelta
        +pm2_5: MetricDelta
        +temperature: MetricDelta
        +humidity: MetricDelta
        +calculatedAt: DateTime
    }

    class LiveTelemetry {
        +deviceId: String
        +co2: double
        +pm2_5: double
        +temperature: double
        +humidity: double
        +timestamp: DateTime
    }

    class TrendPoint {
        +timestamp: DateTime
        +aqiValue: double
        +co2: double
        +pm2_5: double
        +temperature: double
        +humidity: double
    }

    class Aqi {
        +value: double
        +category: String
    }

    class MetricDelta {
        +value: double
        +deltaPercentage: double?
    }

    class GetDashboardMetricsQuery {
        +deviceId: String
        +period: String?
        +startDate: String?
        +endDate: String?
    }

    class GetTrendsQuery {
        +deviceId: String
        +period: String?
        +startDate: String?
        +endDate: String?
    }
}

namespace infrastructure {
    class AnalyticsGateway {
        <<interface>>
        +getDashboardMetrics(deviceId, period, startDate, endDate) DashboardMetricsResource*
        +getTrends(deviceId, period, startDate, endDate) TrendsResource*
        +streamLiveTelemetry(deviceId) Stream~LiveTelemetry~*
    }

    class AnalyticsHttpGateway {
        -_dio: Dio
        -_tokenStorage: TokenLocalStorage
        +getDashboardMetrics(deviceId, period, startDate, endDate) DashboardMetricsResource
        +getTrends(deviceId, period, startDate, endDate) TrendsResource
        +streamLiveTelemetry(deviceId) Stream~LiveTelemetry~
    }
}

%% Relationships between layers

%% Interfaces to Application, Domain and External Services
AnalyticsCubit --> AnalyticsQueryService : uses
AnalyticsCubit --> AnalyticsState : emits
AnalyticsState --> AnalyticsSelectOption : contains
AnalyticsState --> DashboardMetrics : contains
AnalyticsState --> TrendPoint : contains

%% Application to Domain and Infrastructure
AnalyticsQueryServiceImpl ..|> AnalyticsQueryService : implements
AnalyticsQueryServiceImpl --> AnalyticsGateway : uses
AnalyticsQueryServiceImpl --> LiveTelemetry : streams

%% Domain Types
DashboardMetrics --> Aqi : uses
DashboardMetrics --> MetricDelta : uses

%% Infrastructure to Domain
AnalyticsHttpGateway ..|> AnalyticsGateway : implements
```

---

## 2. Layer-Specific Class Diagrams

### 2.1 Interfaces Layer

```mermaid
---
title: Analytics - Interfaces Layer
---
classDiagram
    class AnalyticsCubit {
        -_analytics: AnalyticsQueryService
        -_organizations: OrganizationsQueryService
        -_spaces: SpacesQueryService
        -_devices: DevicesQueryService
        -_pollTimer: Timer?
        -_secondsTimer: Timer?
        -_liveSub: StreamSubscription?
        +load() void
        +loadOrganizations() void
        +selectOrganization(orgId) void
        +selectSpace(spaceId) void
        +selectDevice(deviceId) void
        +selectPeriod(period) void
        +selectMetric(metric) void
        +fetchData() void
    }

    class AnalyticsState {
        +isLoading: bool
        +errorMessage: String?
        +organizations: List~AnalyticsSelectOption~
        +spaces: List~AnalyticsSelectOption~
        +devices: List~AnalyticsSelectOption~
        +selectedOrgId: String?
        +selectedSpaceId: String?
        +selectedDeviceId: String?
        +selectedPeriod: String
        +selectedMetric: String
        +liveData: DashboardMetrics?
        +trendDataPoints: List~TrendPoint~
        +liveUnavailable: bool
        +liveUnavailableMessage: String
        +secondsSinceUpdate: int
    }

    class AnalyticsSelectOption {
        +id: String
        +name: String
    }

    AnalyticsCubit --> AnalyticsState : emits
    AnalyticsState --> AnalyticsSelectOption : contains
```

### 2.2 Application Layer

```mermaid
---
title: Analytics - Application Layer
---
classDiagram
    class AnalyticsQueryServiceImpl {
        -_gateway: AnalyticsGateway
        +handleGetDashboardMetrics(query) Either
        +handleGetTrends(query) Either
        +handleStreamLiveTelemetry(deviceId) Stream~LiveTelemetry~
    }
```

### 2.3 Domain Layer

```mermaid
---
title: Analytics - Domain Layer
---
classDiagram
    class AnalyticsQueryService {
        <<interface>>
        +handleGetDashboardMetrics(query) Either*
        +handleGetTrends(query) Either*
        +handleStreamLiveTelemetry(deviceId) Stream~LiveTelemetry~*
    }

    class DashboardMetrics {
        +aqi: Aqi
        +co2: MetricDelta
        +pm2_5: MetricDelta
        +temperature: MetricDelta
        +humidity: MetricDelta
        +calculatedAt: DateTime
    }

    class LiveTelemetry {
        +deviceId: String
        +co2: double
        +pm2_5: double
        +temperature: double
        +humidity: double
        +timestamp: DateTime
    }

    class TrendPoint {
        +timestamp: DateTime
        +aqiValue: double
        +co2: double
        +pm2_5: double
        +temperature: double
        +humidity: double
    }

    class Aqi {
        +value: double
        +category: String
    }

    class MetricDelta {
        +value: double
        +deltaPercentage: double?
    }

    DashboardMetrics --> Aqi : uses
    DashboardMetrics --> MetricDelta : uses
```

### 2.4 Infrastructure Layer

```mermaid
---
title: Analytics - Infrastructure Layer
---
classDiagram
    class AnalyticsGateway {
        <<interface>>
        +getDashboardMetrics(deviceId, period, startDate, endDate) DashboardMetricsResource*
        +getTrends(deviceId, period, startDate, endDate) TrendsResource*
        +streamLiveTelemetry(deviceId) Stream~LiveTelemetry~*
    }

    class AnalyticsHttpGateway {
        -_dio: Dio
        -_tokenStorage: TokenLocalStorage
        +getDashboardMetrics(deviceId, period, startDate, endDate) DashboardMetricsResource
        +getTrends(deviceId, period, startDate, endDate) TrendsResource
        +streamLiveTelemetry(deviceId) Stream~LiveTelemetry~
    }

    AnalyticsHttpGateway ..|> AnalyticsGateway : implements
```
