import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:outfy/Managers/types/types.dart';

import '../weather/weatherapi.dart';

class GeoManager {
  GeoManager._();
  static final instance = GeoManager._();
  bool serviceEnabled = false;

  late Position position;

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

  Future<void> getPos() async {
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    this.position = await Geolocator.getCurrentPosition();
    debugPrint(this.position.toString());
  }

  Future<MainTemp> GetWeather() async {
    await getPos();
    final forecastWeather = await wr.getForecastWeatherByLocation(
        this.position.latitude, this.position.longitude);

    final realtimeWeather = await wr.getRealtimeWeatherByLocation(
        this.position.latitude, this.position.longitude);

    return MainTemp(
        Temp: realtimeWeather.current.tempC.toString(),
        FeelsTemp:
            "Ощущается как ${realtimeWeather.current.feelslikeC?.toInt()}",
        MaxAndMin:
            "${forecastWeather.forecast.first.day.mintempC}° / ${forecastWeather.forecast.first.day.maxtempC}°");
  }
}
