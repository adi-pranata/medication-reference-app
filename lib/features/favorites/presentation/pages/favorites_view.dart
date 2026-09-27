import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/presentation/widgets/app_state_views.dart';
import '../../../medications/presentation/widgets/medication_tile.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        if (state.status == FavoritesStatus.loading ||
            state.status == FavoritesStatus.initial) {
          return const AppLoadingView();
        }
        if (state.status == FavoritesStatus.failure) {
          return AppErrorView(
            message: context.l10n.unknownError,
            onRetry: context.read<FavoritesCubit>().load,
          );
        }
        if (state.items.isEmpty) {
          return AppEmptyView(
            title: context.l10n.noFavoritesYet,
            message: context.l10n.saveFavoritesHint,
            icon: Icons.favorite_border,
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(context.spacing.md),
          itemCount: state.items.length,
          separatorBuilder: (_, _) => SizedBox(height: context.spacing.sm),
          itemBuilder: (context, index) =>
              MedicationTile(medication: state.items[index]),
        );
      },
    );
  }
}
