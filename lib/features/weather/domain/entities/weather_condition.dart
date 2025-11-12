enum WeatherCondition {
  clear,
  partlyCloudy,
  fog,
  drizzle,
  freezingDrizzle,
  rain,
  freezingRain,
  snow,
  rainShowers,
  snowShowers,
  thunderstorm,
  thunderstormWithHail,
  unknown;

  static WeatherCondition fromWeatherCode(int? code) {
    if (code == null) {
      return WeatherCondition.unknown;
    }

    switch (code) {
      case 0:
        return WeatherCondition.clear;
      case 1:
      case 2:
      case 3:
        return WeatherCondition.partlyCloudy;
      case 45:
      case 48:
        return WeatherCondition.fog;
      case 51:
      case 53:
      case 55:
        return WeatherCondition.drizzle;
      case 56:
      case 57:
        return WeatherCondition.freezingDrizzle;
      case 61:
      case 63:
      case 65:
        return WeatherCondition.rain;
      case 66:
      case 67:
        return WeatherCondition.freezingRain;
      case 71:
      case 73:
      case 75:
      case 77:
        return WeatherCondition.snow;
      case 80:
      case 81:
      case 82:
        return WeatherCondition.rainShowers;
      case 85:
      case 86:
        return WeatherCondition.snowShowers;
      case 95:
        return WeatherCondition.thunderstorm;
      case 96:
      case 99:
        return WeatherCondition.thunderstormWithHail;
      default:
        return WeatherCondition.unknown;
    }
  }
}

