# Unified Class Diagram - Bounded Context: Alerts

This document contains the class diagrams for the **Alerts** Bounded Context structured across the 4 layers of Clean Architecture / DDD (Interfaces, Application, Domain, and Infrastructure).

---

## 1. Unified Class Diagram

```mermaid
---
title: DDD Class Diagram - Alerts Bounded Context (Unified)
---

classDiagram

namespace interfaces {
    class AlertsCubit {
        -_queryService: AlertsQueryService
        -_selectedSpaceId: String?
        +load() void
        +loadAlerts(spaceId, days, page, size) void
        +loadCurrentUserAlerts(days, page, size) void
        +setStatusFilter(status) void
        +setMetricFilter(metric) void
        +setViewMode(viewMode) void
        +setTab(tab) void
        +nextPage() void
        +previousPage() void
        +refreshAlerts() void
    }

    class AlertsState {
        +isLoading: bool
        +errorMessage: String?
        +activeAlertsPage: AlertPage?
        +historyAlertsPage: AlertPage?
        +dailySummary: List~DailyAlertCount~
        +currentPage: int
        +pageSize: int
        +selectedStatus: AlertStatus?
        +selectedMetric: MetricType?
        +viewMode: AlertViewMode
        +tab: AlertTab
    }

    class AlertTab {
        <<enumeration>>
        active
        history
    }

    class AlertViewMode {
        <<enumeration>>
        grid
        list
    }
}

namespace application {
    class AlertsQueryServiceImpl {
        -_gateway: AlertsGateway
        +handleGetAlerts(query, status) Either
        +handleGetAlertsByDevice(query, status) Either
        +handleGetAlertsBySpace(query, status) Either
        +handleGetDailySummary(query) Either
        +handleGetDailySummaryBySpace(spaceId, days) Either
    }
}

namespace domain {
    class AlertsQueryService {
        <<interface>>
        +handleGetAlerts(query, status) Either*
        +handleGetAlertsByDevice(query, status) Either*
        +handleGetAlertsBySpace(query, status) Either*
        +handleGetDailySummary(query) Either*
        +handleGetDailySummaryBySpace(spaceId, days) Either*
    }

    class AlertsCommandService {
        <<interface>>
        +handleAcknowledgeAlert(command) Either*
        +handleRefreshAlerts(command) Either*
    }

    class Alert {
        +id: String
        +deviceId: String
        +metricType: MetricType
        +triggerValue: double
        +thresholdValue: double
        +status: AlertStatus
        +createdAt: DateTime
        +resolvedAt: DateTime?
    }

    class AlertPage {
        +content: List~Alert~
        +totalElements: int
        +number: int
        +size: int
    }

    class AlertStatus {
        <<enumeration>>
        active
        acknowledged
        resolved
    }

    class DailyAlertCount {
        +date: DateTime
        +count: int
    }

    class MetricType {
        <<enumeration>>
        pm25
        co2
        temperature
        humidity
    }

    class GetAlertsQuery {
        +page: int
        +size: int
    }

    class GetAlertsBySpaceQuery {
        +spaceId: String
        +page: int
        +size: int
    }
}

namespace infrastructure {
    class AlertsGateway {
        <<interface>>
        +getAlerts(page, size, status) AlertPageResource*
        +getAlertsByDevice(deviceId, page, size, status) AlertPageResource*
        +getAlertsBySpace(spaceId, page, size, status) AlertPageResource*
        +getCurrentUserDailyAlertSummary(days) List*
        +getDailyAlertSummary(spaceId, days) List*
    }

    class AlertsHttpGateway {
        -_dio: Dio
        +getAlerts(page, size, status) AlertPageResource
        +getAlertsByDevice(deviceId, page, size, status) AlertPageResource
        +getAlertsBySpace(spaceId, page, size, status) AlertPageResource
        +getCurrentUserDailyAlertSummary(days) List
        +getDailyAlertSummary(spaceId, days) List
    }
}

%% Relationships between layers

%% Interfaces to Application and Domain
AlertsCubit --> AlertsQueryService : uses
AlertsCubit --> AlertsState : emits
AlertsState --> AlertTab : uses
AlertsState --> AlertViewMode : uses
AlertsState --> AlertStatus : uses
AlertsState --> MetricType : uses
AlertsState --> AlertPage : contains
AlertsState --> DailyAlertCount : contains

%% Application to Domain and Infrastructure
AlertsQueryServiceImpl ..|> AlertsQueryService : implements
AlertsQueryServiceImpl --> AlertsGateway : uses
AlertsQueryServiceImpl --> AlertPage : maps to
AlertsQueryServiceImpl --> DailyAlertCount : maps to

%% Domain Elements
AlertPage --> Alert : contains
Alert --> AlertStatus : uses
Alert --> MetricType : uses

%% Infrastructure to Domain
AlertsHttpGateway ..|> AlertsGateway : implements
```

