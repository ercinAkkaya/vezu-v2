import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:vezu/core/base/base_location_service.dart";
import "package:vezu/core/components/app_surface_card.dart";
import "package:vezu/core/components/primary_filled_button.dart";
import "package:vezu/features/combination/presentation/components/combination_section_header.dart";
import "package:vezu/features/combination/presentation/components/combination_selectable_pill.dart";
import "package:vezu/features/combination/presentation/components/combination_season_selector.dart";
import "package:vezu/features/combination/presentation/components/combination_weather_summary.dart";
import "package:vezu/features/weather/domain/entities/weather_condition.dart";
import "package:vezu/features/weather/domain/usecases/get_weather.dart";

const Duration _weatherCacheTtl = Duration(minutes: 30);
_WeatherSnapshot? _cachedWeather;

class _WeatherSnapshot {
  const _WeatherSnapshot({
    required this.temperature,
    required this.humidity,
    required this.wind,
    required this.condition,
    required this.location,
    required this.fetchedAt,
  });

  final String temperature;
  final String humidity;
  final String wind;
  final String condition;
  final String? location;
  final DateTime fetchedAt;
}

class CombinationCreatePage extends StatefulWidget {
  const CombinationCreatePage({super.key});

  @override
  State<CombinationCreatePage> createState() => _CombinationCreatePageState();
}

class _CombinationCreatePageState extends State<CombinationCreatePage> {
  final TextEditingController _notesController = TextEditingController();

  late final List<String> _eventOptions;
  final List<String> _seasonOptions = const [
    "combinationSeasonSpring",
    "combinationSeasonSummer",
    "combinationSeasonAutumn",
    "combinationSeasonWinter",
  ];
  final List<String> _colorOptions = const [
    "combinationColorLight",
    "combinationColorDark",
    "combinationColorNeutral",
    "combinationColorVibrant",
  ];

  String? _selectedEvent;
  String? _selectedSeason;
  String? _selectedColor;
  bool _useWeather = true;

  bool _isWeatherLoading = true;
  String? _temperature;
  String? _humidity;
  String? _wind;
  String? _conditionLabel;
  String? _locationLabel;
  String? _weatherError;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _eventOptions = [
      "combinationEventOffice",
      "combinationEventDinner",
      "combinationEventSocial",
      "combinationEventCasual",
      "combinationEventMeeting",
      "combinationEventFormal",
      "combinationEventWedding",
      "combinationEventNightOut",
      "combinationEventDate",
      "combinationEventTravel",
    ];

