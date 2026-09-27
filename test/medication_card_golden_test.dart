import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medication_reference/core/theme/app_theme.dart';
import 'package:medication_reference/features/medications/domain/entities/medication.dart';
import 'package:medication_reference/features/medications/presentation/widgets/medication_card.dart';
import 'package:medication_reference/l10n/app_localizations.dart';

void main() {
  testWidgets('dark medication card with long and missing fields', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const medication = Medication(
      id: 'long',
      brandName: ['A long medication brand name for layout verification'],
      genericName: [],
      manufacturer: ['Example Manufacturer'],
      purpose: [],
      dosage: [],
      warnings: [],
      activeIngredients: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MedicationCard(
                medication: medication,
                isFavorite: true,
                onTap: () {},
                onFavoriteTap: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      Theme.of(tester.element(find.byType(MedicationCard))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/medication_card_dark.png'),
    );
  });
}
