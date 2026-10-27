import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'dart:math' as math;

class FondoApp extends StatelessWidget {
  final Widget child;

  const FondoApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Color base negro puro
        Container(
          color: AppColors.fondoNegro,
        ),
        
        // 2. Fondo personalizado con siluetas de pesas y rayos sutiles
        Positioned.fill(
          child: CustomPaint(
            painter: _GymBackgroundPainter(),
          ),
        ),
        
        // 3. Contenido principal de la pantalla
        child,
      ],
    );
  }
}

class _GymBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrids = Paint()
      ..color = AppColors.grisMedio.withOpacity(0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Dibujar líneas diagonales sutiles (efecto velocidad / rayos limpios)
    for (double i = -size.height; i < size.width + size.height; i += 40) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paintGrids,
      );
    }

    // Pintor para siluetas de pesas / discos minimalistas de fondo
    final paintShapes = Paint()
      ..color = AppColors.grisOscuro.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    // Dibujar círculos decorativos simulando discos de pesas olímpicas en las esquinas
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 90, paintShapes);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.75), 120, paintShapes);
    
    // Anillo exterior para que parezca un disco de pesa
    final paintRing = Paint()
      ..color = AppColors.blancoTransparente.withOpacity(0.03)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
      
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 110, paintRing);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.75), 140, paintRing);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}