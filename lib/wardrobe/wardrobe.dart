import 'package:flutter/material.dart';
import 'package:outfy/Managers/geoManager.dart';
import 'package:outfy/utils/theme.dart';
import 'package:outfy/utils/weatherCard.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Wardrobe extends StatefulWidget {
  const Wardrobe({super.key});

  @override
  State<Wardrobe> createState() => _WardrobeState();
}

class _WardrobeState extends State<Wardrobe> with TickerProviderStateMixin {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  var _isLoading = true;

  ListView _forecastList = ListView.builder(
      itemCount: 3,
      itemBuilder: (_, index) => WeatherCard(date: DateTime.now()));

  @override
  void initState() {
    super.initState();
    Future(() async {
      _refreshIndicatorKey.currentState?.show();
      await _updateForecast();
    });
  }

  Future<void> _updateForecast() async {
    final fors = await GeoManager.instance.GetWeatherCard();
    if (mounted) {
      setState(() {
        _forecastList = fors;
        _isLoading = false;
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
            onRefresh: _updateForecast,
            color: Colors.black,
            child: Container(
              height: 85,
              child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Skeletonizer(
                      enabled: _isLoading,
                      enableSwitchAnimation: true,
                      child: _forecastList)),
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
