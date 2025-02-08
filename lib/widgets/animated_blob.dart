import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBlob extends StatefulWidget {
  final Color color;
  final double size;

  const AnimatedBlob({
    super.key,
    required this.color,
    this.size = 200,
  });

  @override
  State<AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<AnimatedBlob>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller1,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _controller2,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _BlobPainter(
                color: widget.color,
                angle1: _controller1.value * 2 * math.pi,
                angle2: _controller2.value * 2 * math.pi,
              ),
            );
          },
        );
      },
    );
  }
}

class _BlobPainter extends CustomPainter {
  final Color color;
  final double angle1;
  final double angle2;

  _BlobPainter({
    required this.color,
    required this.angle1,
    required this.angle2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final path = Path();
    for (var i = 0; i < 360; i++) {
      final rad = i * math.pi / 180;
      final variance1 = math.sin(rad * 6 + angle1) * 0.15;
      final variance2 = math.cos(rad * 8 + angle2) * 0.15;
      final r = radius * (1 + variance1 + variance2);
      final x = center.dx + r * math.cos(rad);
      final y = center.dy + r * math.sin(rad);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) {
    return oldDelegate.angle1 != angle1 ||
        oldDelegate.angle2 != angle2 ||
        oldDelegate.color != color;
  }
}
