import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';

extension BuildContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textStyles => Theme.of(this).textTheme;

  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;
}
