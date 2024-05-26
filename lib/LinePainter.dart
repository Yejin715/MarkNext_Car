import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final Offset? points;

  LinePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    drawLines(canvas, size);
    drawCircle(canvas, size);
    drawPoints(canvas, size);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return true;
  }

  void drawLines(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    Offset p1 = Offset(size.width / 2, size.height / 2);
    if (points != null) {
      canvas.drawLine(p1, points!, paint);
    }
  }

  void drawCircle(Canvas canvas, Size size) {
    if (points != null) {
      Paint paint = Paint()
        ..color = Colors.green
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      Offset center = Offset(size.width / 2, size.height / 2);

      double dx = points!.dx - center.dx; // x 좌표 간의 차이
      double dy = points!.dy - center.dy; // y 좌표 간의 차이
      double radius = sqrt(dx * dx + dy * dy);
      canvas.drawCircle(points!, radius, paint); // 선의 끝점을 중심으로 원을 그림
    }
  }

  void drawPoints(Canvas canvas, Size size) {
    if (points != null) {
      Paint paint = Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6.0;
      Offset center = Offset(size.width / 2, size.height / 2);
      canvas.drawPoints(PointMode.points, [center, points!], paint);
    }
  }
}
