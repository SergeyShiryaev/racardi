import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class EditableImage extends StatefulWidget {
  final File imageFile;

  const EditableImage({
    super.key,
    required this.imageFile,
  });

  @override
  State<EditableImage> createState() => _EditableImageState();
}

class _EditableImageState extends State<EditableImage> {
  final GlobalKey _repaintKey = GlobalKey();

  double _scale = 1.0;
  double _rotation = 0.0;
  Offset _offset = Offset.zero;

  double _startScale = 1.0;
  double _startRotation = 0.0;
  Offset _startOffset = Offset.zero;
  Offset _startFocalPoint = Offset.zero;

  ui.Image? _uiImage;

  static const double cardRatio = 1.586;

  @override
  void initState() {
    super.initState();
    _loadAndFixExif();
  }

  Future<void> _loadAndFixExif() async {
    final bytes = await widget.imageFile.readAsBytes();
    final Uint8List fixedBytes = await compute(_fixImageOrientation, bytes);

    final codec = await ui.instantiateImageCodec(fixedBytes);
    final frame = await codec.getNextFrame();

    setState(() {
      _uiImage = frame.image;
    });
  }

  // Изолят для декодирования и исправления ориентации
  static Uint8List _fixImageOrientation(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    final fixed = img.bakeOrientation(decoded);
    return Uint8List.fromList(img.encodePng(fixed));
  }

  @override
  Widget build(BuildContext context) {
    if (_uiImage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          )
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: cardRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: RepaintBoundary(
              key: _repaintKey,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.black),
                  GestureDetector(
                    onScaleStart: (details) {
                      _startScale = _scale;
                      _startRotation = _rotation;
                      _startOffset = _offset;
                      _startFocalPoint = details.focalPoint;
                    },
                    onScaleUpdate: (details) {
                      final delta = details.focalPoint - _startFocalPoint;
                      setState(() {
                        _scale = (_startScale * details.scale).clamp(1.0, 6.0);
                        // отключаем автопривязку угла
                        _rotation = _startRotation + details.rotation;
                        _offset = _startOffset + delta;
                      });
                    },
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translate(_offset.dx, _offset.dy)
                        ..rotateZ(_rotation)
                        ..scale(_scale),
                      child: RawImage(
                        image: _uiImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  IgnorePointer(child: CustomPaint(painter: _GridPainter())),
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.8),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;

      // Уменьшаем pixelRatio, чтобы не блокировать UI
      final image = await boundary.toImage(pixelRatio: 2);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/card_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Возвращаем результат родительскому экрану
      Navigator.pop(context, file);
    } catch (e) {
      debugPrint('Ошибка сохранения изображения: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить изображение')),
      );
    }
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1;

    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * i / 3, 0),
        Offset(size.width * i / 3, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 3),
        Offset(size.width, size.height * i / 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
