import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

/// Wraps [child] in a localized [MaterialApp] usable inside `testWidgets`.
///
/// This helper is intentionally NOT named `*_test.dart` so that the test
/// runner never executes it as a suite.
Widget localizedAnalyticsApp(Widget child, {double? width}) {
  final content = width == null ? child : SizedBox(width: width, child: child);
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: content)),
  );
}

/// Finds the small circular status dot of a metric card by its decoration.
Finder statusDot() {
  return find.byWidgetPredicate((widget) {
    if (widget is! Container) return false;
    final decoration = widget.decoration;
    return decoration is BoxDecoration && decoration.shape == BoxShape.circle;
  });
}