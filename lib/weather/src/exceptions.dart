class WeatherAPIException implements Exception {
  final String _cause;
  const WeatherAPIException(this._cause);

  @override
  String toString() {
    return '$runtimeType: $_cause';
  }
}
