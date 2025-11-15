import 'package:flutter/material.dart';
import 'package:vezu/features/weather/domain/entities/weather_condition.dart';

class WeatherBackdropStyle {
  const WeatherBackdropStyle({
    required this.assetPath,
    required this.overlayColors,
  });

  final String assetPath;
  final List<Color> overlayColors;
}

WeatherBackdropStyle resolveWeatherBackdrop({
  WeatherCondition? condition,
  String? moodHint,
  String? explicitTone,
}) {
  final tone =
      _mapTone(explicitTone) ??
      _toneFromCondition(condition) ??
      _toneFromMood(moodHint) ??
      _BackdropTone.sunny;
  return _styleForTone(tone);
}

enum _BackdropTone { sunny, cloudy, rainy, snowy }

_BackdropTone? _toneFromCondition(WeatherCondition? condition) {
  if (condition == null) {
    return null;
  }
  switch (condition) {
    case WeatherCondition.rain:
    case WeatherCondition.drizzle:
    case WeatherCondition.freezingDrizzle:
    case WeatherCondition.freezingRain:
    case WeatherCondition.rainShowers:
    case WeatherCondition.thunderstorm:
    case WeatherCondition.thunderstormWithHail:
      return _BackdropTone.rainy;
    case WeatherCondition.snow:
    case WeatherCondition.snowShowers:
      return _BackdropTone.snowy;
    case WeatherCondition.fog:
    case WeatherCondition.partlyCloudy:
    case WeatherCondition.unknown:
      return _BackdropTone.cloudy;
    case WeatherCondition.clear:
      return _BackdropTone.sunny;
  }
}

_BackdropTone? _toneFromMood(String? mood) {
  if (mood == null || mood.isEmpty) {
    return null;
  }

  final normalized = mood.toLowerCase();
  if (normalized.contains('rain')) {
    return _BackdropTone.rainy;
  }
  if (normalized.contains('snow') || normalized.contains('winter')) {
    return _BackdropTone.snowy;
  }
  if (normalized.contains('cool') ||
      normalized.contains('mild') ||
      normalized.contains('cloudy') ||
      normalized.contains('autumn') ||
      normalized.contains('fall') ||
      normalized.contains('spring')) {
    return _BackdropTone.cloudy;
  }
  if (normalized.contains('warm') || normalized.contains('summer')) {
    return _BackdropTone.sunny;
  }
  return null;
}

_BackdropTone? _mapTone(String? explicit) {
  if (explicit == null || explicit.isEmpty) {
    return null;
  }
  switch (explicit) {
    case 'sunny':
    case 'warm':
      return _BackdropTone.sunny;
    case 'cloudy':
    case 'mild':
      return _BackdropTone.cloudy;
    case 'rainy':
    case 'wet':
      return _BackdropTone.rainy;
    case 'snowy':
    case 'cool':
      return _BackdropTone.snowy;
  }
  return null;
}

WeatherBackdropStyle _styleForTone(_BackdropTone tone) {
  switch (tone) {
    case _BackdropTone.cloudy:
      return WeatherBackdropStyle(
        assetPath: 'assets/png/cloudy.png',
        overlayColors: [
          Colors.black.withValues(alpha: 0.02),
          Colors.black.withValues(alpha: 0.22),
        ],
      );
    case _BackdropTone.rainy:
      return WeatherBackdropStyle(
        assetPath: 'assets/png/rainy.png',
        overlayColors: [
          Colors.black.withValues(alpha: 0.04),
          Colors.black.withValues(alpha: 0.3),
        ],
      );
    case _BackdropTone.snowy:
      return WeatherBackdropStyle(
        assetPath: 'assets/png/snowy.png',
        overlayColors: [
          Colors.white.withValues(alpha: 0.01),
          Colors.black.withValues(alpha: 0.22),
        ],
      );
    case _BackdropTone.sunny:
      return WeatherBackdropStyle(
        assetPath: 'assets/png/sunny.png',
        overlayColors: [
          Colors.black.withValues(alpha: 0.0),
          Colors.black.withValues(alpha: 0.18),
        ],
      );
  }
}
