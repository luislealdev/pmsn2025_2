import 'package:flutter/material.dart';
import 'dart:math' as math;

class AttributePainter extends CustomPainter {
  final double progressPercent;
  final double strokeWidth, filledStrokeWidth;

  final bgPaint, strokeBgPaint, strokeFilledPaint;

  AttributePainter({
    required this.progressPercent,
    this.strokeWidth = 1.0,
    this.filledStrokeWidth = 4.0,
  }) : bgPaint = Paint()..color = Colors.white.withOpacity(0.25),
       strokeBgPaint = Paint()..color = Color(0xffD264C9),
       strokeFilledPaint =
           Paint()
             ..color = Colors.white
             ..style = PaintingStyle.stroke
             ..strokeWidth = filledStrokeWidth
             ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawCircle(center, radius - strokeWidth, strokeBgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
      -math.pi / 2, // - 45 degrees to start from top
      (progressPercent / 100) * math.pi * 2,
      false,
      strokeFilledPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AttributeWidget extends StatelessWidget {
  final double size;
  final double progress;
  final Widget? child;

  const AttributeWidget({
    Key? key,
    required this.progress,
    this.size = 50,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AttributePainter(progressPercent: progress),
      size: Size(size, size),
      child: Container(
        padding: EdgeInsets.all(size / 3.8),
        width: size,
        height: size,
        child: child,
      ),
    );
  }
}
