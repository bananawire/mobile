import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/iam/interfaces/pages/settings/settings_cubit.dart';
import 'package:mobile/shared/application/internal/cubits/locale_cubit.dart';
import 'package:mobile/shared/interfaces/widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguage = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: const ClairAppBar(),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (!state.isAuthenticated && !state.isLoading) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                          return;
                        }
                        context.go('/analytics');
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    ),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.settings_language),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentLanguage == 'es' ? l10n.settings_spanish : l10n.settings_english,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: const Color(0xFF121212),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (sheetContext) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  l10n.settings_select_language,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(l10n.settings_english),
                                trailing: currentLanguage == 'en'
                                    ? const Icon(Icons.check, color: Color(0xFF21D07A))
                                    : null,
                                onTap: () {
                                  context.read<LocaleCubit>().changeLocale('en');
                                  Navigator.pop(sheetContext);
                                },
                              ),
                              ListTile(
                                title: Text(l10n.settings_spanish),
                                trailing: currentLanguage == 'es'
                                    ? const Icon(Icons.check, color: Color(0xFF21D07A))
                                    : null,
                                onTap: () {
                                  context.read<LocaleCubit>().changeLocale('es');
                                  Navigator.pop(sheetContext);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.settings_logout),
                  onTap: () => context.read<SettingsCubit>().signOut(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
