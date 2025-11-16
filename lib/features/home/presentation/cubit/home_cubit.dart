import "dart:async";

import "package:bloc/bloc.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:equatable/equatable.dart";
import "package:vezu/core/base/base_location_service.dart";
import "package:vezu/features/auth/presentation/cubit/auth_cubit.dart";
import "package:vezu/features/weather/domain/entities/weather_condition.dart";
import "package:vezu/features/weather/domain/usecases/get_weather.dart";

part "home_state.dart";

class SavedCombinationItem extends Equatable {
  const SavedCombinationItem({
    required this.imageUrl,
    required this.category,
    required this.nickname,
  });

  final String? imageUrl;
  final String category;
  final String nickname;

  @override
  List<Object?> get props => [imageUrl, category, nickname];
}

class SavedCombination extends Equatable {
  const SavedCombination({
    required this.id,
    required this.theme,
    required this.summary,
    required this.mood,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final String theme;
  final String summary;
  final String? mood;
  final DateTime? createdAt;
  final List<SavedCombinationItem> items;

  SavedCombinationItem? get primaryItem =>
      items.isNotEmpty ? items.first : null;

  int get itemsCount => items.length;

  @override
  List<Object?> get props => [id, theme, summary, mood, createdAt, items];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetWeatherUseCase getWeatherUseCase,
    required BaseLocationService locationService,
    required AuthCubit authCubit,
    FirebaseFirestore? firestore,
  })  : _getWeatherUseCase = getWeatherUseCase,
        _locationService = locationService,
        _authCubit = authCubit,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const HomeState());

  final GetWeatherUseCase _getWeatherUseCase;
  final BaseLocationService _locationService;
  final AuthCubit _authCubit;
  final FirebaseFirestore _firestore;

  Future<void> loadDashboard() async {
    await Future.wait([
      _fetchWeather(showLoading: true),
      _loadRecentCombinations(),
    ]);
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

  Future<void> _loadRecentCombinations() async {
    final userId = _authCubit.state.user?.id;
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          recentCombinations: const [],
          isCombinationsLoading: false,
          resetCombinationsError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isCombinationsLoading: true,
        resetCombinationsError: true,
      ),
    );

    try {
      final snapshot = await _firestore
          .collection("users")
          .doc(userId)
          .collection("saved_combinations")
          .orderBy("created_at", descending: true)
          .limit(10)
          .get();

      final combinations = snapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = data["created_at"];
        final itemsRaw = (data["items"] as List<dynamic>? ?? []);

        final items = itemsRaw.map((raw) {
          final map = raw as Map<String, dynamic>;
          return SavedCombinationItem(
            imageUrl: map["image_url"] as String?,
            category: (map["category"] as String?) ?? "-",
            nickname: (map["nickname"] as String?) ?? "",
          );
        }).toList();

        return SavedCombination(
          id: data["id"] as String? ?? doc.id,
          theme: (data["theme"] as String?) ?? "",
          summary: (data["summary"] as String?) ?? "",
          mood: data["mood"] as String?,
          createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
          items: items,
        );
      }).toList();

      emit(
        state.copyWith(
          recentCombinations: combinations,
          isCombinationsLoading: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isCombinationsLoading: false,
          combinationsErrorKey: "homeHistoryLoadError",
        ),
      );
    }
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
