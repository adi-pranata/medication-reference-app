// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Medication Reference';

  @override
  String get medications => 'Medications';

  @override
  String get favorites => 'Favorites';

  @override
  String get searchMedications => 'Search medications';

  @override
  String get searchHint => 'Search by brand or generic name';

  @override
  String get searchMinLengthHint => 'Type at least 2 characters to search.';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noMedicationsFound => 'No medications found';

  @override
  String get noFavoritesYet => 'No favorite medications yet';

  @override
  String get tryDifferentSearch => 'Try a different search term.';

  @override
  String get saveFavoritesHint => 'Save medications here for quick access.';

  @override
  String get retry => 'Retry';

  @override
  String get loadMore => 'Load more';

  @override
  String get loading => 'Loading';

  @override
  String get manufacturer => 'Manufacturer';

  @override
  String get genericName => 'Generic name';

  @override
  String get brandName => 'Brand name';

  @override
  String get purpose => 'Purpose and indications';

  @override
  String get dosage => 'Dosage and administration';

  @override
  String get warnings => 'Warnings';

  @override
  String get activeIngredients => 'Active ingredients';

  @override
  String get notAvailable => 'Not available';

  @override
  String get technicalDisclaimer =>
      'This information is provided for technical demonstration only and is not medical advice.';

  @override
  String get networkError =>
      'We could not connect. Check your connection and try again.';

  @override
  String get serverError =>
      'The medication service is temporarily unavailable.';

  @override
  String get rateLimitError =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get invalidDataError =>
      'The service returned incomplete medication data.';

  @override
  String get unknownError => 'Something went wrong. Please try again.';

  @override
  String get favoriteAdded => 'Added to favorites';

  @override
  String get favoriteRemoved => 'Removed from favorites';

  @override
  String get favoritesSaveError =>
      'Could not save favorites. Please try again.';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get refresh => 'Refresh';

  @override
  String get loadMoreError => 'Could not load more medications.';

  @override
  String get openDetails => 'Open medication details';
}
