import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:vezu/core/base/base_location_service.dart";
import "package:vezu/core/components/app_surface_card.dart";
import "package:vezu/core/components/empty_state_card.dart";
import "package:vezu/core/components/weather_summary_card.dart";
import "package:vezu/core/components/welcome_header.dart";
import "package:vezu/core/navigation/app_router.dart";
import "package:vezu/features/wardrobe/presentation/widgets/wardrobe_item_carousel.dart";
import "package:vezu/features/auth/domain/entities/user_entity.dart";
import "package:vezu/features/auth/presentation/cubit/auth_cubit.dart";
import "package:vezu/features/shell/presentation/cubit/bottom_nav_cubit.dart";
import "package:vezu/features/weather/domain/entities/weather_condition.dart";
import "package:vezu/features/weather/domain/usecases/get_weather.dart";

import "cubit/home_cubit.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        getWeatherUseCase: context.read<GetWeatherUseCase>(),
        locationService: context.read<BaseLocationService>(),
        authCubit: context.read<AuthCubit>(),
      )..loadDashboard(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth * 0.06;
            final verticalPadding = constraints.maxHeight * 0.02;

            return BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                final authState = context.watch<AuthCubit>().state;
                final user = authState.user;
                final displayName = _resolveDisplayName(user) ?? state.userName;
                final avatarUrl = user?.profilePhotoUrl ?? state.avatarUrl;

                final weatherSection = _buildWeatherSection(context, state);

                final wardrobeItems = context.select(
                  (AuthCubit cubit) => cubit.state.user,
                );

                final hasWardrobeItems =
                    (wardrobeItems?.totalClothes ?? 0) > 0;
                final horizontalPaddingValue =
                    horizontalPadding.clamp(16.0, 32.0);
                final verticalPaddingValue =
                    verticalPadding.clamp(12.0, 24.0);

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<HomeCubit>().refreshWeather().then(
                            (_) =>
                                context.read<HomeCubit>().loadDashboard(),
                          ),
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      vertical: verticalPaddingValue,
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPaddingValue,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WelcomeHeader(
                              userName: displayName,
                              avatarUrl: avatarUrl,
                            ),
                            const SizedBox(height: 20),
                            weatherSection,
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      if (hasWardrobeItems) ...[
                        WardrobeItemCarousel(
                          title: 'homeWardrobeSpotlight'.tr(),
                          horizontalPadding: horizontalPaddingValue,
                          onSeeAll: () =>
                              context.read<BottomNavCubit>().setIndex(1),
                        ),
                        const SizedBox(height: 20),
                      ],
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPaddingValue,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RecentCombinationsSection(
                              combinations: state.recentCombinations,
                              isLoading: state.isCombinationsLoading,
                              errorKey: state.combinationsErrorKey,
                            ),
                            const SizedBox(height: 24),
                            if (state.recentCombinations.isEmpty) ...[
                              if (!hasWardrobeItems)
                                const SizedBox(height: 24),
                              Text(
                                'homeEmptySectionTitle'.tr(),
                                style:
                                    theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              EmptyStateCard(
                                onAction: () => Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.combinationCreate),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static String? _resolveDisplayName(UserEntity? user) {
    if (user == null) {
      return null;
    }

    final parts = <String>[
      if ((user.firstName ?? '').trim().isNotEmpty) user.firstName!.trim(),
      if ((user.lastName ?? '').trim().isNotEmpty) user.lastName!.trim(),
    ];
    if (parts.isNotEmpty) {
      return parts.join(' ');
    }

    final email = user.email;
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return null;
  }

  Widget _buildWeatherSection(BuildContext context, HomeState state) {
    switch (state.status) {
      case HomeStatus.loading:
      case HomeStatus.initial:
        return _WeatherMessageCard(
          title: 'homeWeatherLoadingTitle'.tr(),
          message: 'homeWeatherLoadingMessage'.tr(),
          icon: Icons.my_location_outlined,
        );
      case HomeStatus.success:
        return WeatherSummaryCard(
          temperature: state.temperature,
          condition: state.conditionKey?.tr() ?? '-',
          humidity: state.humidity,
          wind: state.wind,
          location: state.locationLabel ?? 'homeWeatherUnknownLocation'.tr(),
          icon: _iconForCondition(state.weatherCondition),
          isLoading: state.isRefreshing,
          conditionType: state.weatherCondition,
        );
      case HomeStatus.permissionRequired:
        final permanentlyDenied = state.locationPermissionPermanentlyDenied;
        final servicesDisabled = state.locationServiceDisabled;
        final message =
            state.errorMessageKey?.tr() ?? 'homeWeatherPermissionMessage'.tr();
        final title = servicesDisabled
            ? 'homeWeatherServicesDisabledTitle'.tr()
            : 'homeWeatherPermissionTitle'.tr();

        FutureOr<void> Function() primaryAction;
        String primaryLabel;
        String? secondaryLabel;
        FutureOr<void> Function()? secondaryAction;
        final icon = servicesDisabled
            ? Icons.location_off_rounded
            : Icons.location_on_outlined;

        if (servicesDisabled) {
          primaryLabel = 'homeWeatherOpenLocationSettings'.tr();
          primaryAction = context.read<HomeCubit>().openDeviceLocationSettings;
          secondaryLabel = 'homeWeatherRetry'.tr();
          secondaryAction = context.read<HomeCubit>().retryPermissionRequest;
        } else if (permanentlyDenied) {
          primaryLabel = 'homeWeatherOpenAppSettings'.tr();
          primaryAction = context.read<HomeCubit>().openPermissionSettings;
          secondaryLabel = 'homeWeatherRetry'.tr();
          secondaryAction = context.read<HomeCubit>().retryPermissionRequest;
        } else {
          primaryLabel = 'homeWeatherGrantPermission'.tr();
          primaryAction = context.read<HomeCubit>().retryPermissionRequest;
          secondaryLabel = 'homeWeatherWhyNeeded'.tr();
          secondaryAction = () async {
            if (!context.mounted) return;
            await showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text('homeWeatherPermissionDialogTitle'.tr()),
                content: Text('homeWeatherPermissionDialogBody'.tr()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text('commonClose'.tr()),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      if (context.mounted) {
                        context.read<HomeCubit>().retryPermissionRequest();
                      }
                    },
                    child: Text('homeWeatherGrantPermission'.tr()),
                  ),
                ],
              ),
            );
          };
        }

        return _WeatherMessageCard(
          title: title,
          message: message,
          primaryActionLabel: primaryLabel,
          onPrimaryAction: primaryAction,
          secondaryActionLabel: secondaryLabel,
          onSecondaryAction: secondaryAction,
          icon: icon,
        );
      case HomeStatus.failure:
        final message =
            state.errorMessageKey?.tr() ?? 'homeWeatherFetchError'.tr();
        return _WeatherMessageCard(
          title: 'homeWeatherErrorTitle'.tr(),
          message: message,
          primaryActionLabel: 'homeWeatherRetry'.tr(),
          onPrimaryAction: context.read<HomeCubit>().retryPermissionRequest,
          icon: Icons.refresh_rounded,
        );
    }
  }

  IconData _iconForCondition(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return Icons.wb_sunny_rounded;
      case WeatherCondition.partlyCloudy:
        return Icons.wb_cloudy_rounded;
      case WeatherCondition.fog:
        return Icons.blur_on_rounded;
      case WeatherCondition.drizzle:
      case WeatherCondition.freezingDrizzle:
        return Icons.grain_rounded;
      case WeatherCondition.rain:
      case WeatherCondition.freezingRain:
        return Icons.umbrella_rounded;
      case WeatherCondition.snow:
      case WeatherCondition.snowShowers:
        return Icons.ac_unit_rounded;
      case WeatherCondition.rainShowers:
        return Icons.grain_outlined;
      case WeatherCondition.thunderstorm:
      case WeatherCondition.thunderstormWithHail:
        return Icons.thunderstorm_outlined;
      case WeatherCondition.unknown:
        return Icons.device_unknown;
    }
  }
}

