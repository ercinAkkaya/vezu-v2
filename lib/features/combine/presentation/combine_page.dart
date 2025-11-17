import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vezu/core/base/base_location_service.dart';
import 'package:vezu/core/components/app_surface_card.dart';
import 'package:vezu/core/components/primary_filled_button.dart';
import 'package:vezu/core/models/subscription_plan_limits.dart';
import 'package:vezu/core/navigation/app_router.dart';
import 'package:vezu/core/services/subscription_service.dart';
import 'package:vezu/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vezu/features/combination/presentation/components/combination_selectable_pill.dart';
import 'package:vezu/core/utils/weather_backdrop.dart';
import 'package:vezu/features/combine/domain/usecases/generate_combination.dart';
import 'package:vezu/features/combine/presentation/cubit/combine_cubit.dart';
import 'package:vezu/features/combine/presentation/widgets/combination_result_view.dart';
import 'package:vezu/features/combine/presentation/widgets/preference_section.dart';
import 'package:vezu/features/wardrobe/domain/usecases/watch_wardrobe_items.dart';
import 'package:vezu/features/weather/domain/entities/weather_condition.dart';
import 'package:vezu/features/weather/domain/usecases/get_weather.dart';

class CombinePage extends StatelessWidget {
  const CombinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CombineCubit(
        watchWardrobeItemsUseCase: context.read<WatchWardrobeItemsUseCase>(),
        generateCombinationUseCase: context.read<GenerateCombinationUseCase>(),
        authCubit: context.read<AuthCubit>(),
      )..initialize(),
      child: const _CombineView(),
    );
  }
}

class _CombineView extends StatelessWidget {
  const _CombineView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<CombineCubit, CombineState>(
          listener: (context, state) {
            if (state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
            if (state.shouldShowPaywall) {
              _showLimitExceededMessage(context, isClothes: false);
              // Snackbar gösterildikten sonra paywall'ı aç
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  Navigator.of(context).pushNamed(AppRoutes.subscription);
                  context.read<CombineCubit>().clearPaywall();
                }
              });
            }
          },
          builder: (context, state) {
            final cubit = context.read<CombineCubit>();
            final wardrobeMap = {
              for (final item in state.wardrobeItems) item.id: item,
            };
            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      elevation: 0,
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceContainerHighest,
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 8,
                        bottom: 28,
                      ),
                      sliver: SliverList.list(
                        children: [
                          const _WeatherOverviewCard(),
                          const SizedBox(height: 20),
                          CombinationPreferenceSection(
                            preference: state.preference,
                            onOccasionChanged: cubit.selectOccasion,
                            onDressCodeChanged: cubit.selectDressCode,
                            onVibeChanged: cubit.selectVibe,
                            onAccessoriesChanged: cubit.toggleAccessories,
                            onBoldColorsChanged: cubit.toggleBoldColors,
                            onPromptChanged: cubit.updateCustomPrompt,
                          ),
                          const SizedBox(height: 24),
                          if (state.isWardrobeLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (state.plan != null)
                            CombinationResultView(
                              plan: state.plan!,
                              wardrobeMap: wardrobeMap,
                              preference: state.preference,
                              onSave: () => _onSavePlan(context),
                              isSaving: state.isSavingPlan,
                              hasSaved: state.hasSavedPlan,
                            )
                          else if (!state.isWardrobeLoading && state.wardrobeItems.length < 10)
                            _InsufficientClothesWarning(
                              currentCount: state.wardrobeItems.length,
                            )
                          else
                            const SizedBox.shrink(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
                if (state.isGenerating) const _GeneratingOverlay(),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: BlocBuilder<CombineCubit, CombineState>(
          builder: (context, state) {
            final cubit = context.read<CombineCubit>();
            final hasEnoughClothes = state.wardrobeItems.length >= 10;
            final isDisabled = state.isGenerating || !hasEnoughClothes;
            
            return PrimaryFilledButton(
              label: state.isGenerating
                  ? 'combinationGenerateLoading'.tr()
                  : 'combinationGenerateCta'.tr(),
              onPressed: isDisabled
                  ? null
                  : () => _onGenerate(context, state, cubit),
              isLoading: state.isGenerating,
              minHeight: 58,
            );
          },
        ),
      ),
    );
  }

  static Future<void> _showLimitExceededMessage(BuildContext context, {required bool isClothes}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final subscriptionService = SubscriptionService.instance();
      final subscriptionInfo = await subscriptionService.getUserSubscriptionInfo(userId);
      final limits = subscriptionInfo['limits'] as SubscriptionPlanLimits;
      final currentCount = isClothes
          ? subscriptionInfo['totalClothes'] as int
          : subscriptionInfo['monthlyCombinationsUsed'] as int;
      final maxCount = isClothes
          ? limits.maxClothes
          : limits.maxCombinationsPerMonth;

      final message = isClothes
          ? 'Kıyafet ekleme limitinize ulaştınız ($currentCount/$maxCount). Daha fazla kıyafet eklemek için planınızı yükseltin.'
          : 'Aylık kombin limitinize ulaştınız ($currentCount/$maxCount). Daha fazla kombin oluşturmak için planınızı yükseltin.';

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Yükselt',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.subscription);
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Hata durumunda basit mesaj göster
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isClothes
                ? 'Kıyafet ekleme limitinize ulaştınız. Planınızı yükseltin.'
                : 'Aylık kombin limitinize ulaştınız. Planınızı yükseltin.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

void _onGenerate(BuildContext context, CombineState state, CombineCubit cubit) {
  // En az 10 kıyafet kontrolü
  if (state.wardrobeItems.length < 10) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Kombin oluşturabilmek için garderobunuzda en az 10 kıyafet olmalı. Şu anda ${state.wardrobeItems.length} kıyafetiniz var.',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    return;
  }

  final preference = state.preference;
  final missing = <String>[];

  if (preference.occasion.isEmpty) {
    missing.add('combinationEventTitle'.tr());
  }
  if (preference.dressCode.isEmpty) {
    missing.add('combineDressCodeTitle'.tr());
  }
  if (preference.weather.isEmpty) {
    missing.add('combineWeatherMoodTitle'.tr());
  }
  if (preference.vibe.isEmpty) {
    missing.add('combineVibeTitle'.tr());
  }

  if (missing.isNotEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('combinePreferenceIncomplete'.tr())));
    return;
  }

  cubit.generateCombination();
}

