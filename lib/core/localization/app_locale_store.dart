import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';

class AppLocaleStore {
  const AppLocaleStore(this._preferences);

  static const _key = 'app_locale';
  final SharedPreferences _preferences;

  Locale? read() {
    final code = _preferences.getString(_key);
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == code) return locale;
    }
    return null;
  }

  Future<void> save(Locale locale) async {
    final saved = await _preferences.setString(_key, locale.languageCode);
    if (!saved) throw StateError('Failed to persist app locale');
  }
}
