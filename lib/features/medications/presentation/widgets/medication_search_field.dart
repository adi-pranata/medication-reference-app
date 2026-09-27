import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_extensions.dart';

class MedicationSearchField extends StatelessWidget {
  const MedicationSearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: context.l10n.searchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  tooltip: context.l10n.clearSearch,
                  icon: const Icon(Icons.clear),
                ),
        ),
      ),
    );
  }
}
