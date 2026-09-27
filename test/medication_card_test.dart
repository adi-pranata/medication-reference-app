import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medication_reference/core/theme/app_theme.dart';
import 'package:medication_reference/features/medications/domain/entities/medication.dart';
import 'package:medication_reference/features/medications/presentation/widgets/medication_card.dart';
import 'package:medication_reference/l10n/app_localizations.dart';

void main() {
  testWidgets('renders medication summary and favorite action', (tester) async {
    const medication = Medication(
      id: 'med-1',
      brandName: ['Example Brand'],
      genericName: ['Example Generic'],
      manufacturer: ['Example Manufacturer'],
      purpose: [],
      dosage: [],
      warnings: [],
      activeIngredients: [],
    );
    var favoriteTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MedicationCard(
            medication: medication,
            isFavorite: false,
            onTap: () {},
            onFavoriteTap: () => favoriteTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Example Brand'), findsOneWidget);
    expect(find.textContaining('Example Generic'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_border));
    expect(favoriteTapped, isTrue);
  });

  testWidgets('uses generic name as title without empty list fields', (
    tester,
  ) async {
    const medication = Medication(
      id: 'generic-only',
      brandName: [],
      genericName: ['Example Generic'],
      manufacturer: [],
      purpose: [],
      dosage: [],
      warnings: [],
      activeIngredients: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MedicationCard(
            medication: medication,
            isFavorite: false,
            onTap: () {},
            onFavoriteTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Example Generic'), findsOneWidget);
    expect(find.textContaining('Not available'), findsNothing);
    expect(find.textContaining('Manufacturer:'), findsNothing);
  });
}
