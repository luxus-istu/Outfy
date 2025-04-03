// ignore_for_file: public_member_api_docs, sort_constructors_first
class LocationData {
  final String? _name;
  final String? _region;
  final String? _country;
  final double? _lat;
  final double? _lon;

  const LocationData(
      this._name, this._region, this._country, this._lat, this._lon);

  String? get name => _name;
  String? get region => _region;
  String? get country => _country;
  double? get lat => _lat;
  double? get lon => _lon;
}

class CurrentWeatherData {
  final String? _lastUpdated;
  final double? _tempC;
  final int? _isDay;
  final double? _windKph;
  final int? _windDegree;
  final String? _windDir;
  final double? _pressureMb;
  final double? _precipMm;
  final int? _humidity;
  final int? _cloud;
  final double? _feelslikeC;
  final double? _visKm;
  final double? _uv;
  final double? _gustKph;

  const CurrentWeatherData(
      this._lastUpdated,
      this._tempC,
      this._isDay,
      this._windKph,
      this._windDegree,
      this._windDir,
      this._pressureMb,
      this._precipMm,
      this._humidity,
      this._cloud,
      this._feelslikeC,
      this._visKm,
      this._uv,
      this._gustKph);

  String? get lastUpdated => _lastUpdated;
  double? get tempC => _tempC;
  int? get isDay => _isDay;
  double? get windKph => _windKph;
  int? get windDegree => _windDegree;
  String? get windDir => _windDir;
  double? get pressureMb => _pressureMb;
  double? get precipMm => _precipMm;
  int? get humidity => _humidity;
  int? get cloud => _cloud;
  double? get feelslikeC => _feelslikeC;
  double? get visKm => _visKm;
  double? get uv => _uv;
  double? get gustKph => _gustKph;
}

class DayData {
  final double? _maxtempC;
  final double? _mintempC;
  final double? _avgtempC;
  final double? _maxwindKph;
  final double? _totalprecipMm;
  final double? _totalsnowCm;
  final double? _avgvisKm;
  final int? _avghumidity;
  final int? _dailyWillItRain;
  final int? _dailyChanceOfRain;
  final int? _dailyWillItSnow;
  final int? _dailyChanceOfSnow;
  final double? _uv;

  const DayData(
      this._maxtempC,
      this._mintempC,
      this._avgtempC,
      this._maxwindKph,
      this._totalprecipMm,
      this._totalsnowCm,
      this._avgvisKm,
      this._avghumidity,
      this._dailyWillItRain,
      this._dailyChanceOfRain,
      this._dailyWillItSnow,
      this._dailyChanceOfSnow,
      this._uv);

  double? get maxtempC => _maxtempC;
  double? get mintempC => _mintempC;
  double? get avgtempC => _avgtempC;
  double? get maxwindKph => _maxwindKph;
  double? get totalprecipMm => _totalprecipMm;
  double? get totalSnowCm => _totalsnowCm;
  double? get avgvisKm => _avgvisKm;
  int? get avghumidity => _avghumidity;
  int? get dailyWillItRain => _dailyWillItRain;
  int? get dailyChanceOfRain => _dailyChanceOfRain;
  int? get dailyWillItSnow => _dailyWillItSnow;
  int? get dailyChanceOfSnow => _dailyChanceOfSnow;
  double? get uv => _uv;
}

class HourData {
  final String? _time;
  final double? _tempC;
  final int? _isDay;
  final double? _windKph;
  final int? _windDegree;
  final String? _windDir;
  final double? _pressureMb;
  final double? _precipMm;
  final double? _snowCm;
  final int? _humidity;
  final int? _cloud;
  final double? _feelslikeC;
  final double? _windchillC;
  final double? _heatindexC;
  final double? _dewpointC;
  final int? _willItRain;
  final int? _chanceOfRain;
  final int? _willItSnow;
  final int? _chanceOfSnow;
  final double? _visKm;
  final double? _gustKph;

  const HourData(
      this._time,
      this._tempC,
      this._isDay,
      this._windKph,
      this._windDegree,
      this._windDir,
      this._pressureMb,
      this._precipMm,
      this._snowCm,
      this._humidity,
      this._cloud,
      this._feelslikeC,
      this._windchillC,
      this._heatindexC,
      this._dewpointC,
      this._willItRain,
      this._chanceOfRain,
      this._willItSnow,
      this._chanceOfSnow,
      this._visKm,
      this._gustKph);

  String? get time => _time;
  double? get tempC => _tempC;
  int? get isDay => _isDay;
  double? get windKph => _windKph;
  int? get windDegree => _windDegree;
  String? get windDir => _windDir;
  double? get pressureMb => _pressureMb;
  double? get precipMm => _precipMm;
  double? get snowCm => _snowCm;
  int? get humidity => _humidity;
  int? get cloud => _cloud;
  double? get feelslikeC => _feelslikeC;
  double? get windchillC => _windchillC;
  double? get heatindexC => _heatindexC;
  double? get dewpointC => _dewpointC;
  int? get willItRain => _willItRain;
  int? get chanceOfRain => _chanceOfRain;
  int? get willItSnow => _willItSnow;
  int? get chanceOfSnow => _chanceOfSnow;
  double? get visKm => _visKm;
  double? get gustKph => _gustKph;
}

class ForecastDayData {
  final String? _date;
  final DayData _day;
  final List<HourData> _hour;

  const ForecastDayData(this._date, this._day, this._hour);

  String? get date => _date;
  DayData get day => _day;
  List<HourData> get hour => _hour;
}

class LocationResultData {
  final int? _id;
  final String? _name, _region, _country, _url;
  final double? _lat, _lon;

  const LocationResultData(this._id, this._name, this._region, this._country,
      this._lat, this._lon, this._url);

  int? get id => _id;
  String? get name => _name;
  String? get region => _region;
  String? get country => _country;
  String? get url => _url;
  double? get lat => _lat;
  double? get lon => _lon;
}
