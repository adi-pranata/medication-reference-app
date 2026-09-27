import '../../../medications/domain/entities/medication.dart';

abstract interface class FavoritesRepository {
  Future<List<Medication>> getFavorites();

  Future<void> saveFavorites(List<Medication> favorites);
}
