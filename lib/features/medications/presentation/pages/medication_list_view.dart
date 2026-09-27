import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/presentation/widgets/app_state_views.dart';
import '../cubit/medication_list_cubit.dart';
import '../cubit/medication_list_state.dart';
import '../widgets/medication_search_field.dart';
import '../widgets/medication_tile.dart';

class MedicationListView extends StatefulWidget {
  const MedicationListView({super.key});

  @override
  State<MedicationListView> createState() => _MedicationListViewState();
}

class _MedicationListViewState extends State<MedicationListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MedicationListCubit>().loadInitial();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicationListCubit, MedicationListState>(
      builder: (context, state) => RefreshIndicator(
        onRefresh: context.read<MedicationListCubit>().refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                context.spacing.md,
                context.spacing.md,
                context.spacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: MedicationSearchField(
                  controller: _searchController,
                  onChanged: context.read<MedicationListCubit>().updateSearch,
                  onSubmitted: context.read<MedicationListCubit>().submitSearch,
                ),
              ),
            ),
            _MedicationResults(state: state),
          ],
        ),
      ),
    );
  }
}

class _MedicationResults extends StatelessWidget {
  const _MedicationResults({required this.state});

  final MedicationListState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == MedicationListStatus.loading) {
      return const SliverFillRemaining(child: AppLoadingView());
    }
    if (state.status == MedicationListStatus.failure) {
      return SliverFillRemaining(
        child: AppErrorView(
          message: _failureMessage(context, state.failure),
          onRetry: context.read<MedicationListCubit>().refresh,
        ),
      );
    }
    if (state.status == MedicationListStatus.initial &&
        state.query.isNotEmpty) {
      return SliverFillRemaining(
        child: AppEmptyView(
          title: context.l10n.searchMedications,
          message: context.l10n.searchMinLengthHint,
          icon: Icons.search,
        ),
      );
    }
    if (state.status == MedicationListStatus.empty) {
      return SliverFillRemaining(
        child: AppEmptyView(
          title: context.l10n.noMedicationsFound,
          message: state.query.isEmpty
              ? context.l10n.saveFavoritesHint
              : context.l10n.tryDifferentSearch,
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.all(context.spacing.md),
      sliver: SliverList.builder(
        itemCount: state.medications.length + 1,
        itemBuilder: (context, index) {
          if (index == state.medications.length) {
            return _LoadMoreFooter(
              hasMore: state.hasMore,
              isLoading: state.isLoadingMore,
              hasFailure: state.loadMoreFailure != null,
              onLoadMore: context.read<MedicationListCubit>().loadMore,
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: context.spacing.sm),
            child: MedicationTile(medication: state.medications[index]),
          );
        },
      ),
    );
  }

  String _failureMessage(BuildContext context, Failure? failure) =>
      switch (failure?.type) {
        FailureType.network => context.l10n.networkError,
        FailureType.server => context.l10n.serverError,
        FailureType.rateLimited => context.l10n.rateLimitError,
        FailureType.invalidData => context.l10n.invalidDataError,
        _ => context.l10n.unknownError,
      };
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.hasMore,
    required this.isLoading,
    required this.hasFailure,
    required this.onLoadMore,
  });

  final bool hasMore;
  final bool isLoading;
  final bool hasFailure;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) return SizedBox(height: context.spacing.sm);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.md),
      child: Column(
        children: [
          if (hasFailure) ...[
            Text(context.l10n.loadMoreError, textAlign: TextAlign.center),
            SizedBox(height: context.spacing.sm),
          ],
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Center(
              child: OutlinedButton(
                onPressed: onLoadMore,
                child: Text(
                  hasFailure ? context.l10n.retry : context.l10n.loadMore,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
