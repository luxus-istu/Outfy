import 'package:flutter/material.dart';
import 'package:outfy/Managers/geoManager.dart';
import 'package:outfy/utils/weatherCard.dart';

class Wardrobe extends StatefulWidget {
  const Wardrobe({super.key});

  @override
  State<Wardrobe> createState() => _WardrobeState();
}

class _WardrobeState extends State<Wardrobe> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<WeatherCard> forecast = [
    WeatherCard(date: DateTime.now()),
    WeatherCard(date: DateTime.now()),
    WeatherCard(date: DateTime.now())
  ];

  @override
  void initState() {
    super.initState();
    Future(() async {
      _refreshIndicatorKey.currentState?.show();
      await updateForecast();
    });
  }

  Future<void> updateForecast() async {
    var fors = await GeoManager.instance.GetWeatherCard();
    if (mounted) {
      setState(() {
        forecast = fors;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: updateForecast,
        color: Colors.black,
        child: Container(
          height: 120,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.length,
                itemBuilder: (BuildContext _, int index) {
                  return forecast[index];
                }),
          ),
        ));
  }
}
