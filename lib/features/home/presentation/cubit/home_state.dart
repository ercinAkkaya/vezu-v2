part of "home_cubit.dart";

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.userName = "Sarah Johnson",
    this.avatarUrl,
    this.temperature = "22\u00B0C",
    this.condition = "Partly Cloudy",
    this.humidity = "65%",
    this.wind = "12 km/h",
    this.errorMessage,
  });

  final HomeStatus status;
  final String userName;
  final String? avatarUrl;
  final String temperature;
  final String condition;
  final String humidity;
  final String wind;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    String? userName,
    String? avatarUrl,
    String? temperature,
    String? condition,
    String? humidity,
    String? wind,
    String? errorMessage,
    bool resetError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      humidity: humidity ?? this.humidity,
      wind: wind ?? this.wind,
      errorMessage: resetError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userName,
    avatarUrl,
    temperature,
    condition,
    humidity,
    wind,
    errorMessage,
  ];
}
