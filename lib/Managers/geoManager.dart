import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:outfy/Managers/types/types.dart';
import 'package:outfy/utils/weatherCard.dart';

import '../weather/weatherapi.dart';

const dates = ["Сегодня", "Завтра", "Послезавтра"];

const amountVisibleHours = 12;

class GeoManager {
  GeoManager._();
  static final instance = GeoManager._();
  bool _serviceEnabled = false;
  final WeatherRequest _wr = WeatherRequest(dotenv.env['WEATHER_API']!);

  Future<void> getPermission() async {
    LocationPermission permission;
    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
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
    if (!_serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<MainTemp> GetWeather() async {
    final Position position = await getPos();
    final forecastWeather = await _wr.getForecastWeatherByLocation(
        position.latitude, position.longitude);

    final realtimeWeather = await _wr.getRealtimeWeatherByLocation(
        position.latitude, position.longitude);

    return MainTemp(
        Temp: "${realtimeWeather.current.tempC?.toInt()}°",
        FeelsTemp:
            "Ощущается как ${realtimeWeather.current.feelslikeC?.toInt()}°",
        MaxAndMin:
            "${forecastWeather.forecast.first.day.maxtempC?.toInt()}° / ${forecastWeather.forecast.first.day.mintempC?.toInt()}°");
  }

  Future<List<HourData>> GetForecastRaw() async {
    final Position position = await getPos();
    final forecast = await _wr.getForecastWeatherByLocation(
        position.latitude, position.longitude,
        forecastDays: 2);
    final current = DateTime.now().subtract(const Duration(hours: 1));
    final List<HourData> forecasts = [];
    forecast.forecast.forEach((day) {
      day.hour.removeWhere((hour) {
        final local = DateTime.parse(hour.time!);
        return current.isAfter(local);
      });
      forecasts.addAll(day.hour);
    });
    forecasts.removeRange(amountVisibleHours, forecasts.length);
    return forecasts;
  }

  Future<ForecastWeather> GetForecast() async {
    final pos = await getPos();
    return await _wr.getForecastWeatherByLocation(pos.latitude, pos.longitude,
        forecastDays: 3);
  }

  Future<ListView> GetWeatherCard() async {
    final Position position = await getPos();
    final forecastWeather = await _wr.getForecastWeatherByLocation(
        position.latitude, position.longitude,
        forecastDays: 3);

    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastWeather.forecast.length,
        itemBuilder: (_, index) {
          final day = forecastWeather.forecast[index];
          return WeatherCard(
              MaxAndMin:
                  "${day.day.maxtempC?.toInt()}° / ${day.day.mintempC?.toInt()}°",
              date: DateTime.parse(day.date ?? ""),
              text_date: dates[index],
              icon_path: "assets/images/cloudy-icon2.png");
        });
  }
}
