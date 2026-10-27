import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class DialogConfirmarCancelar {
  static void mostrar(BuildContext context, {required VoidCallback onConfirmar}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.grisOscuro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.verdePrimario.withOpacity(0.3), width: 1),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono superior decorativo acorde al diseño
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.verdePrimario,
                size: 40,
              ),
              const SizedBox(height: 12),
              
              // Título centrado
              const Text(
                '¿ESTÁS SEGURO?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              
              // Mensaje centrado
              const Text(
                'Tienes ejercicios o datos ingresados. Si sales ahora, perderás el progreso de tu rutina.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              
              // Botones organizados estéticamente sin colores fuera de la paleta
              Row(
                children: [
                  // Botón de Seguir Editando (Secundario)
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.verdePrimario),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'SEGUIR',
                          style: TextStyle(
                            color: AppColors.verdePrimario,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Botón de Confirmar Cancelación (Principal con estilo limpio)
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdePrimario,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Cierra el diálogo
                          onConfirmar(); // Ejecuta la salida
                        },
                        child: const Text(
                          'DESCARTAR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}