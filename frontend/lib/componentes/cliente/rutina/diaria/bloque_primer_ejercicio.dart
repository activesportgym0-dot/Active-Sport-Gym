import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class BloquePrimerEjercicio extends StatelessWidget {
  final VoidCallback onAgregarEjercicio;

  const BloquePrimerEjercicio({
    super.key,
    required this.onAgregarEjercicio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onAgregarEjercicio,
            child: const Icon(Icons.add_circle_outline, color: AppColors.verdePrimario, size: 50),
          ),
          const SizedBox(height: 12),
          const Text(
            'AGREGAR TU PRIMER EJERCICIO',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'Toca el botón para empezar a construir tu rutina',
            style: TextStyle(color: Colors.grey, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: onAgregarEjercicio,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.verdePrimario),
                ),
              ),
              child: const Text('AGREGAR EJERCICIO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}