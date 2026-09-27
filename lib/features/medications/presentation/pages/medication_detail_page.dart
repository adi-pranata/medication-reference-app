import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../domain/entities/medication.dart';
import '../widgets/medication_info_section.dart';

class MedicationDetailPage extends StatelessWidget {
  const MedicationDetailPage({required this.medication, super.key});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          medication.displayName.isEmpty
              ? context.l10n.medications
              : medication.displayName,
        ),
        actions: [
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              final isFavorite = state.contains(medication.id);
              return FavoriteButton(
                isFavorite: isFavorite,
                onPressed: () =>
                    context.read<FavoritesCubit>().toggle(medication),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(context.spacing.md),
        children: [
          Text(
            medication.displayName.isEmpty
                ? context.l10n.notAvailable
                : medication.displayName,
            style: context.textStyles.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.spacing.xs),
          Text(
            '${context.l10n.genericName}: ${_value(medication.primaryGenericName, context)}',
          ),
          SizedBox(height: context.spacing.xs),
          Text(
            '${context.l10n.manufacturer}: ${_value(medication.primaryManufacturer, context)}',
          ),
          SizedBox(height: context.spacing.md),
          Text(
            context.l10n.technicalDisclaimer,
            style: context.textStyles.bodySmall,
          ),
          SizedBox(height: context.spacing.lg),
          MedicationInfoSection(
            title: context.l10n.purpose,
            values: medication.purpose,
            fallback: context.l10n.notAvailable,
          ),
          SizedBox(height: context.spacing.sm),
          MedicationInfoSection(
            title: context.l10n.dosage,
            values: medication.dosage,
            fallback: context.l10n.notAvailable,
          ),
          SizedBox(height: context.spacing.sm),
          MedicationInfoSection(
            title: context.l10n.warnings,
            values: medication.warnings,
            fallback: context.l10n.notAvailable,
          ),
          SizedBox(height: context.spacing.sm),
          MedicationInfoSection(
            title: context.l10n.activeIngredients,
            values: medication.activeIngredients,
            fallback: context.l10n.notAvailable,
          ),
        ],
      ),
    );
  }

  String _value(String value, BuildContext context) =>
      value.isEmpty ? context.l10n.notAvailable : value;
}
