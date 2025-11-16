import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/services.dart";
import "package:vezu/core/components/app_surface_card.dart";
import "package:vezu/core/components/primary_filled_button.dart";
import "package:vezu/core/components/outlined_button.dart";
import "package:vezu/features/auth/presentation/cubit/auth_cubit.dart";

class CombinationDetailArgs {
  const CombinationDetailArgs({
    required this.id,
    required this.theme,
    required this.summary,
    this.mood,
    this.createdAt,
    required this.piecesCount,
    this.primaryImageUrl,
  });

  final String id;
  final String theme;
  final String summary;
  final String? mood;
  final DateTime? createdAt;
  final int piecesCount;
  final String? primaryImageUrl;
}

class CombinationDetailPage extends StatelessWidget {
  const CombinationDetailPage({super.key, required this.args});

  final CombinationDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = context.read<AuthCubit>().state.user?.id;
    final overlay = SystemUiOverlayStyle(
      statusBarColor: theme.colorScheme.surface,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: userId == null
                ? _UnauthenticatedView(theme: theme)
                : _DetailContent(userId: userId, args: args),
          ),
        ),
      ),
    );
  }
}

class _UnauthenticatedView extends StatelessWidget {
  const _UnauthenticatedView({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          "historyLoadError".tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.userId,
    required this.args,
  });

  final String userId;
  final CombinationDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("saved_combinations")
        .doc(args.id);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: docRef.get(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final data = snapshot.data?.data();

        final itemsRaw = (data?["items"] as List<dynamic>? ?? []);
        final items = itemsRaw.cast<Map<String, dynamic>>();

        final stylingNotes =
            (data?["styling_notes"] as List<dynamic>? ?? []).cast<String>();
        final warnings =
            (data?["warnings"] as List<dynamic>? ?? []).cast<String>();
        final accessories =
            (data?["accessories"] as List<dynamic>? ?? []).cast<String>();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
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
                            args.theme,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "historyDetailSubtitle".tr(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppSurfaceCard(
                  borderRadius: 26,
                  padding: const EdgeInsets.all(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.surface.withOpacity(0.98),
                      theme.colorScheme.surfaceVariant.withOpacity(0.95),
                    ],
                  ),
                  borderColor:
                      theme.colorScheme.outlineVariant.withOpacity(0.5),
                  borderWidth: 1.1,
                  elevation: 0.22,
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero-style görsel alanı
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: SizedBox(
                          height: 240,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (args.primaryImageUrl != null)
                                Image.network(
                                  args.primaryImageUrl!,
                                  fit: BoxFit.cover,
                                )
                              else
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        theme.colorScheme.primary
                                            .withOpacity(0.5),
                                        theme.colorScheme.secondary
                                            .withOpacity(0.4),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 48,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.05),
                                      Colors.black.withOpacity(0.55),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 14,
                                left: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.layers_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "combinePiecesCount".tr(
                                          namedArgs: {
                                            'count': '${args.piecesCount}',
                                          },
                                        ),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (args.createdAt != null)
                                Positioned(
                                  top: 14,
                                  right: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withOpacity(0.35),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      DateFormat("d MMM yyyy, HH:mm")
                                          .format(args.createdAt!),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (args.mood != null &&
                              args.mood!.trim().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary
                                        .withOpacity(0.12),
                                    theme.colorScheme.primaryContainer
                                        .withOpacity(0.08),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    args.mood!,
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        args.summary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SecondaryOutlinedButton(
                              label: "historyShare".tr(),
                              onPressed: () {},
                              icon: const Icon(Icons.ios_share_rounded),
                              minHeight: 44,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryFilledButton(
                              label: "historyFavorite".tr(),
                              onPressed: () {},
                              icon:
                                  const Icon(Icons.favorite_border_rounded),
                              minHeight: 44,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (hasError)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "historyLoadError".tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              )
            else ...[
              if (stylingNotes.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: _NotesSection(
                      title: "combineStylingNotes".tr(),
                      items: stylingNotes,
                    ),
                  ),
                ),
              if (accessories.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: _NotesSection(
                      title: "combineAccessoryNotes".tr(),
                      items: accessories,
                    ),
                  ),
                ),
              if (warnings.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: _NotesSection(
                      title: "combineWarnings".tr(),
                      items: warnings,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    "combineResultPieces".tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList.separated(
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CombinationItemCard(item: item);
                  },
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemCount: items.length,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSurfaceCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• "),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      note,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CombinationItemCard extends StatelessWidget {
  const _CombinationItemCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = item["image_url"] as String?;
    final nickname = (item["nickname"] as String?) ?? "";
    final category = (item["category"] as String?) ?? "";
    final slot = (item["slot"] as String?) ?? "";
    final pairingReason = (item["pairing_reason"] as String?) ?? "";
    final stylingTip = (item["styling_tip"] as String?) ?? "";
    final accent = (item["accent"] as String?) ?? "";

    return AppSurfaceCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(14),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surface.withOpacity(0.98),
          theme.colorScheme.surfaceVariant.withOpacity(0.96),
        ],
      ),
      borderColor: theme.colorScheme.outlineVariant.withOpacity(0.45),
      borderWidth: 1,
      elevation: 0.18,
      shadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 10),
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 78,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: theme.colorScheme.surfaceVariant,
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.18),
                ],
              ),
            ),
            child: imageUrl == null
                ? Icon(
                    Icons.checkroom_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname.isNotEmpty ? nickname : slot,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                if (accent.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    "combineAccentLabel".tr(args: [accent]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
                if (pairingReason.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    pairingReason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.3,
                    ),
                  ),
                ],
                if (stylingTip.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    stylingTip,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


