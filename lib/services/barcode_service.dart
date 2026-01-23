import 'dart:io';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeService {
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
