import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:vezu/core/base/base_location_service.dart";
import "package:vezu/core/components/app_surface_card.dart";
import "package:vezu/core/components/empty_state_card.dart";
import "package:vezu/core/components/weather_summary_card.dart";
import "package:vezu/core/components/welcome_header.dart";
import "package:vezu/features/wardrobe/presentation/widgets/wardrobe_item_carousel.dart";
import "package:vezu/features/wardrobe/domain/entities/clothing_item.dart";
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

                final wardrobeItems =
                    context.select((AuthCubit cubit) => cubit.state.user);

                return RefreshIndicator(
                  onRefresh: context.read<HomeCubit>().refreshWeather,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding.clamp(16, 32),
                      vertical: verticalPadding.clamp(12, 24),
                    ),
                    children: [
                      WelcomeHeader(
                        userName: displayName,
                        avatarUrl: avatarUrl,
                      ),
                      const SizedBox(height: 24),
                      weatherSection,
                      const SizedBox(height: 32),
                      if ((wardrobeItems?.totalClothes ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: WardrobeItemCarousel(
                            title: 'homeWardrobeSpotlight'.tr(),
                            onSeeAll: () =>
                                context.read<BottomNavCubit>().setIndex(1),
                          ),
                        ),
                      Text(
                        'homeEmptySectionTitle'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      EmptyStateCard(
                        onAction: () =>
                            context.read<BottomNavCubit>().setIndex(1),
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
    return AppSurfaceCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                  ),
                ),
              if (icon != null) const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondary.withOpacity(0.9),
            ),
          ),
          if (primaryActionLabel != null && onPrimaryAction != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPrimaryAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(primaryActionLabel!),
              ),
            ),
          ],
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSecondaryAction,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
