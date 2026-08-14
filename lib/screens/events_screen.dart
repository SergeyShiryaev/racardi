import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../app_localizations.dart';
import '../models/card_event.dart';
import '../painters/happy_dog_painter.dart';
import 'add_edit_event_screen.dart';
import 'event_details_screen.dart';
import 'event_type_labels.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.events),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditEventScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<CardEvent>('events').listenable(),
        builder: (context, Box<CardEvent> box, _) {
          final events = box.values.toList()
            ..sort((a, b) => a.startAt.compareTo(b.startAt));

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(painter: HappyDogPainter()),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noEvents,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final dateStr =
                  '${event.startAt.day.toString().padLeft(2, '0')}.${event.startAt.month.toString().padLeft(2, '0')}.${event.startAt.year}'
                  ' ${event.startAt.hour.toString().padLeft(2, '0')}:${event.startAt.minute.toString().padLeft(2, '0')}';

              return ListTile(
                leading: CircleAvatar(
                  child: Icon(eventTypeIcon(event.eventType)),
                ),
                title: Text(
                  event.title,
                  style: event.isPast
                      ? TextStyle(color: Theme.of(context).disabledColor)
                      : null,
                ),
                subtitle: Text(dateStr),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailsScreen(event: event),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
