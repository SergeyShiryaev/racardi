import 'dart:io';

import 'package:flutter/material.dart';

import '../app_localizations.dart';
import '../models/card_event.dart';
import '../models/event_document.dart';
import '../services/event_repository.dart';
import 'add_edit_event_screen.dart';
import 'event_type_labels.dart';

class EventDetailsScreen extends StatefulWidget {
  final CardEvent event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final _repository = EventRepository();

  void _openFullscreen(EventDocument document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _DocumentViewerScreen(document: document),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteEventConfirm),
        content: Text(widget.event.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.delete(widget.event.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = widget.event;
    final dateStr =
        '${event.startAt.day.toString().padLeft(2, '0')}.${event.startAt.month.toString().padLeft(2, '0')}.${event.startAt.year}'
        ' ${event.startAt.hour.toString().padLeft(2, '0')}:${event.startAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditEventScreen(event: event),
                ),
              );
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(eventTypeIcon(event.eventType)),
              const SizedBox(width: 8),
              Text(eventTypeLabel(l10n, event.eventType)),
            ],
          ),
          const SizedBox(height: 8),
          Text(dateStr, style: Theme.of(context).textTheme.titleMedium),
          if (event.description != null && event.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(event.description!),
          ],
          const SizedBox(height: 24),
          Text(l10n.addDocument, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (event.documents.isEmpty)
            Text(l10n.noDocuments)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: event.documents.length,
              itemBuilder: (context, index) {
                final document = event.documents[index];
                return GestureDetector(
                  onTap: () => _openFullscreen(document),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(document.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          if (event.documents.isNotEmpty) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _openFullscreen(event.documents.first),
              icon: const Icon(Icons.qr_code),
              label: Text(l10n.showQr),
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentViewerScreen extends StatelessWidget {
  final EventDocument document;

  const _DocumentViewerScreen({required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(File(document.path)),
        ),
      ),
    );
  }
}
