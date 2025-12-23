import 'package:hive/hive.dart';

part 'discount_card.g.dart';

@HiveType(typeId: 0)
class DiscountCard extends HiveObject {
  @HiveField(0)
  String primaryBarcode;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String frontImagePath;

  @HiveField(4)
  String backImagePath;

  DiscountCard({
    required this.primaryBarcode,
    required this.title,
    required this.description,
    required this.frontImagePath,
    required this.backImagePath,
  });

  // ===============================
  // 🔹 JSON для экспорта / импорта
  // ===============================

  Map<String, dynamic> toJson() {
    return {
      'primaryBarcode': primaryBarcode,
      'title': title,
      'description': description,
      'frontImagePath': frontImagePath.split('/').last,
      'backImagePath': backImagePath.split('/').last,
    };
  }

  factory DiscountCard.fromJson(Map<String, dynamic> json) {
    return DiscountCard(
      primaryBarcode: json['primaryBarcode'],
      title: json['title'],
      description: json['description'] ?? '',
      frontImagePath: json['frontImagePath'] ?? '',
      backImagePath: json['backImagePath'] ?? '',
    );
  }
}
