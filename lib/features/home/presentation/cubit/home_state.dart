part of "home_cubit.dart";

enum HomeStatus { initial, loading, success, failure, permissionRequired }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.userName = "Sarah Johnson",
    this.avatarUrl,
    this.temperature = "22\u00B0C",
    this.conditionKey = 'weatherConditionPartlyCloudy',
    this.humidity = "65%",
    this.wind = "12 km/h",
    this.locationLabel,
    this.errorMessageKey,
    this.locationPermissionPermanentlyDenied = false,
    this.locationServiceDisabled = false,
    this.isRefreshing = false,
    this.weatherCondition = WeatherCondition.partlyCloudy,
    this.recentCombinations = const [],
    this.isCombinationsLoading = false,
    this.combinationsErrorKey,
  });

  final HomeStatus status;
  final String userName;
  final String? avatarUrl;
  final String temperature;
  final String? conditionKey;
  final String humidity;
  final String wind;
  final String? locationLabel;
  final String? errorMessageKey;
  final bool locationPermissionPermanentlyDenied;
  final bool locationServiceDisabled;
  final bool isRefreshing;
  final WeatherCondition weatherCondition;
  final List<SavedCombination> recentCombinations;
  final bool isCombinationsLoading;
  final String? combinationsErrorKey;

  HomeState copyWith({
    HomeStatus? status,
    String? userName,
    String? avatarUrl,
    String? temperature,
    String? conditionKey,
    String? humidity,
    String? wind,
    String? locationLabel,
    String? errorMessageKey,
    bool resetError = false,
    bool? locationPermissionPermanentlyDenied,
    bool? locationServiceDisabled,
    bool? isRefreshing,
    WeatherCondition? weatherCondition,
    List<SavedCombination>? recentCombinations,
    bool? isCombinationsLoading,
    String? combinationsErrorKey,
    bool resetCombinationsError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      temperature: temperature ?? this.temperature,
      conditionKey: conditionKey ?? this.conditionKey,
      humidity: humidity ?? this.humidity,
      wind: wind ?? this.wind,
      locationLabel: locationLabel ?? this.locationLabel,
      errorMessageKey:
          resetError ? null : errorMessageKey ?? this.errorMessageKey,
      locationPermissionPermanentlyDenied:
          locationPermissionPermanentlyDenied ??
              this.locationPermissionPermanentlyDenied,
      locationServiceDisabled:
          locationServiceDisabled ?? this.locationServiceDisabled,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      recentCombinations: recentCombinations ?? this.recentCombinations,
      isCombinationsLoading: isCombinationsLoading ?? this.isCombinationsLoading,
      combinationsErrorKey: resetCombinationsError
          ? null
          : combinationsErrorKey ?? this.combinationsErrorKey,
    );
  }

  @override
  List<Object?> get props => [
        status,
        userName,
        avatarUrl,
        temperature,
        conditionKey,
        humidity,
        wind,
        locationLabel,
        errorMessageKey,
        locationPermissionPermanentlyDenied,
        locationServiceDisabled,
        isRefreshing,
        weatherCondition,
        recentCombinations,
        isCombinationsLoading,
        combinationsErrorKey,
      ];
}
