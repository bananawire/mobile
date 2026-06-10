import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';

class NotificationIconButton extends StatefulWidget {
  const NotificationIconButton({super.key});

  @override
  State<NotificationIconButton> createState() => _NotificationIconButtonState();
}

class _NotificationIconButtonState extends State<NotificationIconButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        getIt<NotificationsCubit>().loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      bloc: getIt<NotificationsCubit>(),
      builder: (context, state) {
        final unreadCount = state.unreadCount;
        return IconButton(
          icon: Badge(
            label: Text('$unreadCount'),
            isLabelVisible: unreadCount > 0,
            child: const Icon(Icons.notifications_none),
          ),
          onPressed: () {
            final currentLocation = GoRouterState.of(context).matchedLocation;
            if (currentLocation == '/notifications') {
              return;
            }
            context.push('/notifications');
          },
        );
      },
    );
  }
}

