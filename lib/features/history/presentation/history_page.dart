import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:vezu/core/components/app_surface_card.dart";
import "package:vezu/features/auth/presentation/cubit/auth_cubit.dart";
import "package:vezu/core/navigation/app_router.dart";
import "package:vezu/features/history/presentation/combination_detail_page.dart";

import "history_cubit.dart";

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HistoryCubit(authCubit: context.read<AuthCubit>())..loadHistory(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            final combinations = state.combinations;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surface.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_rounded),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "historyTitle".tr(),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "historySubtitle".tr(),
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _HistoryStatChip(
                              icon: Icons.auto_awesome_outlined,
                              label: "profileStatOutfits".tr(),
                              value: combinations.length.toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.status == HistoryStatus.loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.status == HistoryStatus.failure)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          (state.errorKey ?? "historyLoadError").tr(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (combinations.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_outlined,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "historyEmptyTitle".tr(),
                              style:
                                  theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "historyEmptySubtitle".tr(),
                              textAlign: TextAlign.center,
                              style:
                                  theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverList.separated(
                      itemBuilder: (context, index) {
                        final combination = combinations[index];
                        return _HistoryCombinationCard(
                          combination: combination,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.historyDetail,
                              arguments: CombinationDetailArgs(
                                id: combination.id,
                                theme: combination.theme,
                                summary: combination.summary,
                                mood: combination.mood,
                                createdAt: combination.createdAt,
                                piecesCount: combination.piecesCount,
                                primaryImageUrl: combination.primaryImageUrl,
                              ),
                            );
                          },
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemCount: combinations.length,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistoryStatChip extends StatelessWidget {
  const _HistoryStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.primary.withOpacity(0.08),
            ),
            child: Text(
              value,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCombinationCard extends StatelessWidget {
  const _HistoryCombinationCard({
    required this.combination,
    this.onTap,
  });

  final HistoryCombination combination;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAt = combination.createdAt;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AppSurfaceCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface.withOpacity(0.98),
              theme.colorScheme.surfaceVariant.withOpacity(0.95),
            ],
          ),
          borderColor: theme.colorScheme.outlineVariant.withOpacity(0.5),
          borderWidth: 1.1,
          elevation: 0.2,
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: theme.colorScheme.surfaceVariant,
                  image: combination.primaryImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(combination.primaryImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: combination.primaryImageUrl == null
                    ? Icon(
                        Icons.checkroom_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            combination.theme,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (createdAt != null)
                          Text(
                            DateFormat("d MMM yyyy, HH:mm").format(createdAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (combination.mood != null &&
                        combination.mood!.trim().isNotEmpty)
                      Text(
                        combination.mood!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      combination.summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: theme.colorScheme.primary
                                .withOpacity(0.08),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.layers_rounded,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "combinePiecesCount".tr(
                                  namedArgs: {
                                    'count': '${combination.piecesCount}',
                                  },
                                ),
                                style:
                                    theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

