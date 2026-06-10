import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/domain/model/valueobjects/access_token.valueobject.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.white70),
      onPressed: () async {
        final token = await getIt<TokenLocalStorage>().getAccessToken();
        if (token != null && token.isNotEmpty) {
          final command = SignOutCommand(accessToken: AccessToken(token));
          await getIt<AuthenticationCommandService>().handleSignOut(command);
        }
        await getIt<TokenLocalStorage>().clearAll();
        if (context.mounted) {
          context.go('/login');
        }
      },
    );
  }
}
