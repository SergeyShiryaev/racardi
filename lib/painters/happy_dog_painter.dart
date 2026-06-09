import 'package:flutter/material.dart';

class HappyDogPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Цвета
    final bodyPaint = Paint()
      ..color = const Color(0xFF8B6F47)
      ..style = PaintingStyle.fill;

    final spotPaint = Paint()
      ..color = const Color(0xFF5D4E37)
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final pinkPaint = Paint()
      ..color = Colors.pink
      ..style = PaintingStyle.fill;

    // Масштабирование всего
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 🐕 ГОЛОВА (большой круг)
    canvas.drawCircle(Offset(centerX, centerY - 40), 50, bodyPaint);

    // 🟤 ПЯТНО НА ГОЛОВЕ
    canvas.drawCircle(Offset(centerX + 30, centerY - 60), 20, spotPaint);

    // 👂 УШИ (два треугольника)
    final leftEarPath = Path()
      ..moveTo(centerX - 35, centerY - 70)
      ..lineTo(centerX - 30, centerY - 120)
      ..lineTo(centerX - 15, centerY - 70)
      ..close();
    canvas.drawPath(leftEarPath, bodyPaint);

    final rightEarPath = Path()
      ..moveTo(centerX + 35, centerY - 70)
      ..lineTo(centerX + 30, centerY - 120)
      ..lineTo(centerX + 15, centerY - 70)
      ..close();
    canvas.drawPath(rightEarPath, bodyPaint);

    // 😊 ГЛАЗА (белки)
    canvas.drawCircle(Offset(centerX - 20, centerY - 50), 8, whitePaint);
    canvas.drawCircle(Offset(centerX + 20, centerY - 50), 8, whitePaint);

    // 😊 ЗРАЧКИ
    canvas.drawCircle(Offset(centerX - 18, centerY - 50), 5, blackPaint);
    canvas.drawCircle(Offset(centerX + 22, centerY - 50), 5, blackPaint);

    // 😊 БЛИКИ В ГЛАЗАХ
    canvas.drawCircle(Offset(centerX - 16, centerY - 52), 2, whitePaint);
    canvas.drawCircle(Offset(centerX + 24, centerY - 52), 2, whitePaint);

    // 👃 НОС (розовый)
    canvas.drawCircle(Offset(centerX, centerY - 20), 8, pinkPaint);

    // 😄 УЛЫБКА (дуга)
    final smilePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerX, centerY), width: 30, height: 20),
      0,
      3.14,
      false,
      smilePaint,
    );

    // 👅 ЯЗЫЧОК (маленький красный)
    canvas.drawCircle(Offset(centerX, centerY + 5), 6, pinkPaint);

    // 📦 ТУЛОВИЩЕ (большой овал)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, centerY + 70), width: 80, height: 100),
      bodyPaint,
    );

    // 🟤 ПЯТНО НА ТУЛОВИЩЕ
    canvas.drawCircle(Offset(centerX + 15, centerY + 60), 25, spotPaint);

    // 🦴 ПЕРЕДНЯЯ ЛЕВАЯ ЛАПА
    canvas.drawRect(
      Rect.fromLTWH(centerX - 40, centerY + 140, 20, 60),
      bodyPaint,
    );

    // 🦴 ПЕРЕДНЯЯ ПРАВАЯ ЛАПА
    canvas.drawRect(
      Rect.fromLTWH(centerX + 20, centerY + 140, 20, 60),
      bodyPaint,
    );

    // 🦴 ЗАДНЯЯ ЛЕВАЯ ЛАПА
    canvas.drawRect(
      Rect.fromLTWH(centerX - 50, centerY + 130, 15, 70),
      spotPaint,
    );

    // 🦴 ЗАДНЯЯ ПРАВАЯ ЛАПА
    canvas.drawRect(
      Rect.fromLTWH(centerX + 35, centerY + 130, 15, 70),
      spotPaint,
    );

    // 💫 ХВОСТ (волнистая линия)
    final tailPaint = Paint()
      ..color = const Color(0xFF8B6F47)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final tailPath = Path();
    tailPath.moveTo(centerX + 40, centerY + 50);
    tailPath.quadraticBezierTo(centerX + 80, centerY + 20, centerX + 100, centerY - 30);
    tailPath.quadraticBezierTo(centerX + 110, centerY - 60, centerX + 90, centerY - 80);
    canvas.drawPath(tailPath, tailPaint);

    // 🐾 ПОДУШЕЧКИ НА ЛАПАХ
    final pawPaint = Paint()
      ..color = const Color(0xFFD4A574)
      ..style = PaintingStyle.fill;

    // Левая передняя лапа
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX - 30, centerY + 200), width: 18, height: 14),
      pawPaint,
    );
    // Правая передняя лапа
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + 30, centerY + 200), width: 18, height: 14),
      pawPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
