import 'structures.dart';

class SearchResults {
  final List<LocationResultData> _locations = [];

  SearchResults(final List<dynamic> jsonData) {
    for (dynamic location in jsonData) {
      LocationResultData result = LocationResultData(
          location['id'],
          location['name'],
          location['region'],
          location['country'],
          location['lat'],
          location['lon'],
          location['url']);

      _locations.add(result);
    }
  }

  List<LocationResultData> get locations => _locations;
}
