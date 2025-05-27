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
  final _navigatorKey = GlobalKey<NavigatorState>();
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      theme: ThemeData(useMaterial3: false),
      title: "Outfy",
      home: Scaffold(
          body: Navigator(key: _navigatorKey, onGenerateRoute: generateRoute),
          appBar: AppBar(
            backgroundColor: Colors.white,
            forceMaterialTransparency: true,
            centerTitle: true,
            title: Text(
              titles[pageIndex],
              style: theader,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              iconSize: 40,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: pageIndex,
              onTap: _onTap,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    activeIcon: Icon(
                      Icons.home,
                      color: Colors.black,
                    ),
                    icon: Icon(
                      Icons.home_outlined,
                      color: Colors.black,
                    ),
                    label: ""),
                BottomNavigationBarItem(
                    icon: Image.asset(
                      "assets/icons/wardrobe-outline.png",
                      height: 40,
                    ),
                    activeIcon: Image.asset(
                      "assets/icons/wardrobe.png",
                      height: 40,
                    ),
                    label: ""),
                BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_outlined,
                        color: Colors.black),
                    activeIcon: Icon(Icons.calendar_today, color: Colors.black),
                    label: "")
              ])),
    );
  }

  _onTap(int tabIndex) {
    switch (tabIndex) {
      case 1:
        _navigatorKey.currentState?.pushReplacementNamed("Wardrobe");
        break;
      case 2:
        _navigatorKey.currentState?.pushReplacementNamed("Forecast");
        break;
      default:
        _navigatorKey.currentState?.pushReplacementNamed("Home");
        break;
    }
    setState(() {
      pageIndex = tabIndex;
    });
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "Wardrobe":
        setState(() {
          pageIndex = 1;
        });
        return MaterialPageRoute(builder: (_) => wardrobe);
      case "Forecast":
        setState(() {
          pageIndex = 2;
        });
        return MaterialPageRoute(builder: (_) => forecst);
      default:
        setState(() {
          pageIndex = 0;
        });
        return MaterialPageRoute(builder: (_) => home);
    }
  }
}
