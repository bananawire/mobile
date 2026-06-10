import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/notifications/domain/model/queries/get_notifications.query.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';
import 'package:mobile/notifications/domain/services/notifications.query-service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsQueryService _queryService;

  NotificationsCubit(this._queryService) : super(const NotificationsState()) {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.notification.display();
      loadNotifications(isRefresh: true);
    });
  }

  Future<void> loadNotifications({bool isRefresh = false}) async {
    if (state.isLoading) return;

    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
    ));

    final result = await _queryService.handleGetNotifications(
      GetNotificationsQuery(page: 0, size: state.pageSize),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
      (page) {
        emit(state.copyWith(
          isLoading: false,
          notifications: page.content,
          totalElements: page.totalElements,
          totalPages: page.totalPages,
          currentPage: 0,
          isLastPage: page.number >= page.totalPages - 1 || page.content.isEmpty,
        ));
      },
    );
  }

  Future<void> loadMoreNotifications() async {
    if (state.isLoadingMore || state.isLastPage) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;

    final result = await _queryService.handleGetNotifications(
      GetNotificationsQuery(page: nextPage, size: state.pageSize),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        ));
      },
      (page) {
        final updatedNotifications = List<NotificationLog>.from(state.notifications)
          ..addAll(page.content);

        emit(state.copyWith(
          isLoadingMore: false,
          notifications: updatedNotifications,
          totalElements: page.totalElements,
          totalPages: page.totalPages,
          currentPage: nextPage,
          isLastPage: page.number >= page.totalPages - 1 || page.content.isEmpty,
        ));
      },
    );
  }

  void markAllAsSeen() {
    if (state.lastSeenElements == state.totalElements) return;
    emit(state.copyWith(lastSeenElements: state.totalElements));
  }

  void reset() {
    emit(const NotificationsState());
  }
}
