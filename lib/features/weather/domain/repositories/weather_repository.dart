import 'package:vezu/features/weather/domain/entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> fetchWeather({
    required double latitude,
    required double longitude,
  });
}

