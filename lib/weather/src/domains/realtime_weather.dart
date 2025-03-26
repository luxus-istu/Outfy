import 'structures.dart';

class RealtimeWeather {
  late final LocationData _location;
  late final CurrentWeatherData _current;

  RealtimeWeather(final Map<String, dynamic> jsonData) {
    final Map<String, dynamic>? jsonLocation = jsonData['location'];

    _location = LocationData(jsonLocation?['name'], jsonLocation?['region'],
        jsonLocation?['country'], jsonLocation?['lat'], jsonLocation?['lon']);

    final Map<String, dynamic>? jsonCurrentWeather = jsonData['current'];

    _current = CurrentWeatherData(
        jsonCurrentWeather?['last_updated'],
        jsonCurrentWeather?['temp_c'],
        jsonCurrentWeather?['is_day'],
        jsonCurrentWeather?['wind_kph'],
        jsonCurrentWeather?['wind_degree'],
        jsonCurrentWeather?['wind_dir'],
        jsonCurrentWeather?['pressure_mb'],
        jsonCurrentWeather?['precip_mm'],
        jsonCurrentWeather?['humidity'],
        jsonCurrentWeather?['cloud'],
        jsonCurrentWeather?['feelslike_c'],
        jsonCurrentWeather?['vis_km'],
        jsonCurrentWeather?['uv'],
        jsonCurrentWeather?['gust_kph']);
  }

  LocationData get location => _location;
  CurrentWeatherData get current => _current;
}
