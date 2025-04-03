import 'package:flutter/material.dart';
import 'package:outfy/Managers/geoManager.dart';
import 'package:outfy/Managers/types/types.dart';
import 'package:outfy/utils/theme.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  var _mainTemp = MainTemp();

  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future(() async {
      _refreshIndicatorKey.currentState?.show();
      await _updateWeather();
    });
  }

  Future<void> _updateWeather() async {
    var data = await GeoManager.instance.GetWeather();
    if (mounted) {
      setState(() {
        this._mainTemp = data;
        this._isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.black,
      key: _refreshIndicatorKey,
      onRefresh: _updateWeather,
      child: ListView(
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Image.asset("assets/images/cloudy.jpg"),
              weatherBlur,
              Skeletonizer(
                  enabled: _isLoading,
                  enableSwitchAnimation: true,
                  child: Column(
                    children: [
                      Row(
                        spacing: 12,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _mainTemp.Temp,
                            style: twatherheader,
                          ),
                          Image.asset(
                            "assets/images/cloudy-icon.png",
                            width: 36,
                          )
                        ],
                      ),
                      Text(
                        _mainTemp.FeelsTemp,
                        style: twathertext,
                      ),
                      Text(
                        _mainTemp.MaxAndMin,
                        style: twathertext,
                      ),
                    ],
                  )),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 30),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    spacing: 14,
                    children: [
                      Image.asset(
                        "assets/images/wardrobe-icon.png",
                        height: 40,
                      ),
                      const Text(
                        "Из вашего гардероба\nхорошо подойдёт:",
                        style: twardrobeTitle,
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
