import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/Constants.dart';
import 'types/types.dart';

class ClothManager {
  const ClothManager();

  Future<List<ClothingItem>> LoadClothingItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString('clothing_items') ?? '[]';
    final List<dynamic> itemsList = jsonDecode(itemsJson);
    return itemsList
        .map((item) => ClothingItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> GetExistingOutfitTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final existingItemsJson = prefs.getString('clothing_items') ?? '[]';
    final List<dynamic> existingItems = jsonDecode(existingItemsJson);
    final List<ClothingItem> items = existingItems
        .map((item) => ClothingItem.fromJson(item as Map<String, dynamic>))
        .toList();
    final outfitTypes = items.map((item) => item.outfitType).toSet().toList();
    return [...defaultOutfitTypes, ...outfitTypes]
        .toSet()
        .where((type) => type.isNotEmpty)
        .toList();
  }

  Future<String> SaveImagePermanently(final File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final newPath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    return image.copy(newPath).then((file) => file.path);
  }

  Future<void> SaveClothingItem(final ClothingItem item) async {
    final prefs = await SharedPreferences.getInstance();

    final existingItemsJson = prefs.getString('clothing_items') ?? '[]';
    final List<dynamic> existingItems = jsonDecode(existingItemsJson);
    final List<ClothingItem> items = existingItems
        .map((item) => ClothingItem.fromJson(item as Map<String, dynamic>))
        .toList();

    items.add(item);

    final updatedItemsJson =
        jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString('clothing_items', updatedItemsJson);
  }

  Future<List<Outfit>> LoadOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('outfits') ?? '[]';

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Outfit.fromJson(json)).toList();
  }

  Future<void> SaveOutfit(Outfit outfit) async {
    final prefs = await SharedPreferences.getInstance();

    final currentOutfits = await LoadOutfits();

    currentOutfits.add(outfit);

    final jsonList = currentOutfits.map((outfit) => outfit.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await prefs.setString('outfits', jsonString);
  }

  Future<void> DeleteOutfit(Outfit outfit) async {
    final outfits = await LoadOutfits();
    outfits.removeWhere((o) => o.name == outfit.name);
    await _saveOutfits(outfits);
  }

  Future<void> _saveOutfits(List<Outfit> outfits) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = outfits.map((outfit) => outfit.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await prefs.setString('outfits', jsonString);
  }
}
