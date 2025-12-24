import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/discount_card.dart';

class ExportImportService {
  static const _jsonFile = 'cards.json';
  static const _imagesDir = 'images';
  static const _cardsDir = 'cards';

  // ───────────────────── EXPORT ─────────────────────

  static Future<void> exportToZip() async {
    final box = Hive.box<DiscountCard>('cards');

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

    File('${exportDir.path}/$_jsonFile')
        .writeAsStringSync(jsonEncode(jsonCards));

    final archive = Archive();
    for (final entity in exportDir.listSync(recursive: true)) {
      if (entity is File) {
        final relPath = entity.path.substring(exportDir.path.length + 1);
        archive.addFile(
          ArchiveFile(relPath, entity.lengthSync(), entity.readAsBytesSync()),
        );
      }
    }

    final zipBytes = ZipEncoder().encodeBytes(archive);

    final savedPath = await FlutterFileDialog.saveFile(
      params: SaveFileDialogParams(
        fileName: 'racardi.zip',
        mimeTypesFilter: ['application/zip'],
        data: zipBytes,
      ),
    );

    if (savedPath == null) {
      throw Exception('Export cancelled');
    }
  }

  // ───────────────────── PICK ZIP ─────────────────────

  static Future<File?> pickZip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    return result?.files.single.path != null
        ? File(result!.files.single.path!)
        : null;
  }

  // ───────────────────── IMPORT ─────────────────────

  static Future<void> importFromZip(File zipFile) async {
    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    final appDir = await getApplicationDocumentsDirectory();
    final cardsDir = Directory('${appDir.path}/$_cardsDir')
      ..createSync(recursive: true);

    final box = Hive.box<DiscountCard>('cards');

    /// fileName → new permanent path
    final Map<String, String> importedImages = {};

    // 1️⃣ extract images → documents/cards
    for (final file in archive) {
      if (!file.isFile) continue;
      if (!file.name.startsWith('$_imagesDir/')) continue;

      final originalName = file.name.split('/').last;
      final newPath =
          '${cardsDir.path}/img_${DateTime.now().millisecondsSinceEpoch}_$originalName';

      final outFile = File(newPath);
      outFile.writeAsBytesSync(file.content);

      importedImages[originalName] = outFile.path;
    }

    // 2️⃣ index existing cards by barcode
    final Map<String, int> barcodeIndex = {};
    for (int i = 0; i < box.length; i++) {
      final card = box.getAt(i);
      if (card != null && card.primaryBarcode.isNotEmpty) {
        barcodeIndex[card.primaryBarcode] = i;
      }
    }

    // 3️⃣ import / merge cards
    for (final file in archive) {
      if (!file.isFile || file.name != _jsonFile) continue;

      final List<dynamic> json = jsonDecode(utf8.decode(file.content));

      for (final map in json) {
        final data = Map<String, dynamic>.from(map);

        data['frontImagePath'] =
            _fixImagePath(data['frontImagePath'], importedImages);
        data['backImagePath'] =
            _fixImagePath(data['backImagePath'], importedImages);

        final importedCard = DiscountCard.fromJson(data);
        final barcode = importedCard.primaryBarcode;

        if (barcode.isNotEmpty && barcodeIndex.containsKey(barcode)) {
          await box.putAt(barcodeIndex[barcode]!, importedCard);
        } else {
          await box.add(importedCard);
        }
      }
    }
  }

  // ───────────────────── SHARE FULL ZIP ─────────────────────

  static Future<void> exportAndShareZip() async {
    final box = Hive.box<DiscountCard>('cards');
    final tempDir = await getTemporaryDirectory();
    final exportDir = Directory('${tempDir.path}/export_mail');

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

    File('${exportDir.path}/$_jsonFile')
        .writeAsStringSync(jsonEncode(jsonCards));

    final archive = Archive();
    for (final entity in exportDir.listSync(recursive: true)) {
      if (entity is File) {
        final relPath = entity.path.substring(exportDir.path.length + 1);
        archive.addFile(
          ArchiveFile(relPath, entity.lengthSync(), entity.readAsBytesSync()),
        );
      }
    }

    final zipFile = File('${tempDir.path}/racardi_backup.zip')
      ..writeAsBytesSync(ZipEncoder().encodeBytes(archive));

    await Share.shareXFiles(
      [XFile(zipFile.path)],
      subject: 'Racardi Wallet — backup',
      text: 'Racardi Wallet backup file',
    );
  }

  // ───────────────────── SHARE SINGLE CARD ─────────────────────

  static Future<void> exportAndShareCard(DiscountCard card) async {
    final tempDir = await getTemporaryDirectory();
    final exportDir = Directory('${tempDir.path}/export_card');

    if (exportDir.existsSync()) {
      exportDir.deleteSync(recursive: true);
    }
    exportDir.createSync(recursive: true);

    final imagesDir = Directory('${exportDir.path}/$_imagesDir')
      ..createSync(recursive: true);

    File('${exportDir.path}/$_jsonFile')
        .writeAsStringSync(jsonEncode([card.toJson()]));

    for (final path in [card.frontImagePath, card.backImagePath]) {
      if (path.isNotEmpty && File(path).existsSync()) {
        final name = path.split(Platform.pathSeparator).last;
        File(path).copySync('${imagesDir.path}/$name');
      }
    }

    final archive = Archive();
    for (final entity in exportDir.listSync(recursive: true)) {
      if (entity is File) {
        final relPath = entity.path.substring(exportDir.path.length + 1);
        archive.addFile(
          ArchiveFile(relPath, entity.lengthSync(), entity.readAsBytesSync()),
        );
      }
    }

    final zipFile = File(
      '${tempDir.path}/racardi_card_${card.primaryBarcode}.zip',
    )..writeAsBytesSync(ZipEncoder().encodeBytes(archive));

    await Share.shareXFiles(
      [XFile(zipFile.path)],
      subject: 'Racardi Wallet — ${card.title}',
      text: 'Card backup: ${card.title}',
    );
  }

  // ───────────────────── HELPERS ─────────────────────

  static String _fixImagePath(
    dynamic originalPath,
    Map<String, String> importedImages,
  ) {
    if (originalPath is! String || originalPath.isEmpty) return '';
    final fileName = originalPath.split('/').last;
    return importedImages[fileName] ?? '';
  }
}
