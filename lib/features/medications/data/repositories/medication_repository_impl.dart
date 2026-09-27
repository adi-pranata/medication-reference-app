import '../../../../core/error/failure.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_data_source.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  MedicationRepositoryImpl(
    this._remoteDataSource, {
    Future<void> Function(Duration)? delay,
  }) : _delay = delay ?? Future<void>.delayed;

  final MedicationRemoteDataSource _remoteDataSource;
  final Future<void> Function(Duration) _delay;

  @override
  Future<MedicationPage> getMedications({
    required int skip,
    required int limit,
    String? query,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await _remoteDataSource.getMedications(
          skip: skip,
          limit: limit,
          query: query,
        );
      } on Failure catch (failure) {
        if (failure.type != FailureType.rateLimited || attempt >= 2) rethrow;
        attempt++;
        await _delay(Duration(milliseconds: 250 * attempt));
      }
    }
  }
}
