import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

Widget buildTestableWidget(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
