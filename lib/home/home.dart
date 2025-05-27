import 'dart:io';

import 'package:flutter/material.dart';
import 'package:outfy/Managers/ClothManager.dart';
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
  final _clothManager = const ClothManager();
  var _isLoading = true;

  List<ClothingItem> _clothingItems = [];
  List<Outfit> _outfits = [];

  var _mainTemp = MainTemp();

  @override
  void initState() {
    super.initState();
    Future(() async {
      _refreshIndicatorKey.currentState?.show();
      await _updateWeather();
    });
  }

  List<ClothingItem> _resolveItems(List<String> itemIds) {
    return _clothingItems.where((item) => itemIds.contains(item.id)).toList();
  }

  Future<void> _updateWeather() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final data = await GeoManager.instance.GetWeather();
    final clothingItems = await _clothManager.LoadClothingItems();
    final outfits = await _clothManager.LoadOutfits();

    if (mounted) {
      setState(() {
        this._mainTemp = data;
        this._clothingItems = clothingItems;
        this._outfits = outfits;
        this._isLoading = false;
      });
    }
  }

  bool _isTempRangeWithin(String rangeStr, String allowedStr) {
    try {
      List<int> parseTempRange(String str) {
        final parts = str.replaceAll('°', '').split('/');
        return [
          int.parse(parts[1].trim()),
          int.parse(parts[0].trim()),
        ];
      }

      final range = parseTempRange(rangeStr);
      final allowed = parseTempRange(allowedStr);

      int minTemp = range[0];
      int maxTemp = range[1];
      int minAllowed = allowed[0];
      int maxAllowed = allowed[1];

      return minTemp >= minAllowed && maxTemp <= maxAllowed;
    } catch (e) {
      print('Ошибка парсинга: $e');
      return false;
    }
  }

  List<ClothingItem> _getFilteredItems() {
    return _clothingItems
        .where((item) =>
            _isTempRangeWithin(item.weatherRecommendation, _mainTemp.MaxAndMin))
        .toList();
  }

  Widget _getWardrobeItems() {
    final filteredItems = _getFilteredItems();
    return Skeletonizer(
      enableSwitchAnimation: true,
      enabled: _isLoading,
      child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                File(item.imagePath).existsSync()
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(0, 4),
                              color: Color(0x1a000000),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(item.imagePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 120,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0xffF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(0, 4),
                              color: Color(0x1a000000),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        width: double.infinity,
                        height: 120,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }

  Widget _getOutfits() {
    return Skeletonizer(
      enabled: _isLoading,
      enableSwitchAnimation: true,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _outfits.length,
        itemBuilder: (context, index) {
          final outfit = _outfits[index];
          return GestureDetector(
            onTap: () {
              _showOutfitDetails(context, outfit);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(outfit.imagePath)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: .4), BlendMode.darken),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(outfit.name, style: twardrobeoutfitname),
                    Text(outfit.outfitType, style: twathertext),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOutfitDetails(BuildContext context, Outfit outfit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final outfitItems = _resolveItems(outfit.itemIds);

        return AlertDialog(
          title: Text(
            outfit.name,
            style: twardrobetext,
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: outfitItems.length,
              itemBuilder: (context, index) {
                final item = outfitItems[index];
                return ListTile(
                  leading: Image.file(
                    File(item.imagePath),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.name),
                  subtitle: Text(item.clothType),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Закрыть",
                style: twardrobetext,
              ),
            ),
          ],
        );
      },
    );
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
              Image.asset(
                _mainTemp.WillItRain
                    ? "assets/images/cloudy.jpg"
                    : "assets/images/sunny.jpg",
                height: MediaQuery.sizeOf(context).width,
                fit: BoxFit.fitWidth,
                width: MediaQuery.sizeOf(context).width,
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
                  )),
            ],
          ),
          Column(
            children: [
              Skeletonizer(
                enableSwitchAnimation: true,
                enabled: _isLoading,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _clothingItems.isEmpty
                      ? Column(
                          spacing: 8,
                          children: [
                            const Text(
                              "У вас пустой гардероб",
                              style: const TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushReplacementNamed("Wardrobe");
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF8F8F8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          Colors.grey.withValues(alpha: 0.5)),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add,
                                          size: 40, color: Colors.black54),
                                      SizedBox(height: 8),
                                      const Text(
                                        "Добавить одежду",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      : Column(
                          children: [
                            Row(
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
                          ],
                        ),
                ),
              ),
              _getWardrobeItems(),
            ],
          ),
          Skeletonizer(
            enableSwitchAnimation: true,
            enabled: _isLoading,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _outfits.isEmpty
                  ? Column(
                      spacing: 8,
                      children: [
                        const Text(
                          "У вас нет образов",
                          style: const TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushReplacementNamed("Wardrobe");
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xffF8F8F8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.5)),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add,
                                      size: 40, color: Colors.black54),
                                  SizedBox(height: 8),
                                  const Text(
                                    "Добавить образ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          spacing: 14,
                          children: [
                            Image.asset(
                              "assets/images/box-icon.png",
                              height: 28,
                            ),
                            const Text(
                              "Стоит посмотреть ваши\nсоставленные наборы одежды:",
                              style: twardrobeTitle,
                            )
                          ],
                        ),
                        _getOutfits()
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
