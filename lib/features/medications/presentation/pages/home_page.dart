import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../../favorites/presentation/pages/favorites_view.dart';
import '../../../../l10n/app_localizations.dart';
import 'medication_list_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.onLocaleChanged, super.key});

  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoritesCubit, FavoritesState>(
      listenWhen: (previous, current) =>
          previous.status != FavoritesStatus.saveFailure &&
          current.status == FavoritesStatus.saveFailure,
      listener: (context, _) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.favoritesSaveError))),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _selectedIndex == 0
                ? context.l10n.medications
                : context.l10n.favorites,
          ),
          actions: [
            PopupMenuButton<Locale>(
              icon: const Icon(Icons.language),
              onSelected: widget.onLocaleChanged,
              itemBuilder: (context) => [
                for (final locale in AppLocalizations.supportedLocales)
                  PopupMenuItem(
                    value: locale,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(locale.languageCode.toUpperCase()),
                        if (Localizations.localeOf(context).languageCode ==
                            locale.languageCode) ...[
                          SizedBox(width: context.spacing.sm),
                          const Icon(Icons.check, size: 18),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: const [MedicationListView(), FavoritesView()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.medication_outlined),
              selectedIcon: const Icon(Icons.medication),
              label: context.l10n.medications,
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border),
              selectedIcon: const Icon(Icons.favorite),
              label: context.l10n.favorites,
            ),
          ],
        ),
      ),
    );
  }
}
