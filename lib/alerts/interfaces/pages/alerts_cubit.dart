import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts.query.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_page.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/daily_alert_count.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';
import 'package:mobile/alerts/domain/services/alerts.query-service.dart';

import '../../domain/model/queries/get_alerts_by_space.query.dart';
import '../../domain/model/queries/get_alerts_daily_summary.query.dart';

part 'alerts_state.dart';

enum AlertTab {
  active,
  history,
}

enum AlertViewMode {
  grid,
  list,
}

class AlertsCubit extends Cubit<AlertsState> {
  final AlertsQueryService _queryService;
  String? _selectedSpaceId;

  AlertsCubit(
    this._queryService,
  ) : super(const AlertsState());

  Future<void> load() async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 0,
      activeAlertsPage: null,
      historyAlertsPage: null,
    ));

    _selectedSpaceId = null;
    await loadCurrentUserAlerts(page: 0);
  }

  Future<void> loadAlerts({
    required String spaceId,
    int days = 30,
    int? page,
    int? size,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final currentPage = page ?? state.currentPage;
    final pageSize = size ?? state.pageSize;
    final statusFilter = _statusFilterForTab(state.tab);

    try {
      final alertsFuture = _queryService.handleGetAlertsBySpace(
        GetAlertsBySpaceQuery(
          spaceId: spaceId,
          page: currentPage,
          size: pageSize,
        ),
        status: statusFilter,
      );
      final summaryFuture = _queryService.handleGetDailySummaryBySpace(
        spaceId,
        days,
      );

      final alertsResult = await alertsFuture;
      final summaryResult = await summaryFuture;

      AlertPage? alertsPage;
      List<DailyAlertCount> dailySummary = [];
      String? errorMessage;

      alertsResult.fold(
            (failure) {
          errorMessage = failure.message;
        },
            (page) {
          alertsPage = page;
        },
      );

      summaryResult.fold(
            (failure) {
          errorMessage ??= failure.message;
        },
            (summary) {
          dailySummary = summary;
        },
      );

      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        activeAlertsPage: state.tab == AlertTab.active
            ? alertsPage
            : state.activeAlertsPage,
        historyAlertsPage: state.tab == AlertTab.history
            ? alertsPage
            : state.historyAlertsPage,
        dailySummary: dailySummary,
        currentPage: currentPage,
        pageSize: pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        activeAlertsPage: null,
        historyAlertsPage: null,
        dailySummary: const [],
      ));
    }
  }

  Future<void> loadCurrentUserAlerts({
    int days = 30,
    int? page,
    int? size,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final currentPage = page ?? state.currentPage;
    final pageSize = size ?? state.pageSize;
    final statusFilter = _statusFilterForTab(state.tab);

    try {
      final alertsFuture = _queryService.handleGetAlerts(
        GetAlertsQuery(page: currentPage, size: pageSize),
        status: statusFilter,
      );
      final summaryFuture = _queryService.handleGetDailySummary(
        GetAlertDailySummaryQuery(days: days),
      );

      final alertsResult = await alertsFuture;
      final summaryResult = await summaryFuture;

      AlertPage? alertsPage;
      List<DailyAlertCount> dailySummary = [];
      String? errorMessage;

      alertsResult.fold(
        (failure) {
          errorMessage = failure.message;
        },
        (page) {
          alertsPage = page;
        },
      );

      summaryResult.fold(
        (failure) {
          errorMessage ??= failure.message;
        },
        (summary) {
          dailySummary = summary;
        },
      );

      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        activeAlertsPage: state.tab == AlertTab.active
            ? alertsPage
            : state.activeAlertsPage,
        historyAlertsPage: state.tab == AlertTab.history
            ? alertsPage
            : state.historyAlertsPage,
        dailySummary: dailySummary,
        currentPage: currentPage,
        pageSize: pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        activeAlertsPage: null,
        historyAlertsPage: null,
        dailySummary: const [],
      ));
    }
  }

  void setStatusFilter(AlertStatus? status) {
    emit(state.copyWith(selectedStatus: status));
  }

  void setMetricFilter(MetricType? metric) {
    emit(state.copyWith(selectedMetric: metric));
  }

  void setViewMode(AlertViewMode viewMode) {
    emit(state.copyWith(viewMode: viewMode));
  }

  void setTab(AlertTab tab) {
    emit(state.copyWith(tab: tab, currentPage: 0));
    refreshAlerts();
  }

  Future<void> nextPage() async {
    if (!state.canGoNext) {
      return;
    }
    await _loadPage(state.currentPage + 1);
  }

  Future<void> previousPage() async {
    if (!state.canGoPrevious) {
      return;
    }
    await _loadPage(state.currentPage - 1);
  }

  Future<void> refreshAlerts() async {
    await _loadPage(0);
  }

  Future<void> _loadPage(int page) async {
    final spaceId = _selectedSpaceId;
    if (spaceId == null) {
      await loadCurrentUserAlerts(page: page);
      return;
    }
    await loadAlerts(spaceId: spaceId, page: page);
  }

  List<AlertStatus> _statusFilterForTab(AlertTab tab) {
    return tab == AlertTab.active
        ? const [AlertStatus.active, AlertStatus.acknowledged]
        : const [AlertStatus.resolved];
  }
}
