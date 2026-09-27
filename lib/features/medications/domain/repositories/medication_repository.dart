import '../entities/medication.dart';

abstract interface class MedicationRepository {
  Future<MedicationPage> getMedications({
    required int skip,
    required int limit,
    String? query,
  });
}
