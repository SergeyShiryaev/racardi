import 'dart:io';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeService {
  /// Детект штрихкода с нескольких изображений
  static Future<String?> detectFromImages(List<File> images) async {
    final controller = MobileScannerController();

    for (final img in images) {
      // Используем путь к файлу
      final result = await controller.analyzeImage(img.path);

      // Безопасный доступ к barcodes
      if (result != null && result.barcodes.isNotEmpty) {
        return result.barcodes.first.rawValue;
      }
    }

    return null;
  }
}
