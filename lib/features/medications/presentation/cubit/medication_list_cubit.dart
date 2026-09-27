import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import 'medication_list_state.dart';

class MedicationListCubit extends Cubit<MedicationListState> {
  MedicationListCubit(this._repository) : super(const MedicationListState());

  final MedicationRepository _repository;
  int _requestId = 0;
  int _nextSkip = 0;
  Timer? _searchDebounce;

  void updateSearch(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      unawaited(loadInitial());
      return;
    }

    ++_requestId;
    _nextSkip = 0;
    emit(
      state.copyWith(
        status: query.length < AppConfig.searchMinLength
            ? MedicationListStatus.initial
            : MedicationListStatus.loading,
        medications: const [],
        query: query,
        hasMore: false,
        isLoadingMore: false,
        clearFailure: true,
        clearLoadMoreFailure: true,
      ),
    );

    if (query.length >= AppConfig.searchMinLength) {
      _searchDebounce = Timer(
        AppConfig.searchDebounce,
        () => unawaited(loadInitial(query: query)),
      );
    }
  }

  Future<void> submitSearch(String value) async {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty || query.length >= AppConfig.searchMinLength) {
      await loadInitial(query: query);
    } else {
      updateSearch(query);
    }
  }

  Future<void> loadInitial({String? query}) async {
    final normalizedQuery = query?.trim() ?? '';
    final requestId = ++_requestId;
    _nextSkip = 0;
    emit(
      state.copyWith(
        status: MedicationListStatus.loading,
        medications: const [],
        query: normalizedQuery,
        hasMore: true,
        isLoadingMore: false,
        clearFailure: true,
        clearLoadMoreFailure: true,
      ),
    );

    try {
      final result = await _fetchVisiblePage(
        skip: 0,
        query: normalizedQuery.isEmpty ? null : normalizedQuery,
      );
      if (requestId != _requestId || isClosed) {
        return;
      }
      final page = result.page;
      _nextSkip = result.nextSkip;
      emit(
        state.copyWith(
          status: page.items.isEmpty
              ? MedicationListStatus.empty
              : MedicationListStatus.success,
          medications: page.items,
          hasMore: page.hasMore,
          clearFailure: true,
        ),
      );
    } catch (error) {
      if (requestId != _requestId || isClosed) return;
      emit(
        state.copyWith(
          status: MedicationListStatus.failure,
          failure: error is Failure ? error : null,
        ),
      );
    }
  }

  Future<void> refresh() => loadInitial(query: state.query);

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.status != MedicationListStatus.success) {
      return;
    }

    final requestId = _requestId;
    final query = state.query;
    final skip = _nextSkip;
    emit(state.copyWith(isLoadingMore: true, clearLoadMoreFailure: true));
    try {
      final result = await _fetchVisiblePage(
        skip: skip,
        query: query.isEmpty ? null : query,
      );
      if (isClosed || requestId != _requestId) return;
      final page = result.page;
      _nextSkip = result.nextSkip;
      emit(
        state.copyWith(
          medications: [...state.medications, ...page.items],
          hasMore: page.hasMore,
          isLoadingMore: false,
          clearLoadMoreFailure: true,
        ),
      );
    } catch (error) {
      if (isClosed || requestId != _requestId) return;
      emit(
        state.copyWith(
          isLoadingMore: false,
          loadMoreFailure: error is Failure
              ? error
              : const Failure(FailureType.unknown),
        ),
      );
    }
  }

  Future<({MedicationPage page, int nextSkip})> _fetchVisiblePage({
    required int skip,
    required String? query,
  }) async {
    var nextSkip = skip;
    while (true) {
      final page = await _repository.getMedications(
        skip: nextSkip,
        limit: AppConfig.pageSize,
        query: query,
      );
      if (page.hasMore && page.consumedCount <= 0) {
        throw const Failure(FailureType.invalidData);
      }
      nextSkip += page.consumedCount;
      if (page.items.isNotEmpty || !page.hasMore) {
        return (page: page, nextSkip: nextSkip);
      }
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
