import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medication_reference/core/localization/app_locale_store.dart';

void main() {
  test('persists a supported language choice across store instances', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = AppLocaleStore(preferences);

    expect(store.read(), isNull);
    await store.save(const Locale('id'));

    expect(AppLocaleStore(preferences).read(), const Locale('id'));
  });

  test('ignores an unsupported saved language', () async {
    SharedPreferences.setMockInitialValues({'app_locale': 'fr'});
    final preferences = await SharedPreferences.getInstance();

    expect(AppLocaleStore(preferences).read(), isNull);
  });
}
