import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/medication.dart';

enum MedicationListStatus { initial, loading, success, empty, failure }

class MedicationListState extends Equatable {
  const MedicationListState({
    this.status = MedicationListStatus.initial,
    this.medications = const [],
    this.query = '',
    this.hasMore = true,
    this.isLoadingMore = false,
    this.failure,
    this.loadMoreFailure,
  });

  final MedicationListStatus status;
  final List<Medication> medications;
  final String query;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? failure;
  final Failure? loadMoreFailure;

  MedicationListState copyWith({
    MedicationListStatus? status,
    List<Medication>? medications,
    String? query,
    bool? hasMore,
    bool? isLoadingMore,
    Failure? failure,
    Failure? loadMoreFailure,
    bool clearFailure = false,
    bool clearLoadMoreFailure = false,
  }) {
    return MedicationListState(
      status: status ?? this.status,
      medications: medications ?? this.medications,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      failure: clearFailure ? null : failure ?? this.failure,
      loadMoreFailure: clearLoadMoreFailure
          ? null
          : loadMoreFailure ?? this.loadMoreFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    medications,
    query,
    hasMore,
    isLoadingMore,
    failure,
    loadMoreFailure,
  ];
}
