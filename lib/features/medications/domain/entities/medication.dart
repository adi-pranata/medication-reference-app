import 'package:equatable/equatable.dart';

class Medication extends Equatable {
  const Medication({
    required this.id,
    required this.brandName,
    required this.genericName,
    required this.manufacturer,
    required this.purpose,
    required this.dosage,
    required this.warnings,
    required this.activeIngredients,
  });

  final String id;
  final List<String> brandName;
  final List<String> genericName;
  final List<String> manufacturer;
  final List<String> purpose;
  final List<String> dosage;
  final List<String> warnings;
  final List<String> activeIngredients;

  String get primaryBrandName => _firstOrFallback(brandName);
  String get primaryGenericName => _firstOrFallback(genericName);
  String get primaryManufacturer => _firstOrFallback(manufacturer);
  String get displayName =>
      primaryBrandName.isNotEmpty ? primaryBrandName : primaryGenericName;

  String _firstOrFallback(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  @override
  List<Object?> get props => [
    id,
    brandName,
    genericName,
    manufacturer,
    purpose,
    dosage,
    warnings,
    activeIngredients,
  ];
}

class MedicationPage extends Equatable {
  const MedicationPage({
    required this.items,
    required this.hasMore,
    this.fetchedCount,
  });

  final List<Medication> items;
  final bool hasMore;
  final int? fetchedCount;

  int get consumedCount => fetchedCount ?? items.length;

  @override
  List<Object?> get props => [items, hasMore, fetchedCount];
}
