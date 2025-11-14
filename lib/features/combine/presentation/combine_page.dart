import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vezu/core/base/base_location_service.dart';
import 'package:vezu/core/components/app_surface_card.dart';
import 'package:vezu/core/components/primary_filled_button.dart';
import 'package:vezu/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vezu/features/combination/presentation/components/combination_weather_summary.dart';
import 'package:vezu/features/combination/presentation/components/combination_selectable_pill.dart';
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
        watchWardrobeItemsUseCase:
            context.read<WatchWardrobeItemsUseCase>(),
        generateCombinationUseCase:
            context.read<GenerateCombinationUseCase>(),
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
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<CombineCubit, CombineState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<CombineCubit>();
            final wardrobeMap = {
              for (final item in state.wardrobeItems) item.id: item,
            };
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 12,
                    bottom: 20,
                  ),
                  sliver: SliverList.list(
                    children: [
                      _Header(theme: theme),
                      const SizedBox(height: 20),
                      const _WeatherOverviewCard(),
                      const SizedBox(height: 26),
                      CombinationPreferenceSection(
                        preference: state.preference,
                        onOccasionChanged: cubit.selectOccasion,
                        onDressCodeChanged: cubit.selectDressCode,
                        onVibeChanged: cubit.selectVibe,
                        onAccessoriesChanged: cubit.toggleAccessories,
                        onBoldColorsChanged: cubit.toggleBoldColors,
                      ),
                      const SizedBox(height: 28),
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
                        )
                      else
                        const _PlaceholderCard(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
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
            return PrimaryFilledButton(
              label: state.isGenerating
                  ? 'combinationGenerateLoading'.tr()
                  : 'combinationGenerateCta'.tr(),
              onPressed: state.isGenerating ? null : () => _onGenerate(context, state, cubit),
              isLoading: state.isGenerating,
              minHeight: 58,
            );
          },
        ),
      ),
    );
  }
}

void _onGenerate(
  BuildContext context,
  CombineState state,
  CombineCubit cubit,
) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('combinePreferenceIncomplete'.tr()),
      ),
    );
    return;
  }

  cubit.generateCombination();
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'combineHeaderTagline'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'combineHeaderTitle'.tr(),
          style: theme.textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'combineHeaderDescription'.tr(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.7),
            height: 1.4,
          ),
        ),
      ],
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
  });

  final String temperature;
  final double temperatureValue;
  final String humidity;
  final String wind;
  final String conditionLabel;
  final String? location;
  final DateTime fetchedAt;
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

    return AppSurfaceCard(
      borderRadius: 34,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'combineWeatherCardTitle'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'combineWeatherCardSubtitle'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _useLiveWeather,
                onChanged: (value) => _toggleLiveWeather(value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _useLiveWeather
                ? Column(
                    key: const ValueKey('live'),
                    children: [
                      CombinationWeatherSummary(
                        temperature: _temperature,
                        humidity: _humidity,
                        wind: _wind,
                        condition: _condition,
                        location: _location,
                        loading: _isLoading,
                        errorText: _error,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _loadWeather(force: true),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text('combineWeatherRefresh'.tr()),
                        ),
                      ),
                    ],
                  )
                : _buildSeasonPicker(context),
          ),
        ],
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
  }

  bool _isCacheExpired(_WeatherSnapshot snapshot) {
    return DateTime.now().difference(snapshot.fetchedAt) > _weatherCacheTtl;
  }

  String _formatWind(double value) {
    final rounded = value >= 10 ? value.round().toString() : value.toStringAsFixed(1);
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
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _seasonOptions
              .map(
                (option) => CombinationSelectablePill(
                  label: option.labelKey.tr(),
                  isSelected: _manualSeason == option?.value,
                  onTap: () {
                    setState(() {
                      _manualSeason = option?.value;
                    });
                    final season = option?.value ?? '';
                    context.read<CombineCubit>().selectWeather(season);
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        Text(
          'combineSeasonManualHint'.tr(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondary,
            height: 1.3,
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
}

class _SeasonOption {
  const _SeasonOption({required this.labelKey, required this.value});

  final String labelKey;
  final String value;
}
class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSurfaceCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(24),
      backgroundColor: Colors.white.withOpacity(0.03),
      borderColor: Colors.white.withOpacity(0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            'combinePlaceholderTitle'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'combinePlaceholderSubtitle'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
