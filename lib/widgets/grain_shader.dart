import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class GrainShader extends CustomPainter {
  final Color color;
  final double opacity;

  GrainShader({
    required this.color,
    this.opacity = 0.1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random();
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 1;

    for (var i = 0; i < size.width * size.height * 0.1; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawPoints(
        ui.PointMode.points,
        [Offset(x, y)],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