---

## 2. Layer-Specific Class Diagrams

### 2.1 Interfaces Layer

```mermaid
---
title: Alerts - Interfaces Layer
---
classDiagram
    class AlertsCubit {
        -_queryService: AlertsQueryService
        -_selectedSpaceId: String?
        +load() void
        +loadAlerts(spaceId, days, page, size) void
        +loadCurrentUserAlerts(days, page, size) void
        +setStatusFilter(status) void
        +setMetricFilter(metric) void
        +setViewMode(viewMode) void
        +setTab(tab) void
        +nextPage() void
        +previousPage() void
        +refreshAlerts() void
    }

    class AlertsState {
        +isLoading: bool
        +errorMessage: String?
        +activeAlertsPage: AlertPage?
        +historyAlertsPage: AlertPage?
        +dailySummary: List~DailyAlertCount~
        +currentPage: int
        +pageSize: int
        +selectedStatus: AlertStatus?
        +selectedMetric: MetricType?
        +viewMode: AlertViewMode
        +tab: AlertTab
    }

    class AlertTab {
        <<enumeration>>
        active
        history
    }

    class AlertViewMode {
        <<enumeration>>
        grid
        list
    }

    AlertsCubit --> AlertsState : emits
    AlertsState --> AlertTab : uses
    AlertsState --> AlertViewMode : uses
```

### 2.2 Application Layer

```mermaid
---
title: Alerts - Application Layer
---
classDiagram
    class AlertsQueryServiceImpl {
        -_gateway: AlertsGateway
        +handleGetAlerts(query, status) Either
        +handleGetAlertsByDevice(query, status) Either
        +handleGetAlertsBySpace(query, status) Either
        +handleGetDailySummary(query) Either
        +handleGetDailySummaryBySpace(spaceId, days) Either
    }
```

### 2.3 Domain Layer

```mermaid
---
title: Alerts - Domain Layer
---
classDiagram
    class AlertsQueryService {
        <<interface>>
        +handleGetAlerts(query, status) Either*
        +handleGetAlertsByDevice(query, status) Either*
        +handleGetAlertsBySpace(query, status) Either*
        +handleGetDailySummary(query) Either*
        +handleGetDailySummaryBySpace(spaceId, days) Either*
    }

    class AlertsCommandService {
        <<interface>>
        +handleAcknowledgeAlert(command) Either*
        +handleRefreshAlerts(command) Either*
    }

    class Alert {
        +id: String
        +deviceId: String
        +metricType: MetricType
        +triggerValue: double
        +thresholdValue: double
        +status: AlertStatus
        +createdAt: DateTime
        +resolvedAt: DateTime?
    }

    class AlertPage {
        +content: List~Alert~
        +totalElements: int
        +number: int
        +size: int
    }

    class AlertStatus {
        <<enumeration>>
        active
        acknowledged
        resolved
    }

    class DailyAlertCount {
        +date: DateTime
        +count: int
    }

    class MetricType {
        <<enumeration>>
        pm25
        co2
        temperature
        humidity
    }

    AlertPage --> Alert : contains
    Alert --> AlertStatus : uses
    Alert --> MetricType : uses
```

### 2.4 Infrastructure Layer

```mermaid
---
title: Alerts - Infrastructure Layer
---
classDiagram
    class AlertsGateway {
        <<interface>>
        +getAlerts(page, size, status) AlertPageResource*
        +getAlertsByDevice(deviceId, page, size, status) AlertPageResource*
        +getAlertsBySpace(spaceId, page, size, status) AlertPageResource*
        +getCurrentUserDailyAlertSummary(days) List*
        +getDailyAlertSummary(spaceId, days) List*
    }

    class AlertsHttpGateway {
        -_dio: Dio
        +getAlerts(page, size, status) AlertPageResource
        +getAlertsByDevice(deviceId, page, size, status) AlertPageResource
        +getAlertsBySpace(spaceId, page, size, status) AlertPageResource
        +getCurrentUserDailyAlertSummary(days) List
        +getDailyAlertSummary(spaceId, days) List
    }

    AlertsHttpGateway ..|> AlertsGateway : implements
```
