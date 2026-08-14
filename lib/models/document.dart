/// Общий интерфейс для всех документов, хранящихся в кошельке
/// (дисконтные карты, события с билетами и т.д.).
abstract interface class Document {
  String get id;
  DateTime get createdAt;
  DateTime get updatedAt;

  /// Текст, по которому документ можно найти через поиск.
  String get searchableText;
}
