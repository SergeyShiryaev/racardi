import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/discount_card.dart';

class ExportImportService {
  static const _jsonFile = 'cards.json';
  static const _imagesDir = 'images';

  // ───────────────────── EXPORT ─────────────────────

  static Future<void> exportToZip() async {
    debugPrint('🟡 EXPORT: start');

    final box = Hive.box<DiscountCard>('cards');
    debugPrint('🟡 EXPORT: cards count = ${box.length}');

    final tempDir = await getTemporaryDirectory();
    final exportDir = Directory('${tempDir.path}/export');

    if (exportDir.existsSync()) {
      exportDir.deleteSync(recursive: true);
    }
    exportDir.createSync(recursive: true);

    final imagesDir = Directory('${exportDir.path}/$_imagesDir')
      ..createSync(recursive: true);

    final List<Map<String, dynamic>> jsonCards = [];

    for (final card in box.values) {
      jsonCards.add(card.toJson());

      for (final path in [card.frontImagePath, card.backImagePath]) {
        if (path.isNotEmpty && File(path).existsSync()) {
          final name = path.split(Platform.pathSeparator).last;
          File(path).copySync('${imagesDir.path}/$name');
        }
      }
    }

    final jsonFile = File('${exportDir.path}/$_jsonFile');
    jsonFile.writeAsStringSync(jsonEncode(jsonCards));

    final archive = Archive();
    for (final entity in exportDir.listSync(recursive: true)) {
      if (entity is File) {
        final relPath = entity.path.substring(exportDir.path.length + 1);
        final bytes = entity.readAsBytesSync();
        archive.addFile(
          ArchiveFile(relPath, bytes.length, bytes),
        );
      }
    }

    final zipBytes = ZipEncoder().encodeBytes(archive);

    final params = SaveFileDialogParams(
      fileName: 'racardi.zip',
      mimeTypesFilter: ['application/zip'],
      data: zipBytes,
    );

    final savedPath = await FlutterFileDialog.saveFile(params: params);

    if (savedPath == null) {
      throw Exception('Экспорт отменён');
    }

    debugPrint('🟢 EXPORT: saved to $savedPath');
  }

  // ───────────────────── PICK ZIP ─────────────────────

