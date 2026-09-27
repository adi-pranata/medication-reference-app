import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_extensions.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
    super.key,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: isFavorite
          ? context.l10n.removeFromFavorites
          : context.l10n.addToFavorites,
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      color: isFavorite ? context.colors.error : context.colors.primary,
    );
  }
}
