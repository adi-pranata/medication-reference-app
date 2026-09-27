import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medication_reference/features/favorites/data/favorites_local_data_source.dart';
import 'package:medication_reference/features/medications/domain/entities/medication.dart';

class _Preferences extends Mock implements SharedPreferences {}

void main() {
  const medication = Medication(
    id: 'stored',
    brandName: ['Stored brand'],
    genericName: [],
    manufacturer: [],
    purpose: ['Stored purpose'],
    dosage: [],
    warnings: [],
    activeIngredients: [],
  );

  test('favorites survive a local JSON round trip', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final dataSource = FavoritesLocalDataSource(preferences);

    await dataSource.write([medication]);

    expect(await dataSource.read(), [medication]);
  });

  test('a failed platform write is reported to the Cubit', () async {
    final preferences = _Preferences();
    when(
      () => preferences.setString('favorite_medications', any()),
    ).thenAnswer((_) async => false);

    await expectLater(
      FavoritesLocalDataSource(preferences).write([medication]),
      throwsStateError,
    );
  });
}
