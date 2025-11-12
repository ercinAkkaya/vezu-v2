import 'package:equatable/equatable.dart';
import 'package:vezu/features/weather/domain/entities/weather_condition.dart';

class WeatherEntity extends Equatable {
  const WeatherEntity({
    required this.temperatureC,
    required this.humidityPercent,
    required this.windSpeedKmh,
    required this.condition,
    required this.observationTime,
    this.precipitationMm,
    this.locationName,
  });

  final double temperatureC;
  final int humidityPercent;
  final double windSpeedKmh;
  final WeatherCondition condition;
  final DateTime observationTime;
  final double? precipitationMm;
  final String? locationName;

  @override
  List<Object?> get props => [
        temperatureC,
        humidityPercent,
        windSpeedKmh,
        condition,
        observationTime,
        precipitationMm,
        locationName,
      ];
}

