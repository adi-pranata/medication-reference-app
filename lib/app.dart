import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/extensions/build_context_extensions.dart';
import 'core/localization/app_locale_store.dart';
import 'core/theme/app_theme.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/medications/presentation/cubit/medication_list_cubit.dart';
import 'features/medications/presentation/pages/home_page.dart';
import 'injection.dart';
import 'l10n/app_localizations.dart';

class MedicationReferenceApp extends StatefulWidget {
  const MedicationReferenceApp({super.key});

  @override
  State<MedicationReferenceApp> createState() => _MedicationReferenceAppState();
}

class _MedicationReferenceAppState extends State<MedicationReferenceApp> {
  late final AppLocaleStore _localeStore = getIt<AppLocaleStore>();
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = _localeStore.read();
  }

  Future<void> _changeLocale(Locale locale) async {
    setState(() => _locale = locale);
    try {
      await _localeStore.save(locale);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.unknownError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<MedicationListCubit>()),
        BlocProvider(create: (_) => getIt<FavoritesCubit>()..load()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        locale: _locale,
        onGenerateTitle: (context) => context.l10n.appTitle,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: HomePage(onLocaleChanged: _changeLocale),
      ),
    );
  }
}