Future<void> _onSavePlan(BuildContext context) async {
  final cubit = context.read<CombineCubit>();
  final success = await cubit.saveCurrentPlan();
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        success ? 'combineSaveSuccess'.tr() : 'combineSaveError'.tr(),
      ),
    ),
  );
}

class _GeneratingOverlay extends StatelessWidget {
  const _GeneratingOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      ignoring: false,
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        alignment: Alignment.center,
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'combineGeneratingTitle'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'combineGeneratingSubtitle'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const Duration _weatherCacheTtl = Duration(minutes: 30);
_WeatherSnapshot? _cachedWeatherSnapshot;

class _WeatherSnapshot {
  const _WeatherSnapshot({
    required this.temperature,
    required this.temperatureValue,
    required this.humidity,
    required this.wind,
    required this.conditionLabel,
    required this.location,
    required this.fetchedAt,
    required this.condition,
  });

  final String temperature;
  final double temperatureValue;
  final String humidity;
  final String wind;
  final String conditionLabel;
  final String? location;
  final DateTime fetchedAt;
  final WeatherCondition condition;
}

class _WeatherOverviewCard extends StatefulWidget {
  const _WeatherOverviewCard();

  @override
  State<_WeatherOverviewCard> createState() => _WeatherOverviewCardState();
}

class _WeatherOverviewCardState extends State<_WeatherOverviewCard> {
  bool _isLoading = true;
  bool _useLiveWeather = true;
  String? _temperature;
  double? _temperatureValue;
  String? _humidity;
  String? _wind;
  String? _condition;
  String? _location;
  String? _error;
  String? _manualSeason;
  _WeatherSnapshot? _latestSnapshot;
  WeatherCondition? _conditionKind;

  static const _seasonOptions = [
    _SeasonOption(labelKey: 'combinationSeasonSpring', value: 'spring'),
    _SeasonOption(labelKey: 'combinationSeasonSummer', value: 'summer'),
    _SeasonOption(labelKey: 'combinationSeasonAutumn', value: 'autumn'),
    _SeasonOption(labelKey: 'combinationSeasonWinter', value: 'winter'),
  ];

  @override
  void initState() {
    super.initState();
    _hydrateFromCache();
  }

  void _hydrateFromCache() {
    final cached = _cachedWeatherSnapshot;
    if (cached != null && !_isCacheExpired(cached)) {
      _applySnapshot(cached);
      setState(() {
        _isLoading = false;
      });
    } else {
      _loadWeather();
    }
  }

