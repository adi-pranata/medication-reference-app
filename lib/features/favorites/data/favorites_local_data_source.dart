import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../medications/domain/entities/medication.dart';
import 'medication_favorite_model.dart';

class FavoritesLocalDataSource {
  const FavoritesLocalDataSource(this._preferences);

  static const _key = 'favorite_medications';
  final SharedPreferences _preferences;

  Future<List<Medication>> read() async {
    final encoded = _preferences.getString(_key);
    if (encoded == null || encoded.isEmpty) return const [];

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(MedicationFavoriteModel.fromJson)
          .toList();
    } on FormatException {
      return const [];
    }
  }

  Future<void> write(List<Medication> favorites) async {
    final saved = await _preferences.setString(
      _key,
      jsonEncode(favorites.map(MedicationFavoriteModel.toJson).toList()),
    );
    if (!saved) throw StateError('Failed to persist favorites');
  }
}