class _RecentCombinationsSection extends StatelessWidget {
  const _RecentCombinationsSection({
    required this.combinations,
    required this.isLoading,
    this.errorKey,
  });

  final List<SavedCombination> combinations;
  final bool isLoading;
  final String? errorKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "homeHistoryTitle".tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (combinations.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Gelecekte tam geçmiş sayfasına yönlendirme için kullanılabilir.
                },
                child: Text(
                  "homeHistorySeeAll".tr(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          SizedBox(
            height: 160,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          )
        else if (errorKey != null)
          Text(
            errorKey!.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          )
        else if (combinations.isEmpty)
          Text(
            "homeHistoryEmpty".tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          )
        else
          _buildVerticalList(theme, context),
      ],
    );
  }

  Widget _buildVerticalList(ThemeData theme, BuildContext context) {
    const maxVisible = 4;
    final visibleCombinations =
        combinations.take(maxVisible).toList(growable: false);
    final hasMore = combinations.length > maxVisible;

    if (!hasMore) {
      return Column(
        children: visibleCombinations
            .map(
              (combination) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CombinationHistoryCard(combination: combination),
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: [
        // İlk 3 kart normal görünsün
        for (var i = 0; i < visibleCombinations.length; i++)
          if (i < maxVisible - 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CombinationHistoryCard(
                combination: visibleCombinations[i],
              ),
            )
          else
            // 4. kartın alt kısmına gradient + buton bindir
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Stack(
                children: [
                  _CombinationHistoryCard(
                    combination: visibleCombinations[i],
                  ),
                  Positioned.fill(
                    child: _HistorySeeMoreOverlay(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("comingSoon".tr()),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class _CombinationHistoryCard extends StatelessWidget {
  const _CombinationHistoryCard({required this.combination});

  final SavedCombination combination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryItem = combination.primaryItem;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 24,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surface.withValues(alpha: 0.98),
          theme.colorScheme.surfaceVariant.withValues(alpha: 0.96),
        ],
      ),
      borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
      borderWidth: 1.1,
      elevation: 0.22,
      shadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 22,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
          blurRadius: 30,
          spreadRadius: -8,
          offset: const Offset(0, 20),
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: primaryItem?.imageUrl == null
                      ? LinearGradient(
                          colors: [
                            theme.colorScheme.primary
                                .withValues(alpha: 0.24),
                            theme.colorScheme.primary
                                .withValues(alpha: 0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  image: primaryItem?.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(primaryItem!.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: primaryItem?.imageUrl == null
                    ? Icon(
                        Icons.checkroom_rounded,
                        color: theme.colorScheme.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      combination.theme,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (combination.mood != null &&
                        combination.mood!.trim().isNotEmpty)
                      Text(
                        combination.mood!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    if (combination.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat("d MMM, HH:mm")
                            .format(combination.createdAt!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: theme.colorScheme.primary.withValues(alpha: 0.09),
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
                      "${combination.itemsCount} parça",
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistorySeeMoreOverlay extends StatelessWidget {
  const _HistorySeeMoreOverlay({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment(0.0, -0.5),
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface.withValues(alpha: 0.25),
              theme.colorScheme.surface.withValues(alpha: 0.7),
              theme.colorScheme.surface.withValues(alpha: 0.94),
              theme.colorScheme.surface.withValues(alpha: 1.0),
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.blur_on_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "homeHistorySeeMore".tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherMessageCard extends StatelessWidget {
  const _WeatherMessageCard({
    required this.title,
    required this.message,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.icon,
  });

  final String title;
  final String message;
  final String? primaryActionLabel;
  final FutureOr<void> Function()? onPrimaryAction;
  final String? secondaryActionLabel;
  final FutureOr<void> Function()? onSecondaryAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: theme.colorScheme.primary),
                ),
              if (icon != null) const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          if (primaryActionLabel != null && onPrimaryAction != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPrimaryAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(primaryActionLabel!),
              ),
            ),
          ],
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSecondaryAction,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(secondaryActionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
