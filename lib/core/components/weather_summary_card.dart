import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:vezu/core/components/app_surface_card.dart";

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
  });

  final String temperature;
  final String condition;
  final String humidity;
  final String wind;
  final IconData icon;
  final String? location;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSurfaceCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.surfaceVariant.withOpacity(0.9),
          theme.colorScheme.surface.withOpacity(0.96),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'homeWeatherTitle'.tr(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                  if (location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    temperature,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    condition,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Icon(icon, size: 28, color: theme.colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _WeatherStat(
                icon: Icons.water_drop_outlined,
                label: 'homeWeatherHumidity'.tr(),
                value: humidity,
              ),
              const SizedBox(width: 16),
              _WeatherStat(
                icon: Icons.air,
                label: 'homeWeatherWind'.tr(),
                value: wind,
              ),
            ],
          ),
        ],
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
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondary,
              ),
            ),
            Text(value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}
