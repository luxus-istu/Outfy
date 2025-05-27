class MainTemp {
  final String Temp, FeelsTemp, MaxAndMin;
  final bool WillItRain;

  const MainTemp(
      {this.Temp = "--°",
      this.FeelsTemp = "Ощущается как --°",
      this.MaxAndMin = "--° / --°",
      this.WillItRain = false});
}

class ClothingItem {
  final String id;
  final String name;
  final String clothType;
  final String seasonType;
  final String outfitType;
  final String sizeType;
  final String weatherRecommendation;
  final String imagePath;

  const ClothingItem({
    required this.id,
    required this.name,
    required this.clothType,
    required this.seasonType,
    required this.outfitType,
    required this.sizeType,
    required this.weatherRecommendation,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'clothType': clothType,
      'seasonType': seasonType,
      'outfitType': outfitType,
      'sizeType': sizeType,
      'weatherRecommendation': weatherRecommendation,
      'imagePath': imagePath,
    };
  }

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] ?? '',
      name: json['name'],
      clothType: json['clothType'],
      seasonType: json['seasonType'],
      outfitType: json['outfitType'],
      sizeType: json['sizeType'],
      weatherRecommendation: json['weatherRecommendation'],
      imagePath: json['imagePath'],
    );
  }
}

class Outfit {
  final String name, imagePath;
  final String seasonType;
  final String outfitType;
  final String weatherRecommendation;
  final List<String> itemIds;

  const Outfit({
    required this.itemIds,
    required this.name,
    required this.seasonType,
    required this.outfitType,
    required this.weatherRecommendation,
    required this.imagePath,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      name: json['name'],
      itemIds: List<String>.from(json['itemIds']),
      imagePath: json['imagePath'],
      outfitType: json['outfitType'],
      weatherRecommendation: json['weatherRecommendation'],
      seasonType: json['seasonType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'itemIds': itemIds,
      'imagePath': imagePath,
      'outfitType': outfitType,
      'weatherRecommendation': weatherRecommendation,
      'seasonType': seasonType,
    };
  }
}
