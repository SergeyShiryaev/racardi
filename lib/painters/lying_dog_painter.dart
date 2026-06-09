import 'package:flutter/material.dart';

/// 🐕 Пушистый голден ретривер - лежит и ждёт (CustomPaint для красоты)
class LyingDogPainter extends CustomPainter {
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

    // 🔹 БОЛЬШОЕ ОКРУГЛОЕ ТЕЛО (главное - выглядит пушисто)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.62, size.height * 0.54),
        width: size.width * 0.45,
        height: size.width * 0.34,
      ),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.62, size.height * 0.54),
        width: size.width * 0.45,
        height: size.width * 0.34,
      ),
      outlinePaint,
    );

    // 🔹 ПУШИСТАЯ ГРУДЬ И ЖИВОТ (светлые)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.52, size.height * 0.62),
        width: size.width * 0.20,
        height: size.width * 0.25,
      ),
      Paint()..color = Colors.amber[100]!,
    );

    // 🔹 ГОЛОВА - КРУГЛАЯ И ДОСТАТОЧНО БОЛЬШАЯ
    canvas.drawCircle(
      Offset(size.width * 0.23, size.height * 0.36),
      size.width * 0.11,
      headPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.23, size.height * 0.36),
      size.width * 0.11,
      outlinePaint,
    );

    // 🔹 МОРДА СНИЗУ (характерный собачий снизу)
    final snoutBottom = Rect.fromCenter(
      center: Offset(size.width * 0.18, size.height * 0.46),
      width: size.width * 0.10,
      height: size.width * 0.08,
    );
    canvas.drawOval(snoutBottom, Paint()..color = Colors.amber[200]!);

    // 🔹 ОГРОМНЫЙ СОБАЧИЙ НОС
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.41),
      size.width * 0.040,
      darkPaint,
    );

    // 🔹 СОБАЧЬИ НОЗДРИ
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.12, size.height * 0.42),
        width: size.width * 0.030,
        height: size.width * 0.018,
      ),
      0,
      3.14,
      false,
      Paint()
        ..color = Colors.brown[900]!
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    // 🔹 ДОБРЫЙ БОЛЬШОЙ ГЛАЗ
    canvas.drawCircle(
      Offset(size.width * 0.26, size.height * 0.31),
      size.width * 0.052,
      Paint()..color = Colors.amber[100]!,
    );
    canvas.drawCircle(
      Offset(size.width * 0.26, size.height * 0.31),
      size.width * 0.052,
      outlinePaint,
    );
    // Чёрный зрачок с блеском (главное выражение лица!)
    canvas.drawCircle(
      Offset(size.width * 0.27, size.height * 0.30),
      size.width * 0.025,
      darkPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.28, size.height * 0.28),
      size.width * 0.010,
      Paint()..color = Colors.white,
    );

    // 🔹 ВТОРОЙ ГЛАЗ
    canvas.drawCircle(
      Offset(size.width * 0.34, size.height * 0.32),
      size.width * 0.048,
      Paint()..color = Colors.amber[100]!,
    );
    canvas.drawCircle(
      Offset(size.width * 0.34, size.height * 0.32),
      size.width * 0.048,
      outlinePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.31),
      size.width * 0.022,
      darkPaint,
    );

    // 🔹 ДВА ДЛИННЫХ ХАРАКТЕРНЫХ УХА (ГЛАВНАЯ ЧЕРТА!)
    // Ухо 1 - левое, очень длинное и пушистое
    final ear1 = Path()
      ..moveTo(size.width * 0.15, size.height * 0.24)
      ..quadraticBezierTo(
        size.width * 0.06,
        size.height * 0.18,
        size.width * 0.04,
        size.height * 0.58,
      )
      ..lineTo(size.width * 0.08, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.09,
        size.height * 0.26,
        size.width * 0.17,
        size.height * 0.26,
      )
      ..close();
    canvas.drawPath(ear1, Paint()..color = Colors.amber[500]!);
    canvas.drawPath(ear1, outlinePaint);

    // Ухо 2 - правое, ещё длиннее
    final ear2 = Path()
      ..moveTo(size.width * 0.31, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.14,
        size.width * 0.46,
        size.height * 0.60,
      )
      ..lineTo(size.width * 0.42, size.height * 0.60)
      ..quadraticBezierTo(
        size.width * 0.39,
        size.height * 0.24,
        size.width * 0.29,
        size.height * 0.24,
      )
      ..close();
    canvas.drawPath(ear2, Paint()..color = Colors.amber[500]!);
    canvas.drawPath(ear2, outlinePaint);

    // 🔹 ВРЕЗИНКА НА УШАХ
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * (0.08 + i * 0.03), size.height * (0.30 + i * 0.08)),
        Offset(size.width * (0.09 + i * 0.03), size.height * (0.35 + i * 0.08)),
        Paint()
          ..color = Colors.amber[700]!
          ..strokeWidth = 0.8,
      );
    }

    // 🔹 ДРУЖЕЛЮБНЫЙ РОТ
    final mouth = Path()
      ..moveTo(size.width * 0.12, size.height * 0.48)
      ..quadraticBezierTo(
        size.width * 0.06,
        size.height * 0.56,
        size.width * 0.02,
        size.height * 0.54,
      );
    canvas.drawPath(mouth, outlinePaint);

    // 🔹 ПЕРЕДНИЕ ЛАПЫ - СОБАЧЬИ И ВИДНЫ ПОЛНОСТЬЮ
    final frontLeg1 = Path()
      ..moveTo(size.width * 0.80, size.height * 0.40)
      ..quadraticBezierTo(
        size.width * 0.90,
        size.height * 0.55,
        size.width * 0.88,
        size.height * 0.82,
      );
    final legPaint = Paint()
      ..color = Colors.amber[400]!
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(frontLeg1, legPaint);
    canvas.drawPath(frontLeg1, Paint()
      ..color = Colors.amber[700]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);

    final frontLeg2 = Path()
      ..moveTo(size.width * 0.75, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.72,
        size.width * 0.80,
        size.height * 0.92,
      );
    canvas.drawPath(frontLeg2, legPaint);
    canvas.drawPath(frontLeg2, Paint()
      ..color = Colors.amber[700]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);

    // 🔹 ЗАДНИЕ ЛАПЫ (согнутые)
    final backLeg1 = Path()
      ..moveTo(size.width * 0.28, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.86,
        size.width * 0.12,
        size.height * 0.98,
      );
    canvas.drawPath(backLeg1, legPaint);
    canvas.drawPath(backLeg1, Paint()
      ..color = Colors.amber[700]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);

    final backLeg2 = Path()
      ..moveTo(size.width * 0.42, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.90,
        size.width * 0.30,
        size.height * 1.00,
      );
    canvas.drawPath(backLeg2, legPaint);
    canvas.drawPath(backLeg2, Paint()
      ..color = Colors.amber[700]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);

    // 🔹 ПУШИСТЫЙ ХВОСТ (ГЛАВНАЯ ФИШКА ГОЛДЕНА! Поднят вверх)
    final tail = Path()
      ..moveTo(size.width * 0.84, size.height * 0.33)
      ..quadraticBezierTo(
        size.width * 1.00,
        size.height * 0.05,
        size.width * 1.10,
        size.height * 0.22,
      );
    final tailPaint = Paint()
      ..color = Colors.amber[600]!
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(tail, tailPaint);

    // Пушистость - волнистые линии рядом
    for (int i = 0; i < 5; i++) {
      final waveStart = Offset(
        size.width * (0.85 + i * 0.05),
        size.height * (0.28 + i * 0.07),
      );
      final waveX = size.width * (0.92 + i * 0.05);
      final waveY = size.height * (0.15 + i * 0.08);

      final fluffPath = Path()
        ..moveTo(waveStart.dx, waveStart.dy)
        ..quadraticBezierTo(
          waveX - size.width * 0.04,
          waveY - size.width * 0.05,
          waveX,
          waveY - size.width * 0.06,
        );
      canvas.drawPath(fluffPath, Paint()
        ..color = Colors.amber[700]!
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(LyingDogPainter oldDelegate) => false;
}