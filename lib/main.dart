import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:outfy/Managers/geoManager.dart';
import 'package:outfy/forecast/Forecast.dart';
import 'package:outfy/home/home.dart';
import 'package:outfy/utils/theme.dart';
import 'package:outfy/wardrobe/wardrobe.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await GeoManager.instance.getPermission();
  await initializeDateFormatting('ru');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int pageIndex = 0;

  final pages = [
    const Home(),
    const Wardrobe(),
    Container(),
    const Forecast(),
    Container(),
  ];

  final titles = [
    "Outfy",
    "Wardrobe",
    "Add item",
    "Forecast",
    "Profile",
  ];

  final titlesicon = [
    Image.asset("assets/images/profile-avatar.png", width: 44),
    Image.asset("assets/images/unbrela-icon.png", width: 36),
    Image.asset("assets/images/unbrela-icon.png", width: 36),
    Image.asset("assets/images/unbrela-icon.png", width: 36),
    Image.asset("assets/images/profile-avatar.png", width: 44),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      theme: ThemeData(useMaterial3: false),
      title: "Outfy",
      home: Scaffold(
        body: pages[pageIndex],
        appBar: AppBar(
          backgroundColor: Colors.white,
          forceMaterialTransparency: true,
          title: Text(
            titles[pageIndex],
            style: theader,
          ),
          actions: [
            Container(
                padding: const EdgeInsets.only(right: 20),
                child: titlesicon[pageIndex])
          ],
        ),
        bottomNavigationBar: Container(
          height: 70,
          decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xffF2F2F2)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkResponse(
                onTap: () {
                  setState(() {
                    pageIndex = 0;
                  });
                },
                child: Image.asset(
                  "assets/images/home-icon.png",
                  height: 40,
                ),
              ),
              InkResponse(
                onTap: () {
                  setState(() {
                    pageIndex = 1;
                  });
                },
                child: Image.asset(
                  "assets/images/wardrobe-icon.png",
                  height: 40,
                ),
              ),
              InkResponse(
                onTap: () {
                  setState(() {
                    pageIndex = 2;
                  });
                },
                child: Image.asset(
                  "assets/images/add-icon.png",
                  height: 48,
                ),
              ),
              InkResponse(
                onTap: () {
                  setState(() {
                    pageIndex = 3;
                  });
                },
                child: Image.asset(
                  "assets/images/cal-icon.png",
                  height: 40,
                ),
              ),
              InkResponse(
                onTap: () {
                  setState(() {
                    pageIndex = 4;
                  });
                },
                child: Image.asset(
                  "assets/images/user-icon.png",
                  height: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
