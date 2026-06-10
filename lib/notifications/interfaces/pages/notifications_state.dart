part of 'notifications_cubit.dart';

const _sentinel = Object();

class NotificationsState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<NotificationLog> notifications;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool isLastPage;
  final int lastSeenElements;

  const NotificationsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.notifications = const [],
    this.totalElements = 0,
    this.totalPages = 1,
    this.currentPage = 0,
    this.pageSize = 20,
    this.isLastPage = true,
    this.lastSeenElements = 0,
  });

  int get unreadCount {
    final count = totalElements - lastSeenElements;
    return count < 0 ? 0 : count;
  }

  NotificationsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
    List<NotificationLog>? notifications,
    int? totalElements,
    int? totalPages,
    int? currentPage,
    int? pageSize,
    bool? isLastPage,
    int? lastSeenElements,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      notifications: notifications ?? this.notifications,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      isLastPage: isLastPage ?? this.isLastPage,
      lastSeenElements: lastSeenElements ?? this.lastSeenElements,
    );
  }
}
