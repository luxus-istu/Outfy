import 'structures.dart';

class ForecastWeather {
  late final LocationData _location;
  late final CurrentWeatherData _current;
  late final List<ForecastDayData> _forecast;

  ForecastWeather(final Map<String, dynamic> jsonData) {
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
      jsonCurrentWeather?['gust_mph'],
    );

    final Map<String, dynamic>? jsonForecast = jsonData['forecast'];
    final List<dynamic>? jsonForecastDays = jsonForecast?['forecastday'];

    _forecast = [];

    jsonForecastDays?.forEach((jsonForecastDay) {
      final Map<String, dynamic>? jsonDay = jsonForecastDay?['day'];

      final DayData day = DayData(
          jsonDay?['maxtemp_c'],
          jsonDay?['mintemp_c'],
          jsonDay?['avgtemp_c'],
          jsonDay?['maxwind_kph'],
          jsonDay?['totalprecip_mm'],
          jsonDay?['totalsnow_cm'],
          jsonDay?['avgvis_km'],
          jsonDay?['avghumidity'],
          jsonDay?['daily_will_it_rain'],
          jsonDay?['daily_chance_of_rain'],
          jsonDay?['daily_will_it_snow'],
          jsonDay?['daily_chance_of_snow'],
          jsonDay?['uv']);

      final List<dynamic>? jsonForecastHour = jsonForecastDay?['hour'];
      final List<HourData> hours = [];

      jsonForecastHour?.forEach((jsonHour) {
        final HourData hour = HourData(
            jsonHour?['time'],
            jsonHour?['temp_c'],
            jsonHour?['is_day'],
            jsonHour?['wind_kph'],
            jsonHour?['wind_degree'],
            jsonHour?['wind_dir'],
            jsonHour?['pressure_mb'],
            jsonHour?['precip_mm'],
            jsonHour?['snow_cm'],
            jsonHour?['humidity'],
            jsonHour?['cloud'],
            jsonHour?['feelslike_c'],
            jsonHour?['windchill_c'],
            jsonHour?['heatindex_c'],
            jsonHour?['dewpoint_c'],
            jsonHour?['will_it_rain'],
            jsonHour?['chance_of_rain'],
            jsonHour?['will_it_snow'],
            jsonHour?['chance_of_snow'],
            jsonHour?['vis_km'],
            jsonHour?['gust_kph'],
            jsonHour?['uv']);

        hours.add(hour);
      });

      final ForecastDayData forecast =
          ForecastDayData(jsonForecastDay?['date'], day, hours);

      _forecast.add(forecast);
    });
  }

  LocationData get location => _location;
  CurrentWeatherData get current => _current;
  List<ForecastDayData> get forecast => _forecast;
}
