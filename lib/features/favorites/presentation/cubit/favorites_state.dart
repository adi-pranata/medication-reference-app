import 'package:equatable/equatable.dart';

import '../../../medications/domain/entities/medication.dart';

enum FavoritesStatus { initial, loading, ready, failure, saveFailure }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.items = const [],
  });

  final FavoritesStatus status;
  final List<Medication> items;

  bool contains(String id) => items.any((item) => item.id == id);

  FavoritesState copyWith({FavoritesStatus? status, List<Medication>? items}) {
    return FavoritesState(
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [status, items];
}
