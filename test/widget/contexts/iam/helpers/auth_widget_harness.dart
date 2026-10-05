import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

/// Wraps [child] in a localized [MaterialApp] usable inside `testWidgets`.
Widget localizedApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}