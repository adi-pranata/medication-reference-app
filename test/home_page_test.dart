import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medication_reference/core/error/failure.dart';
import 'package:medication_reference/core/theme/app_theme.dart';
import 'package:medication_reference/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:medication_reference/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:medication_reference/features/medications/domain/entities/medication.dart';
import 'package:medication_reference/features/medications/domain/repositories/medication_repository.dart';
import 'package:medication_reference/features/medications/presentation/cubit/medication_list_cubit.dart';
import 'package:medication_reference/features/medications/presentation/pages/home_page.dart';
import 'package:medication_reference/l10n/app_localizations.dart';

class _MedicationRepository extends Mock implements MedicationRepository {}

class _FavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  const medication = Medication(
    id: 'sample',
    brandName: ['Sample Brand'],
    genericName: [],
    manufacturer: [],
    purpose: [],
    dosage: [],
    warnings: [],
    activeIngredients: [],
  );

  Future<({MedicationListCubit list, FavoritesCubit favorites})> showHome(
    WidgetTester tester, {
    required MedicationRepository medications,
    required FavoritesRepository favorites,
    Locale locale = const Locale('en'),
    ValueChanged<Locale>? onLocaleChanged,
  }) async {
    final listCubit = MedicationListCubit(medications);
    final favoritesCubit = FavoritesCubit(favorites);
    var activeLocale = locale;
    addTearDown(listCubit.close);
    addTearDown(favoritesCubit.close);
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: listCubit),
            BlocProvider.value(value: favoritesCubit),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            locale: activeLocale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomePage(
              onLocaleChanged: (selected) {
                setState(() => activeLocale = selected);
                onLocaleChanged?.call(selected);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return (list: listCubit, favorites: favoritesCubit);
  }

  testWidgets('shows loading feedback until the first page arrives', (
    tester,
  ) async {
    final medications = _MedicationRepository();
    final pendingPage = Completer<MedicationPage>();
    when(
      () => medications.getMedications(skip: 0, limit: 20, query: null),
    ).thenAnswer((_) => pendingPage.future);

    await showHome(
      tester,
      medications: medications,
      favorites: _FavoritesRepository(),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pendingPage.complete(const MedicationPage(items: [], hasMore: false));
    await tester.pump();
    expect(find.text('No medications found'), findsOneWidget);
  });

  testWidgets('English empty search shows an empty state', (tester) async {
    final medications = _MedicationRepository();
    when(
      () => medications.getMedications(skip: 0, limit: 20, query: null),
    ).thenAnswer((_) async => const MedicationPage(items: [], hasMore: false));

    await showHome(
      tester,
      medications: medications,
      favorites: _FavoritesRepository(),
    );

    expect(find.text('No medications found'), findsOneWidget);
    expect(
      find.text('Save medications here for quick access.'),
      findsOneWidget,
    );
  });

  testWidgets('search reacts while typing and only requests after debounce', (
    tester,
  ) async {
    final medications = _MedicationRepository();
    final searchResult = Completer<MedicationPage>();
    when(
      () => medications.getMedications(skip: 0, limit: 20, query: null),
    ).thenAnswer(
      (_) async => const MedicationPage(items: [medication], hasMore: false),
    );
    when(
      () => medications.getMedications(skip: 0, limit: 20, query: 'Be'),
    ).thenAnswer((_) => searchResult.future);

    await showHome(
      tester,
      medications: medications,
      favorites: _FavoritesRepository(),
    );

    await tester.enterText(find.byType(TextField), 'B');
    await tester.pump();
    expect(find.text('Type at least 2 characters to search.'), findsOneWidget);
    verifyNever(
      () => medications.getMedications(skip: 0, limit: 20, query: 'B'),
    );

    await tester.enterText(find.byType(TextField), 'Be');
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 349));
    verifyNever(
      () => medications.getMedications(skip: 0, limit: 20, query: 'Be'),
    );
    await tester.pump(const Duration(milliseconds: 1));
    verify(
      () => medications.getMedications(skip: 0, limit: 20, query: 'Be'),
    ).called(1);

    searchResult.complete(
      const MedicationPage(items: [medication], hasMore: false),
    );
    await tester.pump();
    expect(find.text('Sample Brand'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.text('Sample Brand'), findsOneWidget);
    verify(
      () => medications.getMedications(skip: 0, limit: 20, query: null),
    ).called(2);
  });

  testWidgets('language menu sends the selected locale', (tester) async {
    final medications = _MedicationRepository();
    when(
      () => medications.getMedications(skip: 0, limit: 20, query: null),
    ).thenAnswer((_) async => const MedicationPage(items: [], hasMore: false));
    Locale? selectedLocale;

    await showHome(
      tester,
      medications: medications,
      favorites: _FavoritesRepository(),
      onLocaleChanged: (locale) => selectedLocale = locale,
    );

    await tester.tap(find.byIcon(Icons.language));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('EN'), findsOneWidget);
    await tester.tap(find.text('ID'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(selectedLocale, const Locale('id'));
    expect(find.text('Obat'), findsWidgets);
    expect(find.text('Favorit'), findsOneWidget);
  });

  testWidgets('Indonesian error state retries successfully', (tester) async {
    final medications = _MedicationRepository();
    var attempts = 0;
    when(
      () => medications.getMedications(skip: 0, limit: 20, query: null),
    ).thenAnswer((_) async {
      attempts++;
      if (attempts == 1) throw const Failure(FailureType.network);
      return const MedicationPage(items: [medication], hasMore: false);
    });

    await showHome(
      tester,
      medications: medications,
      favorites: _FavoritesRepository(),
      locale: const Locale('id'),
    );

    expect(
      find.text('Tidak dapat terhubung. Periksa koneksi Anda dan coba lagi.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Coba Lagi'));
    await tester.pump();
    expect(find.text('Sample Brand'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets(
    'failed favorite save shows localized feedback and keeps icon unchanged',
    (tester) async {
      final medications = _MedicationRepository();
      final favorites = _FavoritesRepository();
      when(
        () => medications.getMedications(skip: 0, limit: 20, query: null),
      ).thenAnswer(
        (_) async => const MedicationPage(items: [medication], hasMore: false),
      );
      when(
        () => favorites.saveFavorites([medication]),
      ).thenThrow(StateError('disk unavailable'));

      await showHome(tester, medications: medications, favorites: favorites);
      await tester.tap(find.byTooltip('Add to favorites'));
      await tester.pump();

      expect(
        find.text('Could not save favorites. Please try again.'),
        findsOneWidget,
      );
      expect(find.byTooltip('Add to favorites'), findsOneWidget);
    },
  );

  testWidgets('favorite load error shows a retry action', (tester) async {
    final medications = _MedicationRepository();
    final favorites = _FavoritesRepository();
    when(
      () => medications.getMedications(skip: 0, limit: 20, query: null),
    ).thenAnswer((_) async => const MedicationPage(items: [], hasMore: false));
    when(favorites.getFavorites).thenThrow(StateError('read unavailable'));

    final cubits = await showHome(
      tester,
      medications: medications,
      favorites: favorites,
    );
    await cubits.favorites.load();
    await tester.tap(find.text('Favorites'));
    await tester.pump();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}
