import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double LOCATION_RADIUS = 50; // 50 метров
  static const int LOCATION_THRESHOLD = 3; // 3 открытия

  /// Получает текущие координаты
  static Future<Position?> getCurrentLocation() async {
    try {
      debugPrint('🔍 Проверяем доступность GPS...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ GPS сервис отключен');
        return null;
      }

      debugPrint('✅ GPS сервис включен');
      
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📋 Текущее разрешение: $permission');
      
      if (permission == LocationPermission.denied) {
        debugPrint('❓ Разрешение не дано, запрашиваем...');
        permission = await Geolocator.requestPermission();
        debugPrint('📊 Результат запроса: $permission');
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('🚫 Разрешение навсегда отклонено');
        return null;
      }
      
      if (permission != LocationPermission.whileInUse && 
          permission != LocationPermission.always) {
        debugPrint('❌ Недостаточные разрешения: $permission');
        return null;
      }

      debugPrint('⏳ Получаем координаты...');
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      return null;
    }
  }

  /// Вычисляет расстояние между двумя точками в метрах
  static double getDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Проверяет находимся ли мы в одном месте (расстояние <= LOCATION_RADIUS)
  static bool isSameLocation(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final distance = getDistance(lat1, lon1, lat2, lon2);
    return distance <= LOCATION_RADIUS;
  }

  /// Обновляет список мест открытия карточки
  /// Добавляет координату только если это новое место (> 50м от всех сохранённых)
  static void updateCardLocation(
    dynamic card, // DiscountCard
    double currentLat,
    double currentLon,
  ) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    debugPrint('📍 updateCardLocation "${card.title}": lat=$currentLat, lon=$currentLon');
    
    final history = card.getLocationHistory();
    debugPrint('   История содержит ${history.length} мест');
    
    // 🔹 ВСЕГДА добавляем первое место
    if (history.isEmpty) {
      card.addLocationToHistory(currentLat, currentLon, timestamp);
      debugPrint('   ✅ Добавили ПЕРВОЕ место в историю');
    } else {
      // Для остальных мест - проверяем расстояние
      final isNear = card.isNearAnySavedLocation(currentLat, currentLon);
      debugPrint('   Уже есть близкая координата (в пределах 50м)? $isNear');
      
      if (!isNear) {
        card.addLocationToHistory(currentLat, currentLon, timestamp);
        debugPrint('   ✅ Добавили новую точку в историю');
      } else {
        // Добавляем посещение к существующей точке
        card.addVisitToNearestLocation(currentLat, currentLon, timestamp);
        debugPrint('   ✅ Добавили посещение к существующей точке');
      }
    }

    card.lastOpenTimestamp = timestamp;
    card.save();
    debugPrint('   ✅ Карточка сохранена, всего мест: ${card.getLocationHistory().length}');
  }

  /// Находит и возвращает карточку, которая близка к текущему месту
  /// Вернёт карточку с наибольшим рейтингом среди близких (в пределах 50м)
  static Future<dynamic> getFrequentCardAtCurrentLocation(List<dynamic> cards) async {
    try {
      final position = await getCurrentLocation();
      if (position == null) {
        debugPrint('❌ Location не получена');
        return null;
      }

      final currentLat = position.latitude;
      final currentLon = position.longitude;
      debugPrint('📍 Текущая позиция: $currentLat, $currentLon');
      debugPrint('📦 Проверяем ${cards.length} карточек...');

      // Найдём все карточки, у которых есть сохранённая координата в пределах 50м
      final nearbyCards = <Map<String, dynamic>>[];

      for (var card in cards) {
        // Проверим каждую сохранённую координату карточки
        final history = card.getLocationHistory();
        debugPrint('   Card "${card.title}": ${history.length} сохранённых мест');
        
        for (var location in history) {
          final distance = getDistance(
            currentLat,
            currentLon,
            location['lat'] as double,
            location['lon'] as double,
          );

          print('     Место: ${location['lat']}, ${location['lon']} — расстояние: ${distance.toStringAsFixed(1)}м');

          // Если находимся в пределах 50м
          if (distance <= LOCATION_RADIUS) {
            print('     ✅ Карточка близко! Добавляем в список');
            nearbyCards.add({
              'card': card,
              'distance': distance,
              'rating': card.getOpenCount(),
            });
            break; // Берём первую попавшуюся координату карточки, чтобы не дублировать
          }
        }
      }

      if (nearbyCards.isEmpty) {
        print('❌ Нет близких карточек');
        return null;
      }

      print('✅ Найдено ${nearbyCards.length} близких карточек');

      // 🔹 Сортируем: сначала по рейтингу (больше = выше), потом по расстоянию (меньше = ближе)
      nearbyCards.sort((a, b) {
        final ratingCompare = (b['rating'] as int).compareTo(a['rating'] as int);
        if (ratingCompare != 0) return ratingCompare;
        return (a['distance'] as double).compareTo(b['distance'] as double);
      });

      final selectedCard = nearbyCards.first['card'];
      print('🎯 Возвращаем карточку: "${selectedCard.title}" (рейтинг: ${selectedCard.getOpenCount()})');
      return selectedCard;
    } catch (e) {
      print('❌ Error checking frequent card: $e');
      return null;
    }
  }
}
