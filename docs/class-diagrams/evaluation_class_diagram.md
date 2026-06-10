# Unified Class Diagram - Bounded Context: Evaluation

This document contains the class diagrams for the **Evaluation** Bounded Context structured across the 4 layers of Clean Architecture / DDD (Interfaces, Application, Domain, and Infrastructure).

---

## 1. Unified Class Diagram

```mermaid
---
title: DDD Class Diagram - Evaluation Bounded Context (Unified)
---

classDiagram

namespace interfaces {
    class TelemetryEvaluationResponseResource {
        +id: String
        +deviceId: String
        +uptime: int
        +connectivity: ConnectivityResource
        +healthStatus: int
        +status: String
        +recordedAt: DateTime
    }

    class ConnectivityResource {
        +status: String
        +network: String
        +signalStrength: int?
    }
}

namespace application {
    class TelemetryEvaluationQueryServiceImpl {
        -_gateway: TelemetryEvaluationGateway
        +handleGetLatestByDevice(query) Either
    }
}

namespace domain {
    class TelemetryEvaluationQueryService {
        <<interface>>
        +handleGetLatestByDevice(query) Either*
    }

    class TelemetryEvaluationReadModel {
        +id: String
        +deviceId: String
        +uptimeSeconds: int
        +connectivity: Connectivity
        +healthStatus: int
        +status: String
        +recordedAt: DateTime
    }

    class Connectivity {
        +status: String
        +network: String
        +signalStrength: int?
    }

    class GetLatestTelemetryEvaluationByDeviceQuery {
        +deviceId: EvaluationDeviceId
    }

    class EvaluationDeviceId {
        +value: String
    }
}

namespace infrastructure {
    class TelemetryEvaluationGateway {
        <<interface>>
        +getLatestByDeviceRaw(deviceId) Map*
    }

    class TelemetryEvaluationHttpGateway {
        -_dio: Dio
        +getLatestByDeviceRaw(deviceId) Map
    }
}

%% Relationships between layers

%% Interfaces Layer
TelemetryEvaluationResponseResource --> ConnectivityResource : contains

%% Application to Domain and Infrastructure
TelemetryEvaluationQueryServiceImpl ..|> TelemetryEvaluationQueryService : implements
TelemetryEvaluationQueryServiceImpl --> TelemetryEvaluationGateway : uses
TelemetryEvaluationQueryServiceImpl --> TelemetryEvaluationReadModel : returns

%% Domain Types
TelemetryEvaluationReadModel --> Connectivity : contains
GetLatestTelemetryEvaluationByDeviceQuery --> EvaluationDeviceId : uses

%% Infrastructure to Domain
TelemetryEvaluationHttpGateway ..|> TelemetryEvaluationGateway : implements
```

---

## 2. Layer-Specific Class Diagrams

### 2.1 Interfaces Layer
*(Note: Evaluation has no pages or Cubits as its UI presentation is integrated into the Devices Bounded Context via ACL)*

```mermaid
---
title: Evaluation - Interfaces Layer
---
classDiagram
    class TelemetryEvaluationResponseResource {
        +id: String
        +deviceId: String
        +uptime: int
        +connectivity: ConnectivityResource
        +healthStatus: int
        +status: String
        +recordedAt: DateTime
    }

    class ConnectivityResource {
        +status: String
        +network: String
        +signalStrength: int?
    }

    TelemetryEvaluationResponseResource --> ConnectivityResource : contains
```

### 2.2 Application Layer

```mermaid
---
title: Evaluation - Application Layer
---
classDiagram
    class TelemetryEvaluationQueryServiceImpl {
        -_gateway: TelemetryEvaluationGateway
        +handleGetLatestByDevice(query) Either
    }
```

### 2.3 Domain Layer

```mermaid
---
title: Evaluation - Domain Layer
---
classDiagram
    class TelemetryEvaluationQueryService {
        <<interface>>
        +handleGetLatestByDevice(query) Either*
    }

    class TelemetryEvaluationReadModel {
        +id: String
        +deviceId: String
        +uptimeSeconds: int
        +connectivity: Connectivity
        +healthStatus: int
        +status: String
        +recordedAt: DateTime
    }

    class Connectivity {
        +status: String
        +network: String
        +signalStrength: int?
    }

    class GetLatestTelemetryEvaluationByDeviceQuery {
        +deviceId: EvaluationDeviceId
    }

    class EvaluationDeviceId {
        +value: String
    }

    TelemetryEvaluationReadModel --> Connectivity : contains
    GetLatestTelemetryEvaluationByDeviceQuery --> EvaluationDeviceId : uses
```

### 2.4 Infrastructure Layer

```mermaid
---
title: Evaluation - Infrastructure Layer
---
classDiagram
    class TelemetryEvaluationGateway {
        <<interface>>
        +getLatestByDeviceRaw(deviceId) Map*
    }

    class TelemetryEvaluationHttpGateway {
        -_dio: Dio
        +getLatestByDeviceRaw(deviceId) Map
    }

    TelemetryEvaluationHttpGateway ..|> TelemetryEvaluationGateway : implements
```
