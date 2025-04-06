import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:outfy/Managers/geoManager.dart';
import 'package:outfy/utils/theme.dart';

import 'utils/Constants.dart';

Future<void> main() async {
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
          centerTitle: true,
          title: Text(
            titles[pageIndex],
            style: theader,
          ),
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
                  "assets/images/cal-icon.png",
                  height: 40,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
