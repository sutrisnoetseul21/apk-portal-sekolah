import 'package:flutter/material.dart';

/// Custom Painter untuk menggambar pola garis diagonal halus (45 derajat) persis Blade Laravel .p-bg-lines
class CardStripesPainter extends CustomPainter {
  const CardStripesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.04)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    const step = 14.0;
    final total = size.width + size.height;

    for (double i = -size.height; i < total; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

