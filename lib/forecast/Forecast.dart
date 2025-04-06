import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:outfy/Managers/geoManager.dart';
import 'package:outfy/Managers/types/types.dart';
import 'package:outfy/utils/theme.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../weather/weatherapi.dart';

const _containerDecoration = const BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(12)));

const padding20 = const EdgeInsets.all(20);

class Forecast extends StatefulWidget {
  const Forecast({super.key});

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  var _mainTemp = MainTemp();
  List<HourData> _forecast = [];
  var _isLoading = true;
  ForecastWeather _forecastWeather = ForecastWeather(Map<String, dynamic>());

  @override
  void initState() {
    super.initState();
    Future(() async {
      _refreshIndicatorKey.currentState?.show();
      await _updateWeather();
    });
  }

  Future<void> _updateWeather() async {
    final fors = await GeoManager.instance.GetForecastRaw();
    final data = await GeoManager.instance.GetWeather();
    final fores = await GeoManager.instance.GetForecast();
    if (mounted) {
      setState(() {
        this._mainTemp = data;
        this._forecast = fors;
        this._forecastWeather = fores;
        this._isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage(_mainTemp.WillItRain
            ? "assets/images/cloudy.jpg"
            : "assets/images/sunny.jpg"),
        fit: BoxFit.cover,
      )),
      child: RefreshIndicator(
        color: Colors.black,
        key: _refreshIndicatorKey,
        onRefresh: _updateWeather,
        child: ListView(
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                const Padding(
                  padding: const EdgeInsets.only(top: 73, bottom: 34),
                  child: const SizedBox(
                    width: double.maxFinite,
                    height: 220,
                  ),
                ),
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
                              _mainTemp.WillItRain
                                  ? "assets/images/rain-icon.png"
                                  : "assets/images/cloudy-icon.png",
                              width: 36,
                              color: Colors.white,
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
                    ))
              ],
            ),
            Container(
              padding: padding20,
              decoration: _containerDecoration,
              child: Column(
                spacing: 16,
                children: [
                  Row(
                    spacing: 16,
                    children: [
                      Image.asset(
                        "assets/images/clock-icon.png",
                        width: 20,
                      ),
                      const Text(
                        "Почасовая погода",
                        style: tforecastHourly,
                      )
                    ],
                  ),
                  Container(
                      height: 90,
                      child: Skeletonizer(
                          enabled: _isLoading,
                          enableSwitchAnimation: true,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _forecast.isEmpty ? 0 : _forecast.length,
                            separatorBuilder: (_, index) => const SizedBox(
                              width: 8,
                            ),
                            itemBuilder: (_, index) {
                              return Column(
                                spacing: 12,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: index == 0
                                          ? const BoxDecoration(
                                              color: Color(0xffDEDEDE),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(4)))
                                          : null,
                                      child: Text(
                                          "${_forecast[index].tempC?.toInt()}°",
                                          style: twardrobeTabs)),
                                  Image.asset(
                                    _forecast[index].willItRain == 1
                                        ? "assets/images/rain-icon.png"
                                        : "assets/images/cloudy-icon3.png",
                                    filterQuality: FilterQuality.high,
                                    width: 18,
                                    height: 18,
                                  ),
                                  Text(index == 0
                                      ? "Сейчас"
                                      : "${DateFormat.Hm().format(DateTime.parse(_forecast[index].time!))}"),
                                ],
                              );
                            },
                          )))
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
                padding: padding20,
                decoration: _containerDecoration,
                child: Column(
                  spacing: 16,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        Image.asset(
                          "assets/images/calendar-icon.png",
                          width: 20,
                        ),
                        const Text(
                          "Погода на 3 дня",
                          style: tforecastHourly,
                        )
                      ],
                    ),
                    Container(
                      height: 150,
                      child: Skeletonizer(
                          enableSwitchAnimation: true,
                          enabled: _isLoading,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _forecastWeather.forecast.length,
                            separatorBuilder: (_, i) =>
                                const SizedBox(width: 10),
                            itemBuilder: (con, index) {
                              final wid = (MediaQuery.sizeOf(con).width -
                                      (10 * _forecastWeather.forecast.length) -
                                      70) /
                                  _forecastWeather.forecast.length;
                              final day = _forecastWeather.forecast[index];
                              return Container(
                                width: wid,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: const BoxDecoration(
                                    color: Color(0xffF2F2F2),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                child: Column(
                                  spacing: 16,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text("${day.day.maxtempC?.toInt()}°",
                                            style: twardrobeTabs),
                                        Text("${day.day.mintempC?.toInt()}°",
                                            style: twardrobeTabsGray),
                                      ],
                                    ),
                                    Image.asset(
                                      day.day.dailyWillItRain == 1
                                          ? "assets/images/rain-icon.png"
                                          : "assets/images/cloudy-icon3.png",
                                      filterQuality: FilterQuality.high,
                                      width: 24,
                                      height: 24,
                                    ),
                                    Column(
                                      children: [
                                        Text(index == 0
                                            ? "Сейчас"
                                            : DateFormat.E().format(
                                                DateTime.parse(day.date!))),
                                        Text(DateFormat('d LLLL', 'ru')
                                            .format(DateTime.parse(day.date!)))
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          )),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
