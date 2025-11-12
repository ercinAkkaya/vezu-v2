class WeatherResponseDto {
  WeatherResponseDto({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.observationTime,
    this.precipitation,
    this.locationName,
  });

  factory WeatherResponseDto.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    return WeatherResponseDto(
      temperature: (current['temperature_2m'] as num?)?.toDouble(),
      humidity: (current['relative_humidity_2m'] as num?)?.toInt(),
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble(),
      weatherCode: (current['weather_code'] as num?)?.toInt(),
      precipitation: (current['precipitation'] as num?)?.toDouble(),
      observationTime: DateTime.tryParse(current['time'] as String? ?? ''),
    );
  }

  final double? temperature;
  final int? humidity;
  final double? windSpeed;
  final int? weatherCode;
  final double? precipitation;
  final DateTime? observationTime;
  String? locationName;
}

