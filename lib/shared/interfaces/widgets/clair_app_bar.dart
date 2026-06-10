import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/notifications/interfaces/widgets/notification_icon_button.dart';
import 'package:mobile/shared/interfaces/widgets/clair_name.dart';

class ClairAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final String? backFallbackLocation;

  const ClairAppBar({
    super.key,
    this.showBack = false,
    this.backFallbackLocation,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                  return;
                }
                final fallback = backFallbackLocation;
                if (fallback != null) {
                  context.go(fallback);
                }
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
            )
          : null,
      title: const ClairName(height: 18),
      actions: [
        const NotificationIconButton(),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            final currentLocation = GoRouterState.of(context).matchedLocation;
            if (currentLocation == '/settings') {
              return;
            }
            context.push('/settings');
          },
        ),
      ],
    );
  }
}
