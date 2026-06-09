import 'dart:io';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeService {
  /// Получает штрихкод с информацией о позиции
  static Future<Map<String, dynamic>?> detectBarcodeWithBounds(File image) async {
    final controller = MobileScannerController();
    final result = await controller.analyzeImage(image.path);

    if (result != null && result.barcodes.isNotEmpty) {
      final barcode = result.barcodes.first;
      final rawValue = barcode.rawValue ?? '';
      final format = barcode.format.name;

      if (rawValue.isNotEmpty) {
        return {
          'value': rawValue,
          'format': format,
          'hasBarcode': true,
        };
      }
    }
    return null;
  }

  static Future<Map<String, String>?> detectFromImage(File image) async {
    final controller = MobileScannerController();
    final result = await controller.analyzeImage(image.path);

    if (result != null && result.barcodes.isNotEmpty) {
      final barcode = result.barcodes.first;
      final rawValue = barcode.rawValue ?? '';
      final format = barcode.format.name;

      if (rawValue.isNotEmpty) {
        return {
          'value': rawValue,
          'format': format,
        };
      }
    }
    return null;
  }

  /// Определяет, на какой стороне находится штрихкод
  /// Возвращает: {'value': '...', 'format': '...', 'side': 'front'|'back'|'both'}
  static Future<Map<String, dynamic>?> detectBarcodeWithSide({
    required File frontImage,
    required File backImage,
  }) async {
    // Проверяем переднюю сторону
    final frontResult = await detectFromImage(frontImage);
    // Проверяем обратную сторону
    final backResult = await detectFromImage(backImage);

    if (frontResult != null && backResult != null) {
      // Штрихкод на обеих сторонах
      return {
        ...frontResult,
        'side': 'both',
      };
    } else if (frontResult != null) {
      return {
        ...frontResult,
        'side': 'front',
      };
    } else if (backResult != null) {
      return {
        ...backResult,
        'side': 'back',
      };
    }

    return null;
  }

  @Deprecated('Use detectBarcodeWithSide instead')
  static Future<Map<String, String>?> detectFromImages(List<File> images) async {
    final controller = MobileScannerController();

    for (final img in images) {
      final result = await controller.analyzeImage(img.path);

      if (result != null && result.barcodes.isNotEmpty) {
        final barcode = result.barcodes.first;
        final rawValue = barcode.rawValue ?? '';
        final format = barcode.format.name; // формат как строка

        if (rawValue.isNotEmpty) {
          return {
            'value': rawValue,
            'format': format,
          };
        }
      }
    }

    return null;
  }
}
