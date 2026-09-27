import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medication_reference/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:medication_reference/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:medication_reference/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:medication_reference/features/medications/domain/entities/medication.dart';

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  const medication = Medication(
    id: 'example',
    brandName: ['Example'],
    genericName: [],
    manufacturer: [],
    purpose: [],
    dosage: [],
    warnings: [],
    activeIngredients: [],
  );

  test(
    'failed save keeps the previous favorite list and reports failure',
    () async {
      final repository = _MockFavoritesRepository();
      when(
        () => repository.saveFavorites([medication]),
      ).thenThrow(StateError('disk unavailable'));
      final cubit = FavoritesCubit(repository);
      addTearDown(cubit.close);

      await cubit.toggle(medication);

      expect(cubit.state.items, isEmpty);
      expect(cubit.state.status, FavoritesStatus.saveFailure);
    },
  );

  test('successful save publishes the new favorite list', () async {
    final repository = _MockFavoritesRepository();
    when(() => repository.saveFavorites([medication])).thenAnswer((_) async {});
    final cubit = FavoritesCubit(repository);
    addTearDown(cubit.close);

    await cubit.toggle(medication);

    expect(cubit.state.items, [medication]);
    expect(cubit.state.status, FavoritesStatus.ready);
  });
}
