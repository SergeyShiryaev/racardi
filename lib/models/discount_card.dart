import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';

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
  String barcodeType; 

  @HiveField(6)
  String barcodeSide; 

  @HiveField(7)
  int lastOpenTimestamp; 

  @HiveField(8)
  String locationHistory;

  @HiveField(9)
  int? openCount; 

  DiscountCard({
    required this.primaryBarcode,
    required this.title,
    required this.description,
    required this.frontImagePath,
    required this.backImagePath,
    required this.barcodeType,
    this.barcodeSide = "front",
    this.lastOpenTimestamp = 0,
    this.locationHistory = '[]',
    this.openCount = 0,
  });

  int getOpenCount() => openCount ?? 0;

  void incrementOpenCount() {
    openCount = (openCount ?? 0) + 1;
  }

  bool isNearAnySavedLocation(double lat, double lon) {
    for (var location in getLocationHistory()) {
      final distance = Geolocator.distanceBetween(
          lat, lon, location['lat'] as double, location['lon'] as double);
      if (distance <= 50) { // 50 метров
        return true;
      }
    }
    return false;
  }

  List<Map<String, dynamic>> getLocationHistory() {
    try {
      final decoded = jsonDecode(locationHistory);
      return List<Map<String, dynamic>>.from(decoded ?? []);
    } catch (e) {
      return [];
    }
  }

  void removeLocationAtIndex(int index) {
    final history = getLocationHistory();
    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      locationHistory = jsonEncode(history);
      save();
    }
  }

  /// Добавляет новую точку с первым посещением
  void addLocationToHistory(double lat, double lon, int timestamp) {
    final history = getLocationHistory();
    history.add({
      'lat': lat,
      'lon': lon,
      'visits': [timestamp],
    });
    locationHistory = jsonEncode(history);
  }

  /// Добавляет посещение к ближайшей существующей точке (в пределах 50м)
  void addVisitToNearestLocation(double lat, double lon, int timestamp) {
    final history = getLocationHistory();
    double minDistance = double.infinity;
    int nearestIndex = -1;

    for (int i = 0; i < history.length; i++) {
      final distance = Geolocator.distanceBetween(
        lat, lon,
        history[i]['lat'] as double,
        history[i]['lon'] as double,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    if (nearestIndex >= 0) {
      final visits = List<dynamic>.from(history[nearestIndex]['visits'] as List? ?? []);
      visits.add(timestamp);
      history[nearestIndex]['visits'] = visits;
      locationHistory = jsonEncode(history);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryBarcode': primaryBarcode,
      'title': title,
      'description': description,
      'frontImagePath': frontImagePath.split('/').last,
      'backImagePath': backImagePath.split('/').last,
      'barcodeType': barcodeType,
      'barcodeSide': barcodeSide,
    };
  }

  factory DiscountCard.fromJson(Map<String, dynamic> json) {
    return DiscountCard(
      primaryBarcode: json['primaryBarcode'],
      title: json['title'],
      description: json['description'] ?? '',
      frontImagePath: json['frontImagePath'] ?? '',
      backImagePath: json['backImagePath'] ?? '',
      barcodeType: json['barcodeType'] ?? 'Code128', 
      barcodeSide: json['barcodeSide'] ?? 'front',
      lastOpenTimestamp: 0,
      locationHistory: '[]',
    );
  }
}
