import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:vezu/core/base/base_location_service.dart";
import "package:vezu/core/components/app_surface_card.dart";
import "package:vezu/core/components/primary_filled_button.dart";
import "package:vezu/features/weather/domain/entities/weather_condition.dart";
import "package:vezu/features/weather/domain/usecases/get_weather.dart";

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

  @override
  void initState() {
    super.initState();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadWeatherOverview();
    });
  }

  Future<void> _loadWeatherOverview() async {
    setState(() {
      _isWeatherLoading = true;
      _weatherError = null;
    });

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
        _temperature = '${weather.temperatureC.round()}°C';
        _humidity = '${weather.humidityPercent}%';
        _wind = _formatWind(weather.windSpeedKmh);
        _conditionLabel = _mapConditionKey(weather.condition).tr();
        _locationLabel = weather.locationName;
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
    super.dispose();
  }

  String _formatWind(double value) {
    final rounded =
        value >= 10 ? value.round().toString() : value.toStringAsFixed(1);
    return '$rounded km/h';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
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
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        _SectionHeader(
                          title: "combinationEventTitle".tr(),
                          subtitle: "combinationEventSubtitle".tr(),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _eventOptions
                              .map(
                                (key) => _SelectablePill(
                                  label: key.tr(),
                                  isSelected: _selectedEvent == key,
                                  onTap: () {
                                    setState(() {
                                      _selectedEvent =
                                          _selectedEvent == key ? null : key;
                                    });
                                  },
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
                        _SectionHeader(
                          title: "combinationWeatherTitle".tr(),
                          subtitle: "combinationWeatherSubtitle".tr(),
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
                              ? _SeasonSelector(
                                  key: const ValueKey("season-section"),
                                  options: _seasonOptions,
                                  selected: _selectedSeason,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSeason =
                                          _selectedSeason == value ? null : value;
                                    });
                                  },
                                )
                              : _WeatherSummary(
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
                        _SectionHeader(
                          title: "combinationColorTitle".tr(),
                          subtitle: "combinationColorSubtitle".tr(),
                          optionalLabel: "combinationSectionOptional".tr(),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _colorOptions
                              .map(
                                (key) => _SelectablePill(
                                  label: key.tr(),
                                  isSelected: _selectedColor == key,
                                  onTap: () {
                                    setState(() {
                                      _selectedColor =
                                          _selectedColor == key ? null : key;
                                    });
                                  },
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
                        _SectionHeader(
                          title: "combinationNotesTitle".tr(),
                          subtitle: "combinationNotesSubtitle".tr(),
                          optionalLabel: "combinationSectionOptional".tr(),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "combinationNotesPlaceholder".tr(),
                            filled: true,
                            fillColor:
                                theme.colorScheme.surfaceVariant.withOpacity(
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
          ],
        ),
      ),
    );
  }
}

class _SeasonSelector extends StatelessWidget {
  const _SeasonSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "combinationSeasonTitle".tr(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "combinationSeasonSubtitle".tr(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options
              .map(
                (key) => _SelectablePill(
                  label: key.tr(),
                  isSelected: selected == key,
                  onTap: () => onChanged(key),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _WeatherSummary extends StatelessWidget {
  const _WeatherSummary({
    super.key,
    required this.temperature,
    required this.humidity,
    required this.wind,
    required this.condition,
    required this.loading,
    required this.errorText,
    this.location,
  });

  final String? temperature;
  final String? humidity;
  final String? wind;
  final String? condition;
  final bool loading;
  final String? errorText;
  final String? location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        ),
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
        ),
      );
    }

    if (errorText != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          border: Border.all(
            color: theme.colorScheme.error.withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.16),
            theme.colorScheme.surface.withOpacity(0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (location != null && location!.isNotEmpty) ...[
            Text(
              "combinationWeatherLocation".tr(args: [location!]),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                temperature ?? "--",
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onPrimary,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      condition ?? "weatherConditionUnknown".tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        if (humidity != null)
                          _WeatherFactChip(
                            icon: Icons.water_drop_outlined,
                            label: 'homeWeatherHumidity'.tr(),
                            value: humidity!,
                          ),
                        if (wind != null)
                          _WeatherFactChip(
                            icon: Icons.air_rounded,
                            label: 'homeWeatherWind'.tr(),
                            value: wind!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherFactChip extends StatelessWidget {
  const _WeatherFactChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.18),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            '$label · $value',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.optionalLabel,
  });

  final String title;
  final String subtitle;
  final String? optionalLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (optionalLabel != null)
              Text(
                optionalLabel!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }
}

class _SelectablePill extends StatelessWidget {
  const _SelectablePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.92),
                    theme.colorScheme.primaryContainer.withOpacity(0.78),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : theme.colorScheme.surfaceVariant.withOpacity(0.65),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.9)
                : theme.colorScheme.outline.withOpacity(0.24),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface.withOpacity(0.8),
            letterSpacing: -0.05,
          ),
        ),
      ),
    );
  }
}

