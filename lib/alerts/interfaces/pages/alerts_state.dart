part of 'alerts_cubit.dart';

const _sentinel = Object();

class AlertsState {
  final bool isLoading;
  final String? errorMessage;
  final AlertPage? activeAlertsPage;
  final AlertPage? historyAlertsPage;
  final List<DailyAlertCount> dailySummary;
  final AlertStatus? selectedStatus;
  final MetricType? selectedMetric;
  final AlertViewMode viewMode;
  final AlertTab tab;
  final int currentPage;
  final int pageSize;

  const AlertsState({
    this.isLoading = false,
    this.errorMessage,
    this.activeAlertsPage,
    this.historyAlertsPage,
    this.dailySummary = const [],
    this.selectedStatus,
    this.selectedMetric,
    this.viewMode = AlertViewMode.list,
    this.tab = AlertTab.active,
    this.currentPage = 0,
    this.pageSize = 20,
  });

  List<Alert> get currentAlerts => tab == AlertTab.active
      ? activeAlertsPage?.content ?? const []
      : historyAlertsPage?.content ?? const [];

  int get totalPages => tab == AlertTab.active
      ? activeAlertsPage?.totalPages ?? 1
      : historyAlertsPage?.totalPages ?? 1;

  bool get canGoPrevious => currentPage > 0;

  bool get canGoNext => currentPage < totalPages - 1;

  AlertsState copyWith({
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Object? activeAlertsPage = _sentinel,
    Object? historyAlertsPage = _sentinel,
    List<DailyAlertCount>? dailySummary,
    Object? selectedStatus = _sentinel,
    Object? selectedMetric = _sentinel,
    AlertViewMode? viewMode,
    AlertTab? tab,
    int? currentPage,
    int? pageSize,
  }) {
    return AlertsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      activeAlertsPage: activeAlertsPage == _sentinel
          ? this.activeAlertsPage
          : activeAlertsPage as AlertPage?,
      historyAlertsPage: historyAlertsPage == _sentinel
          ? this.historyAlertsPage
          : historyAlertsPage as AlertPage?,
      dailySummary: dailySummary ?? this.dailySummary,
      selectedStatus: selectedStatus == _sentinel
          ? this.selectedStatus
          : selectedStatus as AlertStatus?,
      selectedMetric: selectedMetric == _sentinel
          ? this.selectedMetric
          : selectedMetric as MetricType?,
      viewMode: viewMode ?? this.viewMode,
      tab: tab ?? this.tab,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
