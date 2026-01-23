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

  @HiveField(5)
  String barcodeType; // 🔹 новое поле: "Code39", "Code128" и т.д.

  DiscountCard({
    required this.primaryBarcode,
    required this.title,
    required this.description,
    required this.frontImagePath,
    required this.backImagePath,
    required this.barcodeType,
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
      'barcodeType': barcodeType,
    };
  }

  factory DiscountCard.fromJson(Map<String, dynamic> json) {
    return DiscountCard(
      primaryBarcode: json['primaryBarcode'],
      title: json['title'],
      description: json['description'] ?? '',
      frontImagePath: json['frontImagePath'] ?? '',
      backImagePath: json['backImagePath'] ?? '',
      barcodeType: json['barcodeType'] ?? 'Code128', // дефолтный тип
    );
  }
}
