import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../medications/domain/entities/medication.dart';
import '../../domain/repositories/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository) : super(const FavoritesState());

  final FavoritesRepository _repository;
  Future<void> _pendingToggle = Future<void>.value();

  Future<void> load() async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    try {
      final favorites = await _repository.getFavorites();
      emit(FavoritesState(status: FavoritesStatus.ready, items: favorites));
    } catch (_) {
      emit(state.copyWith(status: FavoritesStatus.failure));
    }
  }

  Future<void> toggle(Medication medication) {
    final operation = _pendingToggle.then((_) => _saveToggle(medication));
    _pendingToggle = operation;
    return operation;
  }

  Future<void> _saveToggle(Medication medication) async {
    if (isClosed) return;
    if (state.status == FavoritesStatus.saveFailure) {
      emit(state.copyWith(status: FavoritesStatus.ready));
    }
    final current = [...state.items];
    final index = current.indexWhere((item) => item.id == medication.id);
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.add(medication);
    }
    try {
      await _repository.saveFavorites(current);
      if (!isClosed) {
        emit(state.copyWith(status: FavoritesStatus.ready, items: current));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(status: FavoritesStatus.saveFailure));
      }
    }
  }
}
