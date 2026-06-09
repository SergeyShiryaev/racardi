import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/discount_card.dart';
import '../painters/dog_back_painter.dart';
import '../services/barcode_service.dart';
import '../services/location_service.dart';
import '../app_localizations.dart';
import 'location_map_screen.dart';

class CardDetailsScreen extends StatefulWidget {
  final DiscountCard card;
  const CardDetailsScreen({super.key, required this.card});

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  late final List<Widget> _views;
  late final PageController _pageController;
  late String _barcodeSide;
  double _pageOffset = 0.0;
  
  final Map<int, TransformationController> _transformControllers = {};
  // Информация о штрихкоде для каждого изображения
  final Map<int, bool> _hasBarcodeInfo = {};

  @override
  void initState() {
    super.initState();
    
    // 🔹 Инкрементируем счетчик открытий для рейтинга (безопасно)
    widget.card.incrementOpenCount();
    widget.card.save();
    
    // Сохраняем GPS координаты открытия карты (асинхронно)
    Future.microtask(() => _recordCardLocationOpen());
    
    _barcodeSide = widget.card.barcodeSide;

    _pageController = PageController()
      ..addListener(() {
        setState(() {
          _pageOffset = _pageController.page ?? 0.0;
        });
      });

    _views = [];
    
    // Строим views асинхронно
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildViews();
    });
  }

  /// Сохраняет координаты открытия карты
  Future<void> _recordCardLocationOpen() async {
    try {
      debugPrint('🔍 Получаем текущие координаты для "${widget.card.title}"');
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        debugPrint('📍 Координаты получены: ${position.latitude}, ${position.longitude}');
        LocationService.updateCardLocation(
          widget.card,
          position.latitude,
          position.longitude,
        );
      } else {
        debugPrint('❌ Не удалось получить координаты (GPS отключен или нет разрешения)');
      }
    } catch (e) {
      debugPrint('❌ Error recording card location: $e');
    }
  }

  Future<void> _buildViews() async {
    final l10n = AppLocalizations.of(context)!;
    
    int imageIndex = 0;

    // 1️⃣ Front image with zoom
    if (widget.card.frontImagePath.isNotEmpty &&
        File(widget.card.frontImagePath).existsSync()) {
      final controller = TransformationController();
      _transformControllers[imageIndex] = controller;
      
      // Анализируем штрихкод на переднем изображении
      final hasBarcode = await _analyzeBarcodeBounds(
        File(widget.card.frontImagePath),
      );
      _hasBarcodeInfo[imageIndex] = hasBarcode;

      final viewWidget = _buildZoomableImageWithLabel(
        File(widget.card.frontImagePath),
        l10n.frontSide,
        controller,
      );
      _views.add(viewWidget);
      imageIndex++;
    }

    // 2️⃣ Back image with zoom (или собака со спины как дефолт)
    if (widget.card.backImagePath.isNotEmpty &&
        File(widget.card.backImagePath).existsSync()) {
      final controller = TransformationController();
      _transformControllers[imageIndex] = controller;
      
      // Анализируем штрихкод на обратном изображении
      final hasBarcode = await _analyzeBarcodeBounds(
        File(widget.card.backImagePath),
      );
      _hasBarcodeInfo[imageIndex] = hasBarcode;

      final viewWidget = _buildZoomableImageWithLabel(
        File(widget.card.backImagePath),
        l10n.backSide,
        controller,
      );
      _views.add(viewWidget);
      imageIndex++;
    } else {
      // 🐕 Дефолт - собака со спины
      final controller = TransformationController();
      _transformControllers[imageIndex] = controller;
      _hasBarcodeInfo[imageIndex] = false;

      final viewWidget = Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CustomPaint(
                painter: DogBackPainter(),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.backSide,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
      _views.add(viewWidget);
      imageIndex++;
    }

    // 3️⃣ Description
    if (widget.card.description.isNotEmpty) {
      _views.add(
        Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Text(
              widget.card.description,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    if (_views.isEmpty) {
      _views.add(Center(child: Text(l10n.noImages)));
    }

    if (mounted) {
      setState(() {});
      _jumpToBarcodeSide();
    }
  }

  /// Анализирует изображение и возвращает есть ли штрихкод
  Future<bool> _analyzeBarcodeBounds(File imageFile) async {
    try {
      final result = await BarcodeService.detectBarcodeWithBounds(imageFile);
      return result != null;
    } catch (e) {
      debugPrint('Error analyzing barcode bounds: $e');
    }
    return false;
  }

  void _jumpToBarcodeSide() {
    int targetIndex = 0;
    if (_barcodeSide == 'back' && widget.card.backImagePath.isNotEmpty) {
      targetIndex = 1; // Back image is second
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(targetIndex);
      }
    });
  }

  Widget _buildZoomableImageWithLabel(
    File imageFile,
    String label,
    TransformationController controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        InteractiveViewer(
          transformationController: controller,
          boundaryMargin: const EdgeInsets.all(500),
          minScale: 0.5,
          maxScale: 10.0,
          panEnabled: true,
          scaleEnabled: true,
          clipBehavior: Clip.none,
          child: GestureDetector(
            onDoubleTap: () {
              // 🔹 Двойной тап - сбросить зум
              controller.value = Matrix4.identity();
            },
            child: Image.file(
              imageFile,
              fit: BoxFit.contain,
            ),
          ),
        ),
        // 🔹 Подсказка в нижнем левом углу
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.7 * 255).round()),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              l10n.zoomHint,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
        // 🔹 Название в верхнем правом углу
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.7 * 255).round()),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _transformControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasBackground = widget.card.frontImagePath.isNotEmpty &&
        File(widget.card.frontImagePath).existsSync();
    
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'map') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LocationMapScreen(card: widget.card),
                  ),
                );
              } else {
                setState(() => _barcodeSide = value);
                _jumpToBarcodeSide();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'front',
                child: Text(l10n.barcodeFront),
                enabled: widget.card.frontImagePath.isNotEmpty,
              ),
              PopupMenuItem(
                value: 'back',
                child: Text(l10n.barcodeBack),
                enabled: widget.card.backImagePath.isNotEmpty,
              ),
              PopupMenuItem(
                value: 'both',
                child: Text(l10n.barcodeBoth),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'map',
                child: Text(l10n.usageLocations),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🖼 Background with parallax
          if (hasBackground)
            ClipRect(
              child: Transform.translate(
                offset: Offset(_pageOffset * 20, 0),
                child: Image.file(
                  File(widget.card.frontImagePath),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(color: Theme.of(context).colorScheme.surface),

          /// ☁️ Frosted overlay + blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha((0.45 * 255).round()),
                    Colors.white.withAlpha((0.80 * 255).round()),
                  ],
                ),
              ),
            ),
          ),

          /// 📄 PageView with cards (fullscreen zoom)
          PageView.builder(
            controller: _pageController,
            itemCount: _views.length,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return _views[index];
            },
          ),
        ],
      ),
    );
  }
}
