import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class TarjetaHistorialAdmin extends StatelessWidget {
  final VoidCallback onTap;

  const TarjetaHistorialAdmin({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACTIVIDAD Y REGISTROS',
          style: TextStyle(
            color: AppColors.grisMedio,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.grisOscuro,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: const [
                    Icon(Icons.history, color: AppColors.verdePrimario, size: 22),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Historial Completo del Cliente',
                            style: TextStyle(color: AppColors.blancoPuro, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pagos, asistencias y cambios de membresía',
                            style: TextStyle(color: AppColors.grisClaro, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: AppColors.grisMedio, size: 14),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}