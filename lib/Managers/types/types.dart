class MainTemp {
  final String Temp, FeelsTemp, MaxAndMin;

  const MainTemp(
      {this.Temp = "--°",
      this.FeelsTemp = "Ощущается как --°",
      this.MaxAndMin = "--° / --°"});
}

class ClothingItem {
  final String id;
  final String name;
  final String clothType;
  final String seasonType;
  final String outfitType;
  final String sizeType;
  final String weatherRecommendation;
  final String? imagePath;

  ClothingItem({
    required this.id,
    required this.name,
    required this.clothType,
    required this.seasonType,
    required this.outfitType,
    required this.sizeType,
    required this.weatherRecommendation,
    this.imagePath,
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
