import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  /// Запрашивает все необходимые разрешения
  static Future<void> requestAllPermissions() async {
    debugPrint('📱 Запрашиваем разрешения...');
    
    try {
      // Запрашиваем сразу все разрешения
      final statuses = await [
        Permission.location,
        Permission.camera,
        Permission.storage,
      ].request();

      // Выводим статусы
      debugPrint('📍 GPS: ${statuses[Permission.location]}');
      debugPrint('📷 Камера: ${statuses[Permission.camera]}');
      debugPrint('💾 Файлы: ${statuses[Permission.storage]}');

      // Логируем каждое разрешение
      statuses.forEach((permission, status) {
        String statusStr = _getStatusString(status);
        debugPrint('   ${permission.toString()}: $statusStr');
      });
    } catch (e) {
      debugPrint('❌ Ошибка запроса разрешений: $e');
    }
  }

  /// Проверяет конкретное разрешение
  static Future<bool> hasPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  /// Открывает настройки приложения если разрешения отклонены
  static Future<void> openAppSettings() async {
    openAppSettings();
  }

  /// Преобразует статус разрешения в человеческий текст
  static String _getStatusString(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '✅ Разрешено';
      case PermissionStatus.denied:
        return '❌ Отклонено';
      case PermissionStatus.restricted:
        return '⚠️ Ограничено';
      case PermissionStatus.provisional:
        return '⏳ Временное';
      default:
        return '❓ ${status.toString()}';
    }
  }
}

