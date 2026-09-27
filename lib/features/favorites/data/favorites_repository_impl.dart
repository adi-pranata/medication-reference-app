import '../../medications/domain/entities/medication.dart';
import '../domain/repositories/favorites_repository.dart';
import 'favorites_local_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl(this._localDataSource);

  final FavoritesLocalDataSource _localDataSource;

  @override
  Future<List<Medication>> getFavorites() => _localDataSource.read();

  @override
  Future<void> saveFavorites(List<Medication> favorites) =>
      _localDataSource.write(favorites);
}
