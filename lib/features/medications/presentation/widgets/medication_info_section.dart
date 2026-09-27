import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_extensions.dart';

class MedicationInfoSection extends StatelessWidget {
  const MedicationInfoSection({
    required this.title,
    required this.values,
    required this.fallback,
    super.key,
  });

  final String title;
  final List<String> values;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final visibleValues = values
        .where((value) => value.trim().isNotEmpty)
        .toList();
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: context.spacing.sm),
            if (visibleValues.isEmpty)
              Text(fallback)
            else
              ...visibleValues.map(
                (value) => Padding(
                  padding: EdgeInsets.only(bottom: context.spacing.sm),
                  child: Text(value),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
