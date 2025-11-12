import 'package:vezu/features/weather/domain/entities/weather_entity.dart';
import 'package:vezu/features/weather/domain/repositories/weather_repository.dart';

class GetWeatherUseCase {
  GetWeatherUseCase(this._repository);

  final WeatherRepository _repository;

  Future<WeatherEntity> call({
    required double latitude,
    required double longitude,
  }) {
    return _repository.fetchWeather(latitude: latitude, longitude: longitude);
  }
}

