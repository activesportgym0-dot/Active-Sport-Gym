import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class BloquePrimerEjercicio extends StatelessWidget {
  final VoidCallback onAgregar;

  const BloquePrimerEjercicio({super.key, required this.onAgregar});

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
            onTap: onAgregar,
            child: const Icon(Icons.add_circle_outline, color: AppColors.verdePrimario, size: 50),
          ),
          const SizedBox(height: 12),
          const Text(
            'AGREGAR TU PRIMER EJERCICIO',
            style: TextStyle(
              fontFamily: 'Oswald',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toca el botón para empezar a construir tu rutina',
            style: EstiloTexto.subtituloRoboto,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 35,
            child: ElevatedButton(
              onPressed: onAgregar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: AppColors.verdePrimario),
                ),
              ),
              child: const Text(
                'AGREGAR EJERCICIO',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}