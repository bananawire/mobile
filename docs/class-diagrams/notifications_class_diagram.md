# Unified Class Diagram - Bounded Context: Notifications

This document contains the class diagrams for the **Notifications** Bounded Context structured across the 4 layers of Clean Architecture / DDD (Interfaces, Application, Domain, and Infrastructure).

---

## 1. Unified Class Diagram

```mermaid
---
title: DDD Class Diagram - Notifications Bounded Context (Unified)
---

classDiagram

namespace interfaces {
    class NotificationsCubit {
        -_queryService: NotificationsQueryService
        +loadNotifications(isRefresh) void
        +loadMoreNotifications() void
        +markAllAsSeen() void
        +reset() void
    }

    class NotificationsState {
        +isLoading: bool
        +isLoadingMore: bool
        +errorMessage: String?
        +notifications: List~NotificationLog~
        +totalElements: int
        +totalPages: int
        +currentPage: int
        +pageSize: int
        +isLastPage: bool
        +lastSeenElements: int
        +unreadCount: int
    }
}

namespace application {
    class NotificationsQueryServiceImpl {
        -_gateway: NotificationsGateway
        +handleGetNotifications(query) Either
    }
}

namespace domain {
    class NotificationsQueryService {
        <<interface>>
        +handleGetNotifications(query) Either*
    }

    class NotificationLog {
        +id: NotificationId
        +userId: String
        +alertId: String?
        +title: String
        +message: String
        +sent: bool
        +errorMessage: String?
        +createdAt: DateTime
        +updatedAt: DateTime
    }

    class NotificationPage {
        +content: List~NotificationLog~
        +totalElements: int
        +totalPages: int
        +number: int
        +size: int
    }

    class NotificationId {
        +value: String
    }

    class GetNotificationsQuery {
        +page: int
        +size: int
    }
}

namespace infrastructure {
    class NotificationsGateway {
        <<interface>>
        +getNotifications(page, size) NotificationPageResource*
    }

    class NotificationsHttpGateway {
        -_dio: Dio
        +getNotifications(page, size) NotificationPageResource
    }
}

%% Relationships between layers

%% Interfaces to Application and Domain
NotificationsCubit --> NotificationsQueryService : uses
NotificationsCubit --> NotificationsState : emits
NotificationsState --> NotificationLog : contains

%% Application to Domain and Infrastructure
NotificationsQueryServiceImpl ..|> NotificationsQueryService : implements
NotificationsQueryServiceImpl --> NotificationsGateway : uses
NotificationsQueryServiceImpl --> NotificationPage : returns

%% Domain Elements
NotificationPage --> NotificationLog : contains
NotificationLog --> NotificationId : uses

%% Infrastructure to Domain
NotificationsHttpGateway ..|> NotificationsGateway : implements
```

---

## 2. Layer-Specific Class Diagrams

### 2.1 Interfaces Layer

```mermaid
---
title: Notifications - Interfaces Layer
---
classDiagram
    class NotificationsCubit {
        -_queryService: NotificationsQueryService
        +loadNotifications(isRefresh) void
        +loadMoreNotifications() void
        +markAllAsSeen() void
        +reset() void
    }

    class NotificationsState {
        +isLoading: bool
        +isLoadingMore: bool
        +errorMessage: String?
        +notifications: List~NotificationLog~
        +totalElements: int
        +totalPages: int
        +currentPage: int
        +pageSize: int
        +isLastPage: bool
        +lastSeenElements: int
        +unreadCount: int
    }

    NotificationsCubit --> NotificationsState : emits
```

### 2.2 Application Layer

```mermaid
---
title: Notifications - Application Layer
---
classDiagram
    class NotificationsQueryServiceImpl {
        -_gateway: NotificationsGateway
        +handleGetNotifications(query) Either
    }
```

### 2.3 Domain Layer

```mermaid
---
title: Notifications - Domain Layer
---
classDiagram
    class NotificationsQueryService {
        <<interface>>
        +handleGetNotifications(query) Either*
    }

    class NotificationLog {
        +id: NotificationId
        +userId: String
        +alertId: String?
        +title: String
        +message: String
        +sent: bool
        +errorMessage: String?
        +createdAt: DateTime
        +updatedAt: DateTime
    }

    class NotificationPage {
        +content: List~NotificationLog~
        +totalElements: int
        +totalPages: int
        +number: int
        +size: int
    }

    class NotificationId {
        +value: String
    }

    NotificationPage --> NotificationLog : contains
    NotificationLog --> NotificationId : uses
```

### 2.4 Infrastructure Layer

```mermaid
---
title: Notifications - Infrastructure Layer
---
classDiagram
    class NotificationsGateway {
        <<interface>>
        +getNotifications(page, size) NotificationPageResource*
    }

    class NotificationsHttpGateway {
        -_dio: Dio
        +getNotifications(page, size) NotificationPageResource
    }

    NotificationsHttpGateway ..|> NotificationsGateway : implements
```
