import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:outfy/Managers/types/types.dart';

import '../weather/weatherapi.dart';

class GeoManager {
  GeoManager._();
  static final instance = GeoManager._();
  bool serviceEnabled = false;
  final WeatherRequest wr = WeatherRequest(dotenv.env['WEATHER_API']!);

  Future<void> getPermission() async {
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  Future<Position> getPos() async {
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<MainTemp> GetWeather() async {
    final Position position = await getPos();
    final forecastWeather = await wr.getForecastWeatherByLocation(
        position.latitude, position.longitude);

    final realtimeWeather = await wr.getRealtimeWeatherByLocation(
        position.latitude, position.longitude);

    return MainTemp(
        Temp: "${realtimeWeather.current.tempC?.toInt()}",
        FeelsTemp:
            "Ощущается как ${realtimeWeather.current.feelslikeC?.toInt()}",
        MaxAndMin:
            "${forecastWeather.forecast.first.day.maxtempC?.toInt()}° / ${forecastWeather.forecast.first.day.mintempC?.toInt()}°");
  }
}
