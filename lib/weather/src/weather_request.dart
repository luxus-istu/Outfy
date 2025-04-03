import 'constants.dart';
import 'domains/realtime_weather.dart';
import 'domains/forecast_weather.dart';
import 'domains/search_results.dart';
import 'exceptions.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherRequest {
  final String _apiKey;
  late final http.Client _httpClient;

  WeatherRequest(this._apiKey) {
    _httpClient = http.Client();
  }

  Future<RealtimeWeather> getRealtimeWeatherByLocation(
      double latitude, double longitude) async {
    final Map<String, dynamic>? jsonResponse =
        await _sendRequest<Map<String, dynamic>>(APIType.realtime,
            latitude: latitude, longitude: longitude);

    return RealtimeWeather(jsonResponse!);
  }

  Future<RealtimeWeather> getRealtimeWeatherByCityName(String cityName) async {
    final Map<String, dynamic>? jsonResponse =
        await _sendRequest<Map<String, dynamic>>(APIType.realtime,
            cityName: cityName);

    return RealtimeWeather(jsonResponse!);
  }

  Future<ForecastWeather> getForecastWeatherByLocation(
      double latitude, double longitude,
      {int forecastDays = 1, int tp = 60}) async {
    final Map<String, dynamic>? jsonResponse =
        await _sendRequest<Map<String, dynamic>>(APIType.forecast,
            latitude: latitude,
            longitude: longitude,
            tp: tp,
            forecastDays: forecastDays);

    return ForecastWeather(jsonResponse!);
  }

  Future<ForecastWeather> getForecastWeatherByCityName(String cityName,
      {int forecastDays = 1}) async {
    final Map<String, dynamic>? jsonResponse =
        await _sendRequest<Map<String, dynamic>>(APIType.forecast,
            cityName: cityName, forecastDays: forecastDays);

    return ForecastWeather(jsonResponse!);
  }

  Future<SearchResults> getResultsByLocation(
      double latitude, double longitude) async {
    final List<dynamic>? jsonResponse = await _sendRequest<List<dynamic>>(
        APIType.search,
        latitude: latitude,
        longitude: longitude);

    return SearchResults(jsonResponse!);
  }

  Future<SearchResults> getResultsByCityName(String cityName) async {
    final List<dynamic>? jsonResponse =
        await _sendRequest<List<dynamic>>(APIType.search, cityName: cityName);

    return SearchResults(jsonResponse!);
  }

  Future<T?> _sendRequest<T>(APIType apiType,
      {String? cityName,
      double? latitude,
      double? longitude,
      int forecastDays = 1,
      int tp = 60}) async {
    assert((cityName != null && cityName.isNotEmpty) ||
        (latitude != null && longitude != null));
    assert(forecastDays >= minForecastDays && forecastDays <= maxForecastDays);

    final String url =
        _buildUrl(apiType, cityName, latitude, longitude, forecastDays, tp);

    final http.Response response = await _httpClient.get(Uri.parse(url));
    final dynamic jsonBody = json.decode(response.body);

    if (response.statusCode != httpStatusOk) {
      throw new WeatherAPIException(jsonBody!['error']['message']);
    }

    return jsonBody as T;
  }

  String _buildUrl(APIType apiType, String? cityName, double? latitude,
      double? longitude, int forecastDays, int tp) {
    assert((cityName != null && cityName.isNotEmpty) ||
        (latitude != null && longitude != null));
    assert(forecastDays >= minForecastDays && forecastDays <= maxForecastDays);

    String url = '${ApiTypeBaseUrls[apiType]}?';
    url += 'key=$_apiKey';

    if (cityName != null) {
      url += '&q=$cityName';
    } else {
      url += '&q=$latitude,$longitude';
    }

    if (apiType == APIType.forecast) {
      url += '&days=$forecastDays';
      url += '&tp==$tp';
    }

    return url;
  }
}
