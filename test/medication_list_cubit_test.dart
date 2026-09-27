import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medication_reference/core/error/failure.dart';
import 'package:medication_reference/features/medications/domain/entities/medication.dart';
import 'package:medication_reference/features/medications/domain/repositories/medication_repository.dart';
import 'package:medication_reference/features/medications/presentation/cubit/medication_list_cubit.dart';
import 'package:medication_reference/features/medications/presentation/cubit/medication_list_state.dart';

class _MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  const medication = Medication(
    id: 'med-1',
    brandName: ['Example Brand'],
    genericName: ['Example Generic'],
    manufacturer: ['Example Manufacturer'],
    purpose: [],
    dosage: [],
    warnings: [],
    activeIngredients: [],
  );

  group('MedicationListCubit', () {
    late MedicationRepository repository;

    setUp(() {
      repository = _MockMedicationRepository();
    });

    blocTest<MedicationListCubit, MedicationListState>(
      'emits loading then success when loading medications succeeds',
      build: () {
        when(
          () => repository.getMedications(skip: 0, limit: 20, query: null),
        ).thenAnswer(
          (_) async =>
              const MedicationPage(items: [medication], hasMore: false),
        );
        return MedicationListCubit(repository);
      },
      act: (cubit) => cubit.loadInitial(),
      expect: () => [
        const MedicationListState(status: MedicationListStatus.loading),
        const MedicationListState(
          status: MedicationListStatus.success,
          medications: [medication],
          hasMore: false,
        ),
      ],
    );

    blocTest<MedicationListCubit, MedicationListState>(
      'emits loading then failure when the repository fails',
      build: () {
        when(
          () => repository.getMedications(skip: 0, limit: 20, query: null),
        ).thenThrow(const Failure(FailureType.network));
        return MedicationListCubit(repository);
      },
      act: (cubit) => cubit.loadInitial(),
      expect: () => [
        const MedicationListState(status: MedicationListStatus.loading),
        const MedicationListState(
          status: MedicationListStatus.failure,
          failure: Failure(FailureType.network),
        ),
      ],
    );

    test(
      'skips empty filtered pages and advances by fetched records',
      () async {
        when(
          () => repository.getMedications(skip: 0, limit: 20, query: null),
        ).thenAnswer(
          (_) async =>
              const MedicationPage(items: [], hasMore: true, fetchedCount: 20),
        );
        when(
          () => repository.getMedications(skip: 20, limit: 20, query: null),
        ).thenAnswer(
          (_) async => const MedicationPage(
            items: [medication],
            hasMore: true,
            fetchedCount: 20,
          ),
        );
        when(
          () => repository.getMedications(skip: 40, limit: 20, query: null),
        ).thenAnswer(
          (_) async => const MedicationPage(
            items: [medication],
            hasMore: false,
            fetchedCount: 3,
          ),
        );

        final cubit = MedicationListCubit(repository);
        addTearDown(cubit.close);
        await cubit.loadInitial();
        expect(cubit.state.medications, [medication]);
        expect(cubit.state.status, MedicationListStatus.success);

        await cubit.loadMore();
        verify(
          () => repository.getMedications(skip: 40, limit: 20, query: null),
        ).called(1);
        expect(cubit.state.hasMore, isFalse);
      },
    );

    test('ignores a stale load-more response after a new search', () async {
      const oldMedication = Medication(
        id: 'old',
        brandName: ['Old'],
        genericName: [],
        manufacturer: [],
        purpose: [],
        dosage: [],
        warnings: [],
        activeIngredients: [],
      );
      const newMedication = Medication(
        id: 'new',
        brandName: ['New'],
        genericName: [],
        manufacturer: [],
        purpose: [],
        dosage: [],
        warnings: [],
        activeIngredients: [],
      );
      final oldPage = Completer<MedicationPage>();
      when(
        () => repository.getMedications(skip: 0, limit: 20, query: 'old'),
      ).thenAnswer(
        (_) async =>
            const MedicationPage(items: [oldMedication], hasMore: true),
      );
      when(
        () => repository.getMedications(skip: 1, limit: 20, query: 'old'),
      ).thenAnswer((_) => oldPage.future);
      when(
        () => repository.getMedications(skip: 0, limit: 20, query: 'new'),
      ).thenAnswer(
        (_) async =>
            const MedicationPage(items: [newMedication], hasMore: false),
      );

      final cubit = MedicationListCubit(repository);
      addTearDown(cubit.close);
      await cubit.loadInitial(query: 'old');
      final pending = cubit.loadMore();
      await cubit.loadInitial(query: 'new');
      oldPage.complete(
        const MedicationPage(items: [oldMedication], hasMore: false),
      );
      await pending;

      expect(cubit.state.query, 'new');
      expect(cubit.state.medications, [newMedication]);
      expect(cubit.state.isLoadingMore, isFalse);
    });
  });
}
