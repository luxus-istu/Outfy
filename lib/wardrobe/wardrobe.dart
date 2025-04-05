import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:outfy/Managers/geoManager.dart';
import 'package:outfy/adding/Adding.dart';
import 'package:outfy/utils/theme.dart';
import 'package:outfy/utils/weatherCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../Managers/types/types.dart';

class Wardrobe extends StatefulWidget {
  const Wardrobe({super.key});

  @override
  State<Wardrobe> createState() => _WardrobeState();
}

class _WardrobeState extends State<Wardrobe> with TickerProviderStateMixin {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  var _isLoading = true;
  String? _selectedOutfitType;

  ListView _forecastList = ListView.builder(
      itemCount: 3,
      itemBuilder: (_, index) => WeatherCard(date: DateTime.now()));

  List<ClothingItem> _clothingItems = [];

  @override
  void initState() {
    super.initState();
    Future(() async {
      _refreshIndicatorKey.currentState?.show();
      await _updateForecast();
      await _loadClothingItems();
    });
  }

  Future<void> _loadClothingItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString('clothing_items') ?? '[]';
    final List<dynamic> itemsList = jsonDecode(itemsJson);
    if (mounted) {
      setState(() {
        _clothingItems = itemsList
            .map((item) => ClothingItem.fromJson(item as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> _deleteItem(ClothingItem item) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _clothingItems.remove(item);
    });

    final updatedItemsJson =
        jsonEncode(_clothingItems.map((e) => e.toJson()).toList());
    await prefs.setString('clothing_items', updatedItemsJson);
  }

  List<String> _getUniqueOutfitTypes() {
    return _clothingItems.map((item) => item.outfitType).toSet().toList();
  }

  List<ClothingItem> _getFilteredItems() {
    if (_selectedOutfitType == null) {
      return _clothingItems;
    }
    return _clothingItems
        .where((item) => item.outfitType == _selectedOutfitType)
        .toList();
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

  void _showDeleteConfirmationDialog(ClothingItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Удалить предмет"),
        content: const Text("Вы уверены, что хотите удалить этот предмет?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Отмена", style: twardrobetext),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteItem(item);
            },
            child: const Text(
              "Удалить",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Montserrat",
                  color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addingNewButton() {
    return GestureDetector(
      onTap: () {
        showBottomSheet(
            context: context,
            builder: (context) {
              return const AddingItem();
            });
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, size: 40, color: Colors.black54),
              SizedBox(height: 8),
              Text(
                "Добавить",
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
    );
  }

  Widget _getWardrobeItems() {
    final outfitTypes = _getUniqueOutfitTypes();
    final filteredItems = _getFilteredItems();
    return Skeletonizer(
      enableSwitchAnimation: true,
      enabled: _isLoading,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (outfitTypes.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: outfitTypes.length,
                  itemBuilder: (context, index) {
                    final outfitType = outfitTypes[index];
                    final isSelected = _selectedOutfitType == outfitType;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedOutfitType = outfitType;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withValues(alpha: 0.2)
                                : const Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? Border.all(color: Colors.blue, width: 2)
                                : null,
                          ),
                          child: Text(
                            outfitType,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blue : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Expanded(
              child: filteredItems.isEmpty
                  ? _addingNewButton()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredItems.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _addingNewButton();
                        }

                        final item = filteredItems[index - 1];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            item.imagePath != null &&
                                    File(item.imagePath!).existsSync()
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
                                        File(item.imagePath!),
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
                                GestureDetector(
                                  child: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onTap: () =>
                                      _showDeleteConfirmationDialog(item),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
            ),
          ],
        ),
      ),
    );
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
            child: TabBarView(
                controller: _tabController,
                children: [_getWardrobeItems(), Container()]),
          ),
        )
      ],
    );
  }
}
