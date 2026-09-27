import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../domain/entities/medication.dart';

class MedicationCard extends StatelessWidget {
  const MedicationCard({
    required this.medication,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    super.key,
  });

  final Medication medication;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.displayName,
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (medication.primaryBrandName.isNotEmpty &&
                        medication.primaryGenericName.isNotEmpty) ...[
                      SizedBox(height: context.spacing.xs),
                      _FieldText(
                        label: context.l10n.genericName,
                        value: medication.primaryGenericName,
                      ),
                    ],
                    if (medication.primaryManufacturer.isNotEmpty) ...[
                      SizedBox(height: context.spacing.xs),
                      _FieldText(
                        label: context.l10n.manufacturer,
                        value: medication.primaryManufacturer,
                      ),
                    ],
                  ],
                ),
              ),
              FavoriteButton(isFavorite: isFavorite, onPressed: onFavoriteTap),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldText extends StatelessWidget {
  const _FieldText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.textStyles.bodyMedium,
    );
  }
}
