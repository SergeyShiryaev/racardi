import 'package:flutter/material.dart';

/// 🐕 Та же собака - сидит лицом (для фона списка)
class SittingDogPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outlinePaint = Paint()
      ..color = Colors.amber[900]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final bodyPaint = Paint()
      ..color = Colors.amber[400]!
      ..style = PaintingStyle.fill;

    final headPaint = Paint()
      ..color = Colors.amber[300]!
      ..style = PaintingStyle.fill;

    final darkPaint = Paint()
      ..color = Colors.brown[900]!
      ..style = PaintingStyle.fill;

    // 🔹 ТУЛОВИЩЕ СИДЯЩЕЙ СОБАКИ (вертикальное)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.60),
        width: size.width * 0.35,
        height: size.width * 0.50,
      ),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.60),
        width: size.width * 0.35,
        height: size.width * 0.50,
      ),
      outlinePaint,
    );

    // 🔹 ПУШИСТАЯ ГРУДЬ (светлая)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.65),
        width: size.width * 0.20,
        height: size.width * 0.30,
      ),
      Paint()..color = Colors.amber[100]!,
    );

    // 🔹 ГОЛОВА - БОЛЬШАЯ И КРУГЛАЯ (сидит - голова выше)
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.28),
      size.width * 0.14,
      headPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.28),
      size.width * 0.14,
      outlinePaint,
    );

    // 🔹 МОРДА (спереди)
    final snout = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.38),
      width: size.width * 0.12,
      height: size.width * 0.10,
    );
    canvas.drawOval(snout, Paint()..color = Colors.amber[200]!);

    // 🔹 БОЛЬШОЙ СОБАЧИЙ НОС
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.36),
      size.width * 0.045,
      darkPaint,
    );

    // 🔹 ДОБРЫЙ ГЛАЗ 1
    canvas.drawCircle(
      Offset(size.width * 0.40, size.height * 0.22),
      size.width * 0.055,
      Paint()..color = Colors.amber[100]!,
    );
    canvas.drawCircle(
      Offset(size.width * 0.40, size.height * 0.22),
      size.width * 0.055,
      outlinePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.41, size.height * 0.21),
      size.width * 0.028,
      darkPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.19),
      size.width * 0.012,
      Paint()..color = Colors.white,
    );

    // 🔹 ДОБРЫЙ ГЛАЗ 2
    canvas.drawCircle(
      Offset(size.width * 0.60, size.height * 0.22),
      size.width * 0.055,
      Paint()..color = Colors.amber[100]!,
    );
    canvas.drawCircle(
      Offset(size.width * 0.60, size.height * 0.22),
      size.width * 0.055,
      outlinePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.59, size.height * 0.21),
      size.width * 0.028,
      darkPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.19),
      size.width * 0.012,
      Paint()..color = Colors.white,
    );

    // 🔹 ДВА ДЛИННЫХ УХА (падают по сторонам)
    // Левое ухо
    final earLeft = Path()
      ..moveTo(size.width * 0.30, size.height * 0.20)
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.25,
        size.width * 0.12,
        size.height * 0.60,
      )
      ..lineTo(size.width * 0.18, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.25,
        size.width * 0.32,
        size.height * 0.22,
      )
      ..close();
    canvas.drawPath(earLeft, Paint()..color = Colors.amber[500]!);
    canvas.drawPath(earLeft, outlinePaint);

    // Правое ухо
    final earRight = Path()
      ..moveTo(size.width * 0.70, size.height * 0.20)
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.25,
        size.width * 0.88,
        size.height * 0.60,
      )
      ..lineTo(size.width * 0.82, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.25,
        size.width * 0.68,
        size.height * 0.22,
      )
      ..close();
    canvas.drawPath(earRight, Paint()..color = Colors.amber[500]!);
    canvas.drawPath(earRight, outlinePaint);

    // 🔹 ВОЛНИСТЫЕ ЛИНИИ НА УШАХ
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * (0.18 - i * 0.02), size.height * (0.30 + i * 0.08)),
        Offset(size.width * (0.19 - i * 0.02), size.height * (0.35 + i * 0.08)),
        Paint()
          ..color = Colors.amber[700]!
          ..strokeWidth = 0.8,
      );
      canvas.drawLine(
        Offset(size.width * (0.82 + i * 0.02), size.height * (0.30 + i * 0.08)),
        Offset(size.width * (0.81 + i * 0.02), size.height * (0.35 + i * 0.08)),
        Paint()
          ..color = Colors.amber[700]!
          ..strokeWidth = 0.8,
      );
    }

    // 🔹 ДРУЖЕЛЮБНЫЙ РОТ (улыбка)
    final mouth = Path()
      ..moveTo(size.width * 0.50, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.44,
        size.height * 0.48,
        size.width * 0.40,
        size.height * 0.46,
      );
    canvas.drawPath(mouth, outlinePaint);

    final mouth2 = Path()
      ..moveTo(size.width * 0.50, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.56,
        size.height * 0.48,
        size.width * 0.60,
        size.height * 0.46,
      );
    canvas.drawPath(mouth2, outlinePaint);

    // 🔹 ПЕРЕДНИЕ ЛАПЫ (опираются)
    final frontLegLeft = Path()
      ..moveTo(size.width * 0.35, size.height * 0.95)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.85,
        size.width * 0.28,
        size.height * 1.10,
      );
    final legPaint = Paint()
      ..color = Colors.amber[400]!
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(frontLegLeft, legPaint);
    canvas.drawPath(frontLegLeft, Paint()
      ..color = Colors.amber[700]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);

    final frontLegRight = Path()
      ..moveTo(size.width * 0.65, size.height * 0.95)
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.85,
        size.width * 0.72,
        size.height * 1.10,
      );
    canvas.drawPath(frontLegRight, legPaint);
    canvas.drawPath(frontLegRight, Paint()
      ..color = Colors.amber[700]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);

    // 🔹 ЗАДНИЕ ЛАПЫ (сидит на них)
    final backLegLeft = Path()
      ..moveTo(size.width * 0.30, size.height * 0.90)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.95,
        size.width * 0.15,
        size.height * 1.15,
      );
    canvas.drawPath(backLegLeft, legPaint);
    canvas.drawPath(backLegLeft, Paint()
      ..color = Colors.amber[700]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);

    final backLegRight = Path()
      ..moveTo(size.width * 0.70, size.height * 0.90)
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.95,
        size.width * 0.85,
        size.height * 1.15,
      );
    canvas.drawPath(backLegRight, legPaint);
    canvas.drawPath(backLegRight, Paint()
      ..color = Colors.amber[700]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);

    // 🔹 ПУШИСТЫЙ ХВОСТ (поднят вверх и в сторону - ГОЛДЕНА ФИШКА!)
    final tail = Path()
      ..moveTo(size.width * 0.70, size.height * 0.50)
      ..quadraticBezierTo(
        size.width * 0.95,
        size.height * 0.20,
        size.width * 1.10,
        size.height * 0.35,
      );
    final tailPaint = Paint()
      ..color = Colors.amber[600]!
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(tail, tailPaint);

    // Пушистость хвоста
    for (int i = 0; i < 6; i++) {
      final waveStart = Offset(
        size.width * (0.72 + i * 0.05),
        size.height * (0.48 - i * 0.06),
      );
      final waveX = size.width * (0.82 + i * 0.06);
      final waveY = size.height * (0.32 - i * 0.07);

      final fluffPath = Path()
        ..moveTo(waveStart.dx, waveStart.dy)
        ..quadraticBezierTo(
          waveX + size.width * 0.05,
          waveY - size.width * 0.04,
          waveX,
          waveY - size.width * 0.055,
        );
      canvas.drawPath(fluffPath, Paint()
        ..color = Colors.amber[700]!
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(SittingDogPainter oldDelegate) => false;
}
