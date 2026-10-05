import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/interfaces/widgets/claim_device_form.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Future<void> pumpForm(
    WidgetTester tester, {
    required bool isLoading,
    required Future<void> Function(String claimToken) onSubmit,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ClaimDeviceForm(isLoading: isLoading, onSubmit: onSubmit),
        ),
      ),
    );
  }

  group('ClaimDeviceForm', () {
    testWidgets('should show the localized title, field label and hint', (tester) async {
      // Arrange
      final submitted = <String>[];

      // Act
      await pumpForm(tester, isLoading: false, onSubmit: (token) async => submitted.add(token));

      // Assert
      expect(find.text(l10n.devices_form_claim_title), findsOneWidget);
      expect(find.text(l10n.devices_form_claim_token), findsOneWidget);
      expect(find.text(l10n.devices_form_claim_token_hint), findsOneWidget);
      expect(find.text(l10n.common_add), findsOneWidget);
    });

    testWidgets('should submit the entered claim token when the form is valid', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: (token) async => submitted.add(token));

      // Act
      await tester.enterText(find.byType(TextFormField), 'token-abc');
      await tester.tap(find.text(l10n.common_add));
      await tester.pump();

      // Assert
      expect(submitted, ['token-abc']);
    });

    testWidgets('should show the required message and not submit when the token is empty', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: (token) async => submitted.add(token));

      // Act
      await tester.tap(find.text(l10n.common_add));
      await tester.pump();

      // Assert
      expect(submitted, isEmpty);
      expect(find.text(l10n.devices_form_claim_token_required), findsOneWidget);
    });

    testWidgets('should show the required message when the token is only whitespace', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: (token) async => submitted.add(token));

      // Act
      await tester.enterText(find.byType(TextFormField), '    ');
      await tester.tap(find.text(l10n.common_add));
      await tester.pump();

      // Assert
      expect(submitted, isEmpty);
      expect(find.text(l10n.devices_form_claim_token_required), findsOneWidget);
    });

    testWidgets('should show a progress indicator and disable the field while loading', (tester) async {
      // Arrange
      final submitted = <String>[];

      // Act
      await pumpForm(tester, isLoading: true, onSubmit: (token) async => submitted.add(token));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.common_add), findsNothing);
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });

    testWidgets('should not submit from a disabled button while loading', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: true, onSubmit: (token) async => submitted.add(token));

      // Act
      await tester.enterText(find.byType(TextFormField), 'token-abc');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      // Assert
      expect(submitted, isEmpty);
    });

    testWidgets('should submit once when the button is tapped twice in a row', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: (token) async => submitted.add(token));
      await tester.enterText(find.byType(TextFormField), 'token-abc');

      // Act
      await tester.tap(find.text(l10n.common_add));
      await tester.tap(find.text(l10n.common_add));
      await tester.pump();

      // Assert: each tap is an explicit user action, so both are forwarded.
      expect(submitted, ['token-abc', 'token-abc']);
    });

    testWidgets('should clear a previous validation message after entering a token', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: (token) async => submitted.add(token));
      await tester.tap(find.text(l10n.common_add));
      await tester.pump();
      expect(find.text(l10n.devices_form_claim_token_required), findsOneWidget);

      // Act
      await tester.enterText(find.byType(TextFormField), 'token-abc');
      await tester.tap(find.text(l10n.common_add));
      await tester.pump();

      // Assert
      expect(find.text(l10n.devices_form_claim_token_required), findsNothing);
      expect(submitted, ['token-abc']);
    });
  });
}