  Future<void> _loadWeather({bool force = false}) async {
    if (!force) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final locationService = context.read<BaseLocationService>();
      final getWeatherUseCase = context.read<GetWeatherUseCase>();
      final position = await locationService.getCurrentPosition();
      final weather = await getWeatherUseCase(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final snapshot = _WeatherSnapshot(
        temperature: '${weather.temperatureC.round()}°C',
        temperatureValue: weather.temperatureC,
        humidity: '${weather.humidityPercent}%',
        wind: _formatWind(weather.windSpeedKmh),
        conditionLabel: _mapCondition(weather.condition).tr(),
        location: weather.locationName,
        fetchedAt: DateTime.now(),
        condition: weather.condition,
      );

      _cachedWeatherSnapshot = snapshot;
      if (!mounted) return;
      setState(() {
        _applySnapshot(snapshot);
        _isLoading = false;
        _error = null;
      });
      _syncLiveWeatherPreference();
    } on LocationPermissionException catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'combinationWeatherPermission'.tr();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'combinationWeatherUnavailable'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<CombineCubit>().state;
    if (!_useLiveWeather && state.preference.weather.isNotEmpty) {
      _manualSeason = state.preference.weather;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'combineWeatherCardTitle'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'combineWeatherCardSubtitle'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch.adaptive(
                      value: _useLiveWeather,
                      onChanged: (value) => _toggleLiveWeather(value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: _useLiveWeather
                    ? _buildLiveWeatherPanel(theme)
                    : _buildSeasonPicker(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applySnapshot(_WeatherSnapshot snapshot) {
    _latestSnapshot = snapshot;
    _temperature = snapshot.temperature;
    _temperatureValue = snapshot.temperatureValue;
    _humidity = snapshot.humidity;
    _wind = snapshot.wind;
    _condition = snapshot.conditionLabel;
    _location = snapshot.location;
    _conditionKind = snapshot.condition;
  }

  bool _isCacheExpired(_WeatherSnapshot snapshot) {
    return DateTime.now().difference(snapshot.fetchedAt) > _weatherCacheTtl;
  }

  String _formatWind(double value) {
    final rounded = value >= 10
        ? value.round().toString()
        : value.toStringAsFixed(1);
    return '$rounded km/h';
  }

  String _mapCondition(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return 'weatherConditionClear';
      case WeatherCondition.partlyCloudy:
        return 'weatherConditionPartlyCloudy';
      case WeatherCondition.fog:
        return 'weatherConditionFog';
      case WeatherCondition.drizzle:
        return 'weatherConditionDrizzle';
      case WeatherCondition.freezingDrizzle:
        return 'weatherConditionFreezingDrizzle';
      case WeatherCondition.rain:
        return 'weatherConditionRain';
      case WeatherCondition.freezingRain:
        return 'weatherConditionFreezingRain';
      case WeatherCondition.snow:
        return 'weatherConditionSnow';
      case WeatherCondition.rainShowers:
        return 'weatherConditionRainShowers';
      case WeatherCondition.snowShowers:
        return 'weatherConditionSnowShowers';
      case WeatherCondition.thunderstorm:
        return 'weatherConditionThunderstorm';
      case WeatherCondition.thunderstormWithHail:
        return 'weatherConditionThunderstormWithHail';
      case WeatherCondition.unknown:
        return 'weatherConditionUnknown';
    }
  }

  Widget _buildSeasonPicker(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('manual'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'combineSeasonManualTitle'.tr(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _seasonOptions
              .map(
                (option) => CombinationSelectablePill(
                  label: option.labelKey.tr(),
                  isSelected: _manualSeason == option.value,
                  onTap: () {
                    setState(() {
                      _manualSeason = option.value;
                    });
                    final season = option.value;
                    context.read<CombineCubit>().selectWeather(season);
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'combineSeasonManualHint'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.3,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveWeatherPanel(ThemeData theme) {
    if (_isLoading) {
      return const _WeatherStateBanner.loading(
        key: ValueKey('weather-loading'),
      );
    }
    if (_error != null) {
      return _WeatherStateBanner.error(
        key: const ValueKey('weather-error'),
        message: _error!,
      );
    }
    final inferredMood = _temperatureValue != null
        ? _inferWeatherMood(_temperatureValue!)
        : null;
    return Column(
      key: const ValueKey('weather-ready'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TemperatureOrb(value: _temperature),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _condition ?? 'weatherConditionUnknown'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_location != null && _location!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            _location!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (_humidity != null)
                        _WeatherMetricPill(
                          icon: Icons.water_drop_outlined,
                          label: 'homeWeatherHumidity'.tr(),
                          value: _humidity!,
                        ),
                      if (_wind != null)
                        _WeatherMetricPill(
                          icon: Icons.air_rounded,
                          label: 'homeWeatherWind'.tr(),
                          value: _wind!,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _WeatherMoodGauge(activeMood: inferredMood),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _loadWeather(force: true),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              'combineWeatherRefresh'.tr(),
              style: const TextStyle(fontSize: 13),
            ),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  void _toggleLiveWeather(bool value) {
    setState(() {
      _useLiveWeather = value;
    });
    if (value) {
      if (_latestSnapshot == null) {
        _loadWeather(force: true);
      } else {
        _syncLiveWeatherPreference();
      }
    } else {
      context.read<CombineCubit>().selectWeather(_manualSeason ?? '');
    }
  }

  void _syncLiveWeatherPreference() {
    if (!_useLiveWeather || _latestSnapshot == null) {
      return;
    }
    final mood = _inferWeatherMood(_latestSnapshot!.temperatureValue);
    context.read<CombineCubit>().selectWeather(mood);
  }

  String _inferWeatherMood(double temp) {
    if (temp <= 10) {
      return 'cool';
    } else if (temp <= 22) {
      return 'mild';
    }
    return 'warm';
  }

  String? _activeMoodHint(CombineState state) {
    if (_useLiveWeather && _latestSnapshot != null) {
      return _inferWeatherMood(_latestSnapshot!.temperatureValue);
    }
    if (state.preference.weatherTone != null &&
        state.preference.weatherTone!.isNotEmpty) {
      return state.preference.weatherTone;
    }
    if (_manualSeason != null && _manualSeason!.isNotEmpty) {
      return _manualSeason;
    }
    if (state.preference.weather.isNotEmpty) {
      return state.preference.weather;
    }
    return null;
  }
}

class _SeasonOption {
  const _SeasonOption({required this.labelKey, required this.value});

  final String labelKey;
  final String value;
}

class _WeatherStateBanner extends StatelessWidget {
  const _WeatherStateBanner.loading({super.key})
    : message = null,
      isError = false;

  const _WeatherStateBanner.error({super.key, required this.message})
    : isError = true;

  final String? message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!isError) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surfaceContainerHigh,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.errorContainer,
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherMetricPill extends StatelessWidget {
  const _WeatherMetricPill({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '$label · $value',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemperatureOrb extends StatelessWidget {
  const _TemperatureOrb({this.value});

  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primary.withValues(alpha: 0.3),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        value ?? '--',
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
      ),
    );
  }
}

class _WeatherMoodGauge extends StatelessWidget {
  const _WeatherMoodGauge({this.activeMood});

  final String? activeMood;

  static const _moods = [
    _MoodChip(labelKey: 'combineWeatherCool', value: 'cool'),
    _MoodChip(labelKey: 'combineWeatherMild', value: 'mild'),
    _MoodChip(labelKey: 'combineWeatherWarm', value: 'warm'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: _moods
            .map(
              (mood) => Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    color: activeMood == mood.value
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: Text(
                    mood.labelKey.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: activeMood == mood.value
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: activeMood == mood.value
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  static Future<void> _showLimitExceededMessage(BuildContext context, {required bool isClothes}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final subscriptionService = SubscriptionService.instance();
      final subscriptionInfo = await subscriptionService.getUserSubscriptionInfo(userId);
      final limits = subscriptionInfo['limits'] as SubscriptionPlanLimits;
      final currentCount = isClothes
          ? subscriptionInfo['totalClothes'] as int
          : subscriptionInfo['monthlyCombinationsUsed'] as int;
      final maxCount = isClothes
          ? limits.maxClothes
          : limits.maxCombinationsPerMonth;

      final message = isClothes
          ? 'Kıyafet ekleme limitinize ulaştınız ($currentCount/$maxCount). Daha fazla kıyafet eklemek için planınızı yükseltin.'
          : 'Aylık kombin limitinize ulaştınız ($currentCount/$maxCount). Daha fazla kombin oluşturmak için planınızı yükseltin.';

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Yükselt',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.subscription);
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Hata durumunda basit mesaj göster
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isClothes
                ? 'Kıyafet ekleme limitinize ulaştınız. Planınızı yükseltin.'
                : 'Aylık kombin limitinize ulaştınız. Planınızı yükseltin.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _InsufficientClothesWarning extends StatelessWidget {
  const _InsufficientClothesWarning({required this.currentCount});

  final int currentCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = 10 - currentCount;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Yeterli Kıyafet Yok',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Kombin oluşturabilmek için garderobunuzda en az 10 kıyafet olmalı.\nŞu anda $currentCount kıyafetiniz var. ${remaining > 0 ? '$remaining kıyafet daha eklemeniz gerekiyor.' : ''}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MoodChip {
  const _MoodChip({required this.labelKey, required this.value});

  final String labelKey;
  final String value;
}
