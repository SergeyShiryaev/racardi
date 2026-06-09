import 'dart:io';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racardi/services/export_import_service.dart';
import 'package:racardi/services/location_service.dart';
import 'package:racardi/services/permissions_service.dart';

import '../models/discount_card.dart';
import '../app_localizations.dart';
import '../painters/lying_dog_painter.dart';
import '../painters/sitting_dog_painter.dart';
import '../widgets/settings_drawer.dart';
import 'add_card_screen.dart';
import 'edit_card_screen.dart';
import 'card_details_screen.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final TextEditingController searchController = TextEditingController();
  String query = '';
  bool _initialized = false;
  bool _showSearch = false; // 🔹 Флаг для показа/скрытия поиска
  
  // 🔹 Количество колонок
  int _portraitColumns = 2;
  int _landscapeColumns = 4;

  static const double cardRatio = 1.586;

  @override
  void initState() {
    super.initState();
    // Загружаем настройки в фоне (не блокируем UI)
    unawaited(_loadColumnSettings());
    // Запускаем проверку GPS в фоне (не блокируя UI)
    _checkAndOpenFrequentCard();
    // Запрашиваем разрешения в фоне после первого фрейма
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(PermissionsService.requestAllPermissions());
    });
  }

  /// Проверяет есть ли "частая карта" и открывает её (асинхронно, не блокирует UI)
  Future<void> _checkAndOpenFrequentCard() async {
    if (_initialized) return;
    _initialized = true;

    try {
      if (!mounted) return;
      
      final box = Hive.box<DiscountCard>('cards');
      debugPrint('🔍 _checkAndOpenFrequentCard: в Hive ${box.length} карточек');
      
      // 🔹 Запускаем GetLocation в фоне, не ждём здесь
      // Это позволяет списку карточек отобразиться быстро
      unawaited(
        Future.delayed(const Duration(milliseconds: 300)).then((_) async {
          try {
            final frequentCard =
                await LocationService.getFrequentCardAtCurrentLocation(
              box.values.toList(),
            );

            if (frequentCard != null && mounted) {
              debugPrint('🎯 Открываем карточку автоматически: "${frequentCard.title}"');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CardDetailsScreen(card: frequentCard),
                ),
              );
            } else {
              debugPrint('ℹ️ Нет карточки для автооткрытия');
            }
          } catch (e) {
            debugPrint('❌ Error in background GPS check: $e');
          }
        }),
      );
    } catch (e) {
      debugPrint('❌ Error in _checkAndOpenFrequentCard: $e');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// Загружает сохраненные настройки колонок
  Future<void> _loadColumnSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _portraitColumns = prefs.getInt('portraitColumns') ?? 2;
      _landscapeColumns = prefs.getInt('landscapeColumns') ?? 4;
    });
  }

  /// Сохраняет настройки колонок
  Future<void> _saveColumnSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('portraitColumns', _portraitColumns);
    await prefs.setInt('landscapeColumns', _landscapeColumns);
    debugPrint('✅ Настройки колонок сохранены: портрет=$_portraitColumns, ландшафт=$_landscapeColumns');
  }

  // 🔹 Диалог для настройки количества колонок (из SettingsDrawer)
  void showColumnsDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(l10n.columnsCount),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.portrait),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('$_portraitColumns', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Slider(
                value: _portraitColumns.toDouble(),
                min: 1,
                max: 2,
                divisions: 2,
                onChanged: (value) {
                  setStateDialog(() {
                    _portraitColumns = value.toInt();
                    _saveColumnSettings();
                  });
                  setState(() {});
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.landscape),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('$_landscapeColumns', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Slider(
                value: _landscapeColumns.toDouble(),
                min: 2,
                max: 4,
                divisions: 2,
                onChanged: (value) {
                  setStateDialog(() {
                    _landscapeColumns = value.toInt();
                    _saveColumnSettings();
                  });
                  setState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSearchText = searchController.text.isNotEmpty;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: SettingsDrawer(onShowColumnsDialog: showColumnsDialog),
      drawerEdgeDragWidth: 40,
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: searchController,
                autofocus: true,
                onChanged: (value) =>
                    setState(() => query = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: l10n.searchCards,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                style: const TextStyle(color: Colors.black),
              )
            : GestureDetector(
                onTap: () {
                  setState(() {
                    _showSearch = true;
                  });
                },
                child: Text(l10n.cards),
              ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 40,
        actions: [
          // 🔹 Иконка поиска со статусом
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  _showSearch ? Icons.close : Icons.search,
                  color: Colors.amber[300]!,
                  size: 26,
                ),
                // 🔹 Восклицательный знак, если есть текст
                if (hasSearchText)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.orange[400],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  searchController.clear();
                  query = '';
                }
              });
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCardScreen()),
        ),
      ),

      /// 🔥 Слушаем Hive для автообновления
      body: ValueListenableBuilder(
        valueListenable: Hive.box<DiscountCard>('cards').listenable(),
        builder: (context, Box<DiscountCard> box, _) {
          final cards = box.values.where((card) {
            final text = '${card.title} ${card.primaryBarcode}'.toLowerCase();
            return text.contains(query);
          }).toList();

          // 🔹 Сортируем по количеству открытий (по убыванию)
          cards.sort((a, b) => b.getOpenCount().compareTo(a.getOpenCount()));

          if (cards.isEmpty) {
            final l10n = AppLocalizations.of(context)!;
            
            final emptyMessage = query.isNotEmpty 
              ? l10n.notFound
              : l10n.noCards;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CustomPaint(
                      painter: LyingDogPainter(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emptyMessage,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          // 🔹 Определяем количество колонок в зависимости от ориентации
          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
          final crossAxisCount = isLandscape ? _landscapeColumns : _portraitColumns;

          return Stack(
            children: [
              /// 🐕 ФОН - РАЗМЫТАЯ СОБАКА (СИДИТ)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: CustomPaint(
                        painter: SittingDogPainter(),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
              ///  СПИСОК КАРТ
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: cardRatio,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 16,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Dismissible(
                      key: ValueKey(card.key),
                      direction: DismissDirection.horizontal,

                      /// ───── УДАЛЕНИЕ (влево)
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!.deleteCardConfirm),
                              content: Text(card.title),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(AppLocalizations.of(context)!.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(AppLocalizations.of(context)!.delete),
                                ),
                              ],
                            ),
                          );
                        }

                        /// ───── РЕДАКТИРОВАНИЕ (вправо)
                        if (direction == DismissDirection.startToEnd) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditCardScreen(card: card),
                            ),
                          );
                          return false;
                        }

                        return false;
                      },

                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          card.delete();
                        }
                      },

                      background: _swipeBackground(
                        icon: Icons.edit,
                        alignment: Alignment.centerLeft,
                        color: Colors.blueGrey,
                      ),
                      secondaryBackground: _swipeBackground(
                        icon: Icons.delete,
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                      ),

                      child: _CardTile(card: card),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _swipeBackground({
    required IconData icon,
    required Alignment alignment,
    required Color color,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}

class _CardTile extends StatelessWidget {
  final DiscountCard card;

  const _CardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // 👆 ОДИНАРНЫЙ ТАП — ПРОСМОТР
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CardDetailsScreen(card: card),
            ),
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 🔹 Адаптивный размер кнопок в зависимости от ширины карточки
            final cardWidth = constraints.maxWidth;
            final buttonSpacing = cardWidth < 180 
              ? 32.0 
              : cardWidth > 250 
                ? 48.0 
                : 40.0;
            
            // Размер самих кнопок и иконок
            double buttonSize;
            double iconSize;
            if (cardWidth < 180) {
              buttonSize = 32;
              iconSize = 16;
            } else if (cardWidth > 250) {
              buttonSize = 52;
              iconSize = 28;
            } else {
              buttonSize = 36;
              iconSize = 20;
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                /// ФОН КАРТЫ
                card.frontImagePath.isNotEmpty &&
                        File(card.frontImagePath).existsSync()
                    ? Image.file(
                        File(card.frontImagePath),
                        fit: BoxFit.cover,
                      )
                    : Image.asset(

                    'assets/images/empty_front.png',
                    fit: BoxFit.cover,
                  ),

            /// НИЖНЯЯ ПАНЕЛЬ С ТЕКСТОМ
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 6, 48, 6),
                    color: Colors.black.withOpacity(0.45),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          card.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card.primaryBarcode,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// ✏️ ИКОНКА РЕДАКТИРОВАНИЯ
            Positioned(
              right: 4,
              bottom: 4,
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditCardScreen(card: card),
                        ),
                      );
                    },
                    child: Icon(Icons.edit, color: Colors.white, size: iconSize),
                  ),
                ),
              ),
            ),

            /// 📤 ИКОНКА ПОДЕЛИТЬСЯ
            Positioned(
              right: buttonSpacing,
              bottom: 4,
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      try {
                        await ExportImportService.exportAndShareCard(card);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${AppLocalizations.of(context)!.errorSending}: $e')),
                        );
                      }
                    },
                    child: Icon(Icons.share, color: Colors.white, size: iconSize),
                  ),
                ),
              ),
            ),

            /// 🔥 БАТЖ КОЛИЧЕСТВА МЕСТ ОТКРЫТИЯ
            // Убрано — структура координат изменена на более логичную
              ],
            );
          },
        ),
      ),
    );
  }
}
