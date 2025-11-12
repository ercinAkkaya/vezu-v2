import 'package:dio/dio.dart';
import 'package:vezu/features/weather/data/models/weather_dto.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherResponseDto> fetchWeather({
    required double latitude,
    required double longitude,
  });

  Future<String?> resolveLocationName({
    required double latitude,
    required double longitude,
  });
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  WeatherRemoteDataSourceImpl(this._dio);

  static const _weatherEndpoint = 'https://api.open-meteo.com/v1/forecast';
  static const _geocodeEndpoint =
      'https://nominatim.openstreetmap.org/reverse';

  final Dio _dio;

  @override
  Future<WeatherResponseDto> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _weatherEndpoint,
      queryParameters: <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'current':
            'temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation,weather_code',
        'timezone': 'auto',
      },
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Weather API returned empty response.');
    }

    return WeatherResponseDto.fromJson(data);
  }

  @override
  Future<String?> resolveLocationName({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _geocodeEndpoint,
      queryParameters: <String, dynamic>{
        'format': 'json',
        'lat': latitude,
        'lon': longitude,
        'zoom': 10,
        'addressdetails': 1,
      },
      options: Options(headers: const <String, String>{
        'User-Agent': 'vezu-app/1.0 (support@appistryco@gmail.com)',
      }),
    );

    final data = response.data;
    if (data == null) {
      return null;
    }
    final address = data['address'] as Map<String, dynamic>?;
    if (address == null) {
      return null;
    }

    return address['city'] as String? ??
        address['town'] as String? ??
        address['state'] as String? ??
        address['county'] as String?;
  }
}

