import 'package:flutter/material.dart';
import 'package:outfy/Managers/geoManager.dart';
import 'package:outfy/utils/theme.dart';
import 'package:outfy/utils/weatherCard.dart';

class Wardrobe extends StatefulWidget {
  const Wardrobe({super.key});

  @override
  State<Wardrobe> createState() => _WardrobeState();
}

class _WardrobeState extends State<Wardrobe> with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<WeatherCard> forecast =
      List.generate(3, (_) => WeatherCard(date: DateTime.now()));

  @override
  void initState() {
    super.initState();
    Future(() async {
      _refreshIndicatorKey.currentState?.show();
      await updateForecast();
    });
  }

  Future<void> updateForecast() async {
    final fors = await GeoManager.instance.GetWeatherCard();
    if (mounted) {
      setState(() {
        forecast = fors;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _tabController = TabController(length: 2, vsync: this);
    return Column(
      children: [
        RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: updateForecast,
            color: Colors.black,
            child: Container(
              height: 120,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: forecast.length,
                    itemBuilder: (_, index) => forecast[index]),
              ),
            )),
        Container(
          child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              labelStyle: twardrobeTabs,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.label,
              padding: const EdgeInsets.symmetric(horizontal: 80),
              indicatorPadding: const EdgeInsets.symmetric(vertical: 10),
              indicator: const BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1.6))),
              tabs: [
                const Tab(text: "Гардероб"),
                const Tab(text: "Образы"),
              ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBarView(controller: _tabController, children: [
              Container(),
              Container(),
            ]),
          ),
        )
      ],
    );
  }
}
