import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/interfaces/widgets/create_space_form.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Future<void> pumpForm(
    WidgetTester tester, {
    required bool isLoading,
    required void Function(String name) onSubmit,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CreateSpaceForm(isLoading: isLoading, onSubmit: onSubmit),
        ),
      ),
    );
  }

  group('CreateSpaceForm', () {
    testWidgets('should show the localized title, field label and submit button', (tester) async {
      // Arrange
      final submitted = <String>[];

      // Act
      await pumpForm(tester, isLoading: false, onSubmit: submitted.add);

      // Assert
      expect(find.text(l10n.spaces_btn_create), findsOneWidget);
      expect(find.text(l10n.spaces_form_name_label), findsOneWidget);
      expect(find.text(l10n.common_create), findsOneWidget);
    });

    testWidgets('should submit the entered name when the form is valid', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: submitted.add);

      // Act
      await tester.enterText(find.byType(TextFormField), 'Main Bedroom');
      await tester.tap(find.text(l10n.common_create));
      await tester.pump();

      // Assert
      expect(submitted, ['Main Bedroom']);
    });

    testWidgets('should submit the raw entered text without trimming it', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: submitted.add);

      // Act
      await tester.enterText(find.byType(TextFormField), '  Garage  ');
      await tester.tap(find.text(l10n.common_create));
      await tester.pump();

      // Assert
      expect(submitted, ['  Garage  ']);
    });

    testWidgets('should show the required message and not submit when the name is empty', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: submitted.add);

      // Act
      await tester.tap(find.text(l10n.common_create));
      await tester.pump();

      // Assert
      expect(submitted, isEmpty);
      expect(find.text(l10n.org_form_name_required), findsOneWidget);
    });

    testWidgets('should show the required message when the name is only whitespace', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: submitted.add);

      // Act
      await tester.enterText(find.byType(TextFormField), '    ');
      await tester.tap(find.text(l10n.common_create));
      await tester.pump();

      // Assert
      expect(submitted, isEmpty);
      expect(find.text(l10n.org_form_name_required), findsOneWidget);
    });

    testWidgets('should show the too short message for a one character name', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: submitted.add);

      // Act
      await tester.enterText(find.byType(TextFormField), 'A');
      await tester.tap(find.text(l10n.common_create));
      await tester.pump();

      // Assert
      expect(submitted, isEmpty);
      expect(find.text(l10n.org_form_name_short), findsOneWidget);
    });

    testWidgets('should show the too long message for a name of sixty five characters', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: submitted.add);

      // Act
      await tester.enterText(find.byType(TextFormField), 'x' * 65);
      await tester.tap(find.text(l10n.common_create));
      await tester.pump();

      // Assert
      expect(submitted, isEmpty);
      expect(find.text(l10n.org_form_name_long), findsOneWidget);
    });

    testWidgets('should accept a name of exactly sixty four characters', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: submitted.add);
      final name = 'x' * 64;

      // Act
      await tester.enterText(find.byType(TextFormField), name);
      await tester.tap(find.text(l10n.common_create));
      await tester.pump();

      // Assert
      expect(submitted, [name]);
      expect(find.text(l10n.org_form_name_long), findsNothing);
    });

    testWidgets('should show a progress indicator and disable the field while loading', (tester) async {
      // Arrange
      final submitted = <String>[];

      // Act
      await pumpForm(tester, isLoading: true, onSubmit: submitted.add);

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.common_create), findsNothing);
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });

    testWidgets('should not submit from a disabled button while loading', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: true, onSubmit: submitted.add);

      // Act
      await tester.enterText(find.byType(TextFormField), 'Main Bedroom');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      // Assert
      expect(submitted, isEmpty);
    });

    testWidgets('should submit from the keyboard action when the field is valid', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: submitted.add);

      // Act
      await tester.enterText(find.byType(TextFormField), 'Attic');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Assert
      expect(submitted, ['Attic']);
    });

    testWidgets('should clear a previous validation message after correcting the input', (tester) async {
      // Arrange
      final submitted = <String>[];
      await pumpForm(tester, isLoading: false, onSubmit: submitted.add);
      await tester.enterText(find.byType(TextFormField), 'A');
      await tester.tap(find.text(l10n.common_create));
      await tester.pump();
      expect(find.text(l10n.org_form_name_short), findsOneWidget);

      // Act
      await tester.enterText(find.byType(TextFormField), 'Attic');
      await tester.tap(find.text(l10n.common_create));
      await tester.pump();

      // Assert
      expect(find.text(l10n.org_form_name_short), findsNothing);
      expect(submitted, ['Attic']);
    });
  });
}