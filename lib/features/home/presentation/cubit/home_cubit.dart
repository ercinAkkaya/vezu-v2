import "dart:async";

import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import 'package:vezu/core/base/base_location_service.dart';
import 'package:vezu/features/weather/domain/entities/weather_condition.dart';
import 'package:vezu/features/weather/domain/usecases/get_weather.dart';

part "home_state.dart";

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetWeatherUseCase getWeatherUseCase,
    required BaseLocationService locationService,
  })  : _getWeatherUseCase = getWeatherUseCase,
        _locationService = locationService,
        super(const HomeState());

  final GetWeatherUseCase _getWeatherUseCase;
  final BaseLocationService _locationService;

  Future<void> loadDashboard() {
    return _fetchWeather(showLoading: true);
  }

  Future<void> refreshWeather() {
    return _fetchWeather(showLoading: false);
  }

  Future<void> retryPermissionRequest() {
    return _fetchWeather(showLoading: true);
  }

  Future<void> openPermissionSettings() async {
    await _locationService.openAppSettings();
    await _fetchWeather(showLoading: true);
  }

  Future<void> openDeviceLocationSettings() async {
    await _locationService.openLocationSettings();
    await _fetchWeather(showLoading: true);
  }

  Future<void> _fetchWeather({required bool showLoading}) async {
    if (showLoading) {
      emit(
        state.copyWith(
          status: HomeStatus.loading,
          resetError: true,
          isRefreshing: false,
          locationServiceDisabled: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isRefreshing: true,
          resetError: true,
          locationServiceDisabled: false,
        ),
      );
    }

    try {
      final coordinates = await _locationService.getCurrentPosition();
      final weather = await _getWeatherUseCase(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      );

      emit(
        state.copyWith(
          status: HomeStatus.success,
          temperature: _formatTemperature(weather.temperatureC),
          humidity: _formatHumidity(weather.humidityPercent),
          wind: _formatWind(weather.windSpeedKmh),
          conditionKey: _mapConditionKey(weather.condition),
          locationLabel: weather.locationName,
          weatherCondition: weather.condition,
          isRefreshing: false,
          resetError: true,
          locationPermissionPermanentlyDenied: false,
          locationServiceDisabled: false,
        ),
      );
    } on LocationPermissionException catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.permissionRequired,
          locationPermissionPermanentlyDenied: error.permanentlyDenied,
          locationServiceDisabled: error.serviceDisabled,
          errorMessageKey: error.serviceDisabled
              ? 'homeWeatherLocationServicesDisabled'
              : 'homeWeatherPermissionMessage',
          isRefreshing: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessageKey: 'homeWeatherFetchError',
          locationServiceDisabled: false,
          isRefreshing: false,
        ),
      );
    }
  }

  String _formatTemperature(double value) => '${value.round()}°C';

  String _formatHumidity(int value) => '$value%';

  String _formatWind(double value) {
    final rounded = value >= 10 ? value.round().toString() : value.toStringAsFixed(1);
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
}
