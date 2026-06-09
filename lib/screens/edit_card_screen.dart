import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../models/discount_card.dart';
import '../painters/dog_back_painter.dart';
import '../services/barcode_service.dart';
import '../widgets/editable_image_widget.dart';
import '../app_localizations.dart';
import 'barcode_scanner_screen.dart';
import 'package:path_provider/path_provider.dart';

class EditCardScreen extends StatefulWidget {
  final DiscountCard card;
  const EditCardScreen({super.key, required this.card});

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final ImagePicker picker = ImagePicker();
  late TextEditingController titleController;
  late TextEditingController barcodeController;

  late File front;
  late File back;
  late String barcodeSide; // 🔹 сторона штрихкода

  static const double cardRatio = 1.586;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.card.title);
    barcodeController = TextEditingController(text: widget.card.primaryBarcode);
    
    // 🔹 Слушаем изменения текста для обновления UI
    titleController.addListener(() => setState(() {}));
    barcodeController.addListener(() => setState(() {}));
    
    barcodeSide = widget.card.barcodeSide; // 🔹 загружаем сторону из карты
    front = File(widget.card.frontImagePath);
    back = File(widget.card.backImagePath);
  }

  @override
  void dispose() {
    titleController.dispose();
    barcodeController.dispose();
    super.dispose();
  }

  Future<File> _saveImagePermanently(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/cards');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final newPath =
        '${imagesDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';

    return file.copy(newPath);
  }

  Future<File?> pickAndEditImage(ImageSource source, File file) async {
    final XFile? img = await picker.pickImage(source: source, imageQuality: 90);
    if (img == null) return null;

    final File newFile = File(img.path);
    final File? edited = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => EditableImage(imageFile: newFile)),
    );
    return edited ?? newFile;
  }

  Future<void> editFront(ImageSource source) async {
    final File? result = await pickAndEditImage(source, front);
    if (result != null) {
      setState(() => front = result);
    }
  }

  Future<void> editBack(ImageSource source) async {
    final File? result = await pickAndEditImage(source, back);
    if (result != null) {
      setState(() => back = result);
    }
  }

  void chooseSource(bool isFront) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.camera),
              onTap: () {
                Navigator.pop(context);
                isFront
                    ? editFront(ImageSource.camera)
                    : editBack(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: Text(l10n.gallery),
              onTap: () {
                Navigator.pop(context);
                isFront
                    ? editFront(ImageSource.gallery)
                    : editBack(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPreview({required File image, required bool isFront}) {
    return GestureDetector(
      onTap: () async {
        // 🔹 Короткий тап - сразу открываем камеру
        isFront
            ? await editFront(ImageSource.camera)
            : await editBack(ImageSource.camera);
      },
      onLongPress: () {
        // 🔹 Длительное нажатие - показываем меню выбора
        chooseSource(isFront);
      },
      child: AspectRatio(
        aspectRatio: cardRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image.existsSync()
              ? Image.file(image, fit: BoxFit.cover)
              : Container(
                  color: Colors.grey[200],
                  child: isFront
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: SvgPicture.asset('assets/images/dog_sitting.svg'),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Загрузи карту',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                                                        SizedBox(
                              width: 100,
                              height: 100,
                              child: SvgPicture.asset('assets/images/dog_sitting.svg'),
                            ),

                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CustomPaint(
                                painter: DogBackPainter(),
                                size: const Size(80, 80),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'загрузи свою карту',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
        ),
      ),
    );
  }

  Future<void> scanBarcode() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (scannedCode != null) {
      setState(() {
        barcodeController.text = scannedCode;
      });
    }
  }

Future<void> saveCard() async {
  try {
    final l10n = AppLocalizations.of(context)!;
    String? barcode = barcodeController.text.trim().isNotEmpty
        ? barcodeController.text.trim()
        : null;

    String? barcodeType = widget.card.barcodeType; // сохраняем текущий тип

    // 🔹 Если поле штрихкода пустое, пробуем автодетект с изображений
    if (barcode == null || barcode.isEmpty) {
      final detected = await BarcodeService.detectBarcodeWithSide(
        frontImage: front,
        backImage: back,
      );

      if (detected != null) {
        barcode = detected['value'];
        barcodeType = detected['format']; // только при автодетекте
        barcodeSide = detected['side'] ?? 'front'; // 🔹 обновляем сторону
      }
    }

    // 🔹 Если всё ещё нет штрихкода, показываем ошибку
    if (barcode == null || barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.barcodeFailed)),
      );
      return;
    }

    File finalFront = front;
    File finalBack = back;

    // 🔹 Если изображения находятся вне папки /cards/, сохраняем их
    if (!front.path.contains('/cards/')) {
      finalFront = await _saveImagePermanently(front);
      debugPrint('✅ Front image re-saved: ${finalFront.path}');
    }

    if (!back.path.contains('/cards/')) {
      finalBack = await _saveImagePermanently(back);
      debugPrint('✅ Back image re-saved: ${finalBack.path}');
    }

    // 🔹 Сохраняем карту с информацией о стороне штрихкода
    widget.card
      ..title = titleController.text
      ..primaryBarcode = barcode
      ..barcodeType = barcodeType!
      ..barcodeSide = barcodeSide // 🔹 сохраняем сторону
      ..frontImagePath = finalFront.path
      ..backImagePath = finalBack.path
      ..save();

    debugPrint('✅ Card updated and saved');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cardUpdated)),
      );
      Navigator.pop(context);
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error saving card: $e');
    debugPrint('❌ Stack trace: $stackTrace');
    final l10n = AppLocalizations.of(context)!;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.cardSaveFailed}: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editCard)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Название'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'[а-яА-ЯёЁa-zA-Z0-9\s]')),
            ],
          ),
          const SizedBox(height: 10),
          Text(l10n.frontSide),
          const SizedBox(height: 6),
          buildPreview(image: front, isFront: true),
          const SizedBox(height: 10),
          Text(l10n.backSide),
          const SizedBox(height: 6),
          buildPreview(image: back, isFront: false),
          const SizedBox(height: 10),
          TextField(
            controller: barcodeController,
            decoration: InputDecoration(
              labelText: 'Штрихкод',
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: scanBarcode,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 🔹 Auto-detect barcode button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_fix_high),
              label: Text(l10n.autoDetectBarcode),
              onPressed: () async {
                final detected = await BarcodeService.detectBarcodeWithSide(
                  frontImage: front,
                  backImage: back,
                );

                if (detected != null) {
                  setState(() {
                    barcodeController.text = detected['value'] ?? '';
                    barcodeSide = detected['side'] ?? 'front';
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.barcodeDetected),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.barcodeNotFound),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.barcodeLocation),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text(l10n.front),
                selected: barcodeSide == 'front',
                onSelected: (_) => setState(() => barcodeSide = 'front'),
              ),
              FilterChip(
                label: Text(l10n.back),
                selected: barcodeSide == 'back',
                onSelected: (_) => setState(() => barcodeSide = 'back'),
              ),
              FilterChip(
                label: Text(l10n.both),
                selected: barcodeSide == 'both',
                onSelected: (_) => setState(() => barcodeSide = 'both'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: saveCard, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
