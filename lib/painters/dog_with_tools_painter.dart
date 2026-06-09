import 'package:flutter/material.dart';

class DogWithToolsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.brown;
    final bookPaint = Paint()..color = Colors.amber[700]!;
    final pagePaint = Paint()..color = Colors.white;
    final hammerPaint = Paint()..color = Colors.grey[600]!;
    final handlePaint = Paint()..color = Colors.brown[400]!;

    // 🐕 СОБАКА (ЛЕЖИТ)
    // Туловище
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.35, size.height * 0.55), width: 70, height: 50),
      paint,
    );

    // Голова
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.65, size.height * 0.45), width: 45, height: 40),
      paint,
    );

    // Уши
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.55, size.height * 0.25), width: 15, height: 20),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.75, size.height * 0.28), width: 15, height: 20),
      paint,
    );

    // Нос
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.43), 5, paint);

    // Глаз
    canvas.drawCircle(Offset(size.width * 0.60, size.height * 0.40), 4, Colors.black as Paint);

    // Передние лапы
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.48, size.height * 0.75), width: 12, height: 30),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.55, size.height * 0.75), width: 12, height: 30),
      paint,
    );

    // 🔨 МОЛОТОК В ЗУБАХ
    // Металлическая головка молотка
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width * 0.78, size.height * 0.45), width: 16, height: 12),
      hammerPaint,
    );
    // Деревянная рукоять
    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.45),
      Offset(size.width * 0.82, size.height * 0.35),
      handlePaint..strokeWidth = 3,
    );

    // 📖 ОТКРЫТАЯ КНИГА
    // Левая страница
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.50, 35, 50),
      bookPaint,
    );
    // Правая страница
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.48, 35, 50),
      pagePaint,
    );

    // Корешок книги
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.50),
      Offset(size.width * 0.12, size.height * 0.98),
      Colors.brown as Paint..strokeWidth = 2,
    );

    // Линии текста на странице
    final linePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(size.width * 0.13, size.height * 0.56 + (i * 8)),
        Offset(size.width * 0.42, size.height * 0.56 + (i * 8)),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
