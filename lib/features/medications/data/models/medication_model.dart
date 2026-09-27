import '../../domain/entities/medication.dart';

class MedicationModel {
  const MedicationModel._();

  static Medication fromJson(Map<String, dynamic> json) {
    final openFda = json['openfda'];
    final openFdaFields = openFda is Map<String, dynamic>
        ? openFda
        : const <String, dynamic>{};

    List<String> normalizedValues(Object? value) {
      if (value is List) {
        return value
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
      if (value is String && value.trim().isNotEmpty) return [value.trim()];
      return const [];
    }

    List<String> values(String key) {
      final directValues = normalizedValues(json[key]);
      return directValues.isNotEmpty
          ? directValues
          : normalizedValues(openFdaFields[key]);
    }

    final brandName = values('brand_name');
    final genericName = values('generic_name');
    final manufacturer = values('manufacturer_name');
    final indications = values('indications_and_usage');
    final fallbackId = [
      brandName.join('|'),
      genericName.join('|'),
      manufacturer.join('|'),
    ].join('::').toLowerCase();

    return Medication(
      id: (json['id'] ?? json['set_id'] ?? fallbackId).toString(),
      brandName: brandName,
      genericName: genericName,
      manufacturer: manufacturer,
      purpose: indications.isNotEmpty ? indications : values('purpose'),
      dosage: values('dosage_and_administration'),
      warnings: values('warnings'),
      activeIngredients: values('active_ingredient'),
    );
  }
}
