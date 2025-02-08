import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBlob extends StatefulWidget {
  final List<Color> colors;
  final double size;

  const AnimatedBlob({
    super.key,
    required this.colors,
    this.size = 200,
  });

  @override
  State<AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<AnimatedBlob>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final _random = math.Random();
  late List<Offset> _positions;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _positions = List.generate(2, (index) {
      return Offset(
        _random.nextDouble() * 0.4 - 0.2,
        _random.nextDouble() * 0.4 - 0.2,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: List.generate(2, (index) {
            final normalizedProgress = _controller.value * 2 * math.pi;
            final move = Offset(
              math.sin(normalizedProgress + index * math.pi) * 0.15,
              math.cos(normalizedProgress + index * math.pi) * 0.15,
            );

            return Positioned.fill(
              child: Transform.translate(
                offset: Offset(
                  (_positions[index].dx + move.dx) * widget.size,
                  (_positions[index].dy + move.dy) * widget.size,
                ),
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _OptimizedBlobPainter(
                      color: widget.colors[index % widget.colors.length],
                      progress: normalizedProgress,
                      phaseOffset: index * math.pi,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _OptimizedBlobPainter extends CustomPainter {
  final Color color;
  final double progress;
  final double phaseOffset;
  static const _points = 180;

  _OptimizedBlobPainter({
    required this.color,
    required this.progress,
    required this.phaseOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final path = Path();

    for (var i = 0; i <= _points; i++) {
      final angle = (i * math.pi * 2) / _points;
      final loopedProgress = progress % (math.pi * 2);

      final noise = math.sin(angle * 3 + loopedProgress + phaseOffset) * 0.15 +
          math.cos(angle * 4 - loopedProgress + phaseOffset) * 0.15;

      final r = radius * (0.8 + noise);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final gradient = ui.Gradient.radial(
      center,
      radius * 1.5,
      [
        color.withOpacity(0.3),
        color.withOpacity(0.1),
        color.withOpacity(0.05),
      ],
      [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32)
      ..imageFilter = ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OptimizedBlobPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.phaseOffset != phaseOffset;
  }
}
