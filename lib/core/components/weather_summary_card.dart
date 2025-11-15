import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:vezu/core/utils/weather_backdrop.dart";
import "package:vezu/features/weather/domain/entities/weather_condition.dart";

class WeatherSummaryCard extends StatelessWidget {
  const WeatherSummaryCard({
    super.key,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.wind,
    required this.icon,
    this.location,
    this.isLoading = false,
    this.conditionType,
  });

  final String temperature;
  final String condition;
  final String humidity;
  final String wind;
  final IconData icon;
  final String? location;
  final bool isLoading;
  final WeatherCondition? conditionType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backdrop = resolveWeatherBackdrop(condition: conditionType);
    final primaryTextColor = Colors.white;
    final secondaryTextColor = Colors.white.withValues(alpha: 0.9);
    final textShadows = [
      Shadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.16,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(backdrop.assetPath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.05),
              Colors.black.withValues(alpha: 0.25),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (location != null)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 11,
                          color: primaryTextColor,
                          shadows: textShadows,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            location!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: primaryTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              shadows: textShadows,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(icon, size: 19, color: primaryTextColor),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  temperature,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: primaryTextColor,
                    height: 1,
                    letterSpacing: -1.5,
                    shadows: textShadows,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    condition,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      shadows: textShadows,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _WeatherStat(
                    icon: Icons.water_drop_outlined,
                    label: 'homeWeatherHumidity'.tr(),
                    value: humidity,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _WeatherStat(
                    icon: Icons.air,
                    label: 'homeWeatherWind'.tr(),
                    value: wind,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  const _WeatherStat({
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
    final labelColor = Colors.white.withValues(alpha: 0.85);
    final valueColor = Colors.white;
    final textShadows = [
      Shadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 6,
        offset: const Offset(0, 1),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white, shadows: textShadows),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 8,
                    shadows: textShadows,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    shadows: textShadows,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}