    final cached = _cachedWeather;
    if (cached != null && !_isCacheExpired(cached)) {
      _applyWeatherSnapshot(cached);
      _isWeatherLoading = false;
      _weatherError = null;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadWeatherOverview();
      });
    }
  }

  Future<void> _loadWeatherOverview({bool force = false}) async {
    final cached = _cachedWeather;
    if (!force && cached != null && !_isCacheExpired(cached)) {
      if (!mounted) return;
      setState(() {
        _applyWeatherSnapshot(cached);
        _isWeatherLoading = false;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isWeatherLoading = true;
        _weatherError = null;
      });
    }

    try {
      final locationService = context.read<BaseLocationService>();
      final getWeatherUseCase = context.read<GetWeatherUseCase>();
      final coordinates = await locationService.getCurrentPosition();
      final weather = await getWeatherUseCase(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      );

      if (!mounted) return;
      setState(() {
        final snapshot = _WeatherSnapshot(
          temperature: '${weather.temperatureC.round()}°C',
          humidity: '${weather.humidityPercent}%',
          wind: _formatWind(weather.windSpeedKmh),
          condition: _mapConditionKey(weather.condition).tr(),
          location: weather.locationName,
          fetchedAt: DateTime.now(),
        );
        _cachedWeather = snapshot;
        _applyWeatherSnapshot(snapshot);
        _isWeatherLoading = false;
      });
    } on LocationPermissionException catch (_) {
      if (!mounted) return;
      setState(() {
        _isWeatherLoading = false;
        _weatherError = "combinationWeatherPermission".tr();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isWeatherLoading = false;
        _weatherError = "combinationWeatherUnavailable".tr();
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatWind(double value) {
    final rounded =
        value >= 10 ? value.round().toString() : value.toStringAsFixed(1);
    return '$rounded km/h';
  }

  bool _isCacheExpired(_WeatherSnapshot snapshot) {
    return DateTime.now().difference(snapshot.fetchedAt) > _weatherCacheTtl;
  }

  void _applyWeatherSnapshot(_WeatherSnapshot snapshot) {
    _temperature = snapshot.temperature;
    _humidity = snapshot.humidity;
    _wind = snapshot.wind;
    _conditionLabel = snapshot.condition;
    _locationLabel = snapshot.location;
    _weatherError = null;
  }

  String _mapConditionKey(WeatherCondition condition) {
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

  void _onGeneratePressed() {
    if (_selectedEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("combinationValidationEvent".tr()),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("combinationComingSoon".tr()),
      ),
    );
  }

  void _toggleEvent(String key) {
    final next = _selectedEvent == key ? null : key;
    if (next == _selectedEvent) return;
    setState(() => _selectedEvent = next);
  }

  void _toggleSeason(String key) {
    final next = _selectedSeason == key ? null : key;
    if (next == _selectedSeason) return;
    setState(() => _selectedSeason = next);
  }

  void _toggleColor(String key) {
    final next = _selectedColor == key ? null : key;
    if (next == _selectedColor) return;
    setState(() => _selectedColor = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.08),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 14,
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
                          "combinationCreateTitle".tr(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "combinationCreateSubtitle".tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              AppSurfaceCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CombinationSectionHeader(
                      titleKey: "combinationEventTitle",
                      subtitleKey: "combinationEventSubtitle",
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _eventOptions
                          .map(
                            (key) => CombinationSelectablePill(
                              key: ValueKey("event_$key"),
                              label: key.tr(),
                              isSelected: _selectedEvent == key,
                              onTap: () => _toggleEvent(key),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppSurfaceCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CombinationSectionHeader(
                      titleKey: "combinationWeatherTitle",
                      subtitleKey: "combinationWeatherSubtitle",
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.12),
                            theme.colorScheme.surface.withOpacity(0.96),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sunny_snowing,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "combinationWeatherToggle".tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Switch.adaptive(
                            value: _useWeather,
                            onChanged: (value) {
                              if (_useWeather == value) return;
                              setState(() {
                                _useWeather = value;
                                if (value) {
                                  _selectedSeason = null;
                                }
                              });
                              if (value) {
                                _loadWeatherOverview();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: !_useWeather
                          ? CombinationSeasonSelector(
                              key: const ValueKey("season-section"),
                              options: _seasonOptions,
                              selected: _selectedSeason,
                              onChanged: _toggleSeason,
                            )
                          : CombinationWeatherSummary(
                              key: const ValueKey("weather-summary"),
                              temperature: _temperature,
                              humidity: _humidity,
                              wind: _wind,
                              condition: _conditionLabel,
                              location: _locationLabel,
                              loading: _isWeatherLoading,
                              errorText: _weatherError,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppSurfaceCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CombinationSectionHeader(
                      titleKey: "combinationColorTitle",
                      subtitleKey: "combinationColorSubtitle",
                      optionalLabelKey: "combinationSectionOptional",
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _colorOptions
                          .map(
                            (key) => CombinationSelectablePill(
                              key: ValueKey("color_$key"),
                              label: key.tr(),
                              isSelected: _selectedColor == key,
                              onTap: () => _toggleColor(key),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppSurfaceCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CombinationSectionHeader(
                      titleKey: "combinationNotesTitle",
                      subtitleKey: "combinationNotesSubtitle",
                      optionalLabelKey: "combinationSectionOptional",
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "combinationNotesPlaceholder".tr(),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant.withOpacity(
                          0.45,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              PrimaryFilledButton(
                onPressed: _onGeneratePressed,
                label: "combinationGenerateCta".tr(),
                icon: const Icon(Icons.auto_awesome_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

