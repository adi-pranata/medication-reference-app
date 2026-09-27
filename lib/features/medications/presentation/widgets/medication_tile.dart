import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../domain/entities/medication.dart';
import '../pages/medication_detail_page.dart';
import 'medication_card.dart';

class MedicationTile extends StatelessWidget {
  const MedicationTile({required this.medication, super.key});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (previous, current) => previous.items != current.items,
      builder: (context, state) => MedicationCard(
        medication: medication,
        isFavorite: state.contains(medication.id),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MedicationDetailPage(medication: medication),
          ),
        ),
        onFavoriteTap: () => context.read<FavoritesCubit>().toggle(medication),
      ),
    );
  }
}
