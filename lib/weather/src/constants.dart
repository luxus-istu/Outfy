const int minForecastDays = 1;
const int maxForecastDays = 14;
const int httpStatusOk = 200;

enum APIType { realtime, forecast, search }

const Map<APIType, String> ApiTypeBaseUrls = {
  APIType.realtime: 'https://api.weatherapi.com/v1/current.json',
  APIType.forecast: 'https://api.weatherapi.com/v1/forecast.json',
  APIType.search: 'https://api.weatherapi.com/v1/search.json'
};
