import '../../medications/domain/entities/medication.dart';

class MedicationFavoriteModel {
  const MedicationFavoriteModel._();

  static Map<String, dynamic> toJson(Medication medication) => {
    'id': medication.id,
    'brandName': medication.brandName,
    'genericName': medication.genericName,
    'manufacturer': medication.manufacturer,
    'purpose': medication.purpose,
    'dosage': medication.dosage,
    'warnings': medication.warnings,
    'activeIngredients': medication.activeIngredients,
  };

  static Medication fromJson(Map<String, dynamic> json) {
    List<String> values(String key) {
      final value = json[key];
      if (value is List) {
        return value
            .whereType<String>()
            .where((item) => item.trim().isNotEmpty)
            .toList();
      }
      if (value is String && value.trim().isNotEmpty) return [value.trim()];
      return const [];
    }

    return Medication(
      id: json['id']?.toString() ?? '',
      brandName: values('brandName'),
      genericName: values('genericName'),
      manufacturer: values('manufacturer'),
      purpose: values('purpose'),
      dosage: values('dosage'),
      warnings: values('warnings'),
      activeIngredients: values('activeIngredients'),
    );
  }
}
