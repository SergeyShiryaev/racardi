import 'package:flutter/material.dart';

import '../app_localizations.dart';
import '../models/event_type.dart';

String eventTypeLabel(AppLocalizations l10n, EventType type) {
  switch (type) {
    case EventType.cinema:
      return l10n.eventTypeCinema;
    case EventType.theater:
      return l10n.eventTypeTheater;
    case EventType.concert:
      return l10n.eventTypeConcert;
    case EventType.travel:
      return l10n.eventTypeTravel;
    case EventType.sport:
      return l10n.eventTypeSport;
    case EventType.other:
      return l10n.eventTypeOther;
  }
}

IconData eventTypeIcon(EventType type) {
  switch (type) {
    case EventType.cinema:
      return Icons.movie_outlined;
    case EventType.theater:
      return Icons.theater_comedy_outlined;
    case EventType.concert:
      return Icons.music_note_outlined;
    case EventType.travel:
      return Icons.flight_takeoff;
    case EventType.sport:
      return Icons.sports_soccer;
    case EventType.other:
      return Icons.event_outlined;
  }
}
