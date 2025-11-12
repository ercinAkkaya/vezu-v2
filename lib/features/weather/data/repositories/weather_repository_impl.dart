import 'package:vezu/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:vezu/features/weather/data/models/weather_dto.dart';
import 'package:vezu/features/weather/domain/entities/weather_condition.dart';
import 'package:vezu/features/weather/domain/entities/weather_entity.dart';
import 'package:vezu/features/weather/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({required WeatherRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final WeatherRemoteDataSource _remoteDataSource;

  @override
  Future<WeatherEntity> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final WeatherResponseDto dto = await _remoteDataSource.fetchWeather(
      latitude: latitude,
      longitude: longitude,
    );

    dto.locationName = await _remoteDataSource.resolveLocationName(
      latitude: latitude,
      longitude: longitude,
    );

    final temperature = dto.temperature ?? 0;
    final humidity = dto.humidity ?? 0;
    final windSpeed = dto.windSpeed ?? 0;
    final condition = WeatherCondition.fromWeatherCode(dto.weatherCode);
    final observationTime = dto.observationTime ?? DateTime.now();

    return WeatherEntity(
      temperatureC: temperature,
      humidityPercent: humidity,
      windSpeedKmh: windSpeed,
      condition: condition,
      observationTime: observationTime,
      precipitationMm: dto.precipitation,
      locationName: dto.locationName,
    );
  }
}