  static Future<File?> pickZip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: false,
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    return File(result.files.single.path!);
  }

  // ───────────────────── IMPORT ─────────────────────

  static Future<void> importFromZip(File zipFile) async {
    debugPrint('🟡 IMPORT: start');

    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/$_imagesDir')
      ..createSync(recursive: true);

    final box = Hive.box<DiscountCard>('cards');

    /// 🔹 имя файла → новый путь
    final Map<String, String> importedImages = {};

    // 1️⃣ распаковываем картинки
    for (final file in archive) {
      if (!file.isFile) continue;

      if (file.name.startsWith('$_imagesDir/')) {
        final fileName = file.name.split('/').last;
        final outFile = File('${imagesDir.path}/$fileName');
        outFile.writeAsBytesSync(file.content);

        importedImages[fileName] = outFile.path;
      }
    }

    // 2️⃣ индекс существующих карточек по штрихкоду
    final Map<String, int> barcodeIndex = {};

    for (int i = 0; i < box.length; i++) {
      final card = box.getAt(i);
      if (card != null && card.primaryBarcode.isNotEmpty) {
        barcodeIndex[card.primaryBarcode] = i;
      }
    }

    // 3️⃣ импорт карточек (merge)
    for (final file in archive) {
      if (!file.isFile) continue;

      if (file.name == _jsonFile) {
        final json = jsonDecode(utf8.decode(file.content)) as List<dynamic>;

        for (final map in json) {
          final data = Map<String, dynamic>.from(map);

          data['frontImagePath'] =
              _fixImagePath(data['frontImagePath'], importedImages);

          data['backImagePath'] =
              _fixImagePath(data['backImagePath'], importedImages);

          final importedCard = DiscountCard.fromJson(data);
          final barcode = importedCard.primaryBarcode;

          if (barcode.isNotEmpty && barcodeIndex.containsKey(barcode)) {
            // 🔁 перезаписываем существующую
            final index = barcodeIndex[barcode]!;
            await box.putAt(index, importedCard);
          } else {
            // ➕ новая карточка
            await box.add(importedCard);
          }
        }
      }
    }

    debugPrint('🟢 IMPORT: success, cards = ${box.length}');
  }

  static Future<void> exportAndShareZip() async {
    final box = Hive.box<DiscountCard>('cards');
    final tempDir = await getTemporaryDirectory();
    final exportDir = Directory('${tempDir.path}/export_mail');

    if (exportDir.existsSync()) exportDir.deleteSync(recursive: true);
    exportDir.createSync(recursive: true);

    final imagesDir = Directory('${exportDir.path}/images')
      ..createSync(recursive: true);

    final List<Map<String, dynamic>> jsonCards = [];

    for (final card in box.values) {
      jsonCards.add(card.toJson());

      for (final path in [card.frontImagePath, card.backImagePath]) {
        if (path.isNotEmpty && File(path).existsSync()) {
          final name = path.split(Platform.pathSeparator).last;
          File(path).copySync('${imagesDir.path}/$name');
        }
      }
    }

    final jsonFile = File('${exportDir.path}/cards.json');
    jsonFile.writeAsStringSync(jsonEncode(jsonCards));

    final archive = Archive();
    for (final entity in exportDir.listSync(recursive: true)) {
      if (entity is File) {
        final relPath = entity.path.substring(exportDir.path.length + 1);
        final bytes = entity.readAsBytesSync();
        archive.addFile(ArchiveFile(relPath, bytes.length, bytes));
      }
    }

    final zipBytes = ZipEncoder().encodeBytes(archive);

    final zipFile = File('${tempDir.path}/racardi_backup.zip');
    await zipFile.writeAsBytes(zipBytes, flush: true);

    // ✅ вот правильный вызов
    await Share.shareXFiles(
      [XFile(zipFile.path)],
      subject: 'Racardi Wallet — резервная копия',
      text: 'Файл резервной копии Racardi Wallet',
    );
  }

  /// 🔹 Экспорт и отправка одной карточки
  static Future<void> exportAndShareCard(DiscountCard card) async {
    final tempDir = await getTemporaryDirectory();
    final exportDir = Directory('${tempDir.path}/export_card');

    if (exportDir.existsSync()) exportDir.deleteSync(recursive: true);
    exportDir.createSync(recursive: true);

    final imagesDir = Directory('${exportDir.path}/$_imagesDir')
      ..createSync(recursive: true);

    // JSON с одной карточкой
    final jsonCards = [card.toJson()];
    final jsonFile = File('${exportDir.path}/$_jsonFile');
    jsonFile.writeAsStringSync(jsonEncode(jsonCards));

    // Копируем картинки карточки
    for (final path in [card.frontImagePath, card.backImagePath]) {
      if (path.isNotEmpty && File(path).existsSync()) {
        final name = path.split(Platform.pathSeparator).last;
        File(path).copySync('${imagesDir.path}/$name');
      }
    }

    // Создаем ZIP
    final archive = Archive();
    for (final entity in exportDir.listSync(recursive: true)) {
      if (entity is File) {
        final relPath = entity.path.substring(exportDir.path.length + 1);
        final bytes = entity.readAsBytesSync();
        archive.addFile(ArchiveFile(relPath, bytes.length, bytes));
      }
    }

    final zipBytes = ZipEncoder().encodeBytes(archive);
    final zipFile = File('${tempDir.path}/racardi_card_${card.title}_${card.primaryBarcode}.zip');
    await zipFile.writeAsBytes(zipBytes, flush: true);

    // Отправка через системный Share
    await Share.shareXFiles(
      [XFile(zipFile.path)],
      subject: 'Racardi Wallet — карта: ${card.title}',
      text: 'Резервная копия карточки: ${card.title}',
    );
  }
  // ───────────────────── HELPERS ─────────────────────

  static String _fixImagePath(
    dynamic originalPath,
    Map<String, String> importedImages,
  ) {
    if (originalPath == null || originalPath is! String) {
      return '';
    }

    final fileName = originalPath.split('/').last;
    return importedImages[fileName] ?? '';
  }
}
