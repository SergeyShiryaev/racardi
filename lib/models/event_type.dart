enum EventType {
  cinema,
  theater,
  concert,
  travel,
  sport,
  other;

  static EventType fromName(String name) {
    return EventType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => EventType.other,
    );
  }
}

enum EventDocumentType {
  image,
  qr,
  barcode,
  pdf;

  static EventDocumentType fromName(String name) {
    return EventDocumentType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => EventDocumentType.image,
    );
  }
}
