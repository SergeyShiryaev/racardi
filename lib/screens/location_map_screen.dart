import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/discount_card.dart';
import '../app_localizations.dart';

class LocationMapScreen extends StatefulWidget {
  final DiscountCard card;
  const LocationMapScreen({super.key, required this.card});

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  late final MapController _mapController;
  late final List<Map<String, dynamic>> _locations;
  bool _showMap = true; // Переключатель между картой и списком

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _locations = widget.card.getLocationHistory();
  }

  @override
  void dispose() {
    // НЕ вызываем _mapController.dispose() - flutter_map v6 управляет им сам
    super.dispose();
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.usageLocations}: ${widget.card.title}'),
        actions: [
          if (_locations.isNotEmpty)
            IconButton(
              icon: Icon(_showMap ? Icons.map : Icons.list),
              onPressed: () => setState(() => _showMap = !_showMap),
              tooltip: _showMap ? 'Список' : 'Карта',
            ),
        ],
      ),
      body: _locations.isEmpty
          ? Center(
              child: Text(l10n.noSavedLocations),
            )
          : _showMap
              ? _buildMap()
              : _buildListView(),
    );
  }

  Widget _buildMap() {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _locations.isNotEmpty
                  ? LatLng(
                      _locations.first['lat'] as double,
                      _locations.first['lon'] as double,
                    )
                  : const LatLng(55.7558, 37.6173),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'racardi.wallet.app',
                errorTileCallback: (tile, error, stackTrace) {
                  debugPrint('❌ TILE ERROR: $error');
                },
              ),
              MarkerLayer(
                markers: [
                  for (int i = 0; i < _locations.length; i++)
                    Marker(
                      point: LatLng(
                        _locations[i]['lat'] as double,
                        _locations[i]['lon'] as double,
                      ),
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: () => _openInOSMMap(
                          _locations[i]['lat'] as double,
                          _locations[i]['lon'] as double,
                          i + 1,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            // Счётчик посещений (верхний правый угол)
                            Builder(builder: (context) {
                              final visits = _locations[i]['visits'] as List?;
                              final count = visits?.length ?? 1;
                              if (count <= 1) return const SizedBox.shrink();
                              return Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // 📋 СПИСОК МЕСТ (справа внизу)
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            width: 280,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
              ],
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(2),
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final loc = _locations[_locations.length - 1 - index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.blue,
                    child: Text(
                      '${_locations.length - index}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  title: Text(
                    '${loc['lat']?.toStringAsFixed(4)}, ${loc['lon']?.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  subtitle: Builder(builder: (context) {
                    final visits = loc['visits'] as List?;
                    final firstVisit = visits != null && visits.isNotEmpty
                        ? visits.first as int
                        : (loc['timestamp'] as int? ?? 0);
                    final count = visits?.length ?? 1;
                      return Text(
                      '${l10n.firstVisit}: ${_formatDate(firstVisit)}  ×$count',
                      style: const TextStyle(fontSize: 9),
                    );
                  }),
                  onTap: () {
                    if (mounted) {
                      _mapController.move(
                        LatLng(loc['lat'] as double, loc['lon'] as double),
                        15,
                      );
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 25, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => _deleteLocation(_locations.length - 1 - index),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildListView() {
    final l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      itemCount: _locations.length,
      itemBuilder: (context, index) {
        final loc = _locations[_locations.length - 1 - index];
        final lat = loc['lat'] as double;
        final lon = loc['lon'] as double;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              '${_locations.length - index}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text('$lat, $lon'),
          subtitle: Builder(builder: (context) {
            final visits = loc['visits'] as List?;
            final firstVisit = visits != null && visits.isNotEmpty
                ? visits.first as int
                : (loc['timestamp'] as int? ?? 0);
            final count = visits?.length ?? 1;
            return Text('${l10n.firstVisit}: ${_formatDate(firstVisit)}  ×$count');
          }),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _openInOSMMap(lat, lon, _locations.length - index),
        );
      },
    );
  }

  void _deleteLocation(int index) {
    widget.card.removeLocationAtIndex(index);
    setState(() {
      _locations.removeAt(index);
    });
  }

  void _openInOSMMap(double lat, double lon, int index) {
    final l10n = AppLocalizations.of(context)!;
    if (!mounted) return;
    
    // Переключаемся на вид карты
    if (!_showMap) {
      setState(() => _showMap = true);
    }
    
    // Центрируем карту на выбранное место с зумом
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _mapController.move(
          LatLng(lat, lon),
          16,
        );
      }
    });
    
    // Показываем снекбар с информацией
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.location} $index: $lat, $lon'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}


