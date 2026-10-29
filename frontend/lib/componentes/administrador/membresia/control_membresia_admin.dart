import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class ControlMembresiaAdmin extends StatelessWidget {
  final String estadoMembresia;
  final String fechaInicio;
  final String fechaFin;
  final ValueChanged<String> onEstadoChanged;
  final VoidCallback onRenovarAsignar;

  const ControlMembresiaAdmin({
    super.key,
    required this.estadoMembresia,
    required this.fechaInicio,
    required this.fechaFin,
    required this.onEstadoChanged,
    required this.onRenovarAsignar,
  });

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':
        return AppColors.verdePrimario;
      case 'vencida':
        return Colors.redAccent;
      case 'inactiva':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color colorEstado = _colorEstado(estadoMembresia);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONTROL DE MEMBRESÍA',
          style: TextStyle(
            color: AppColors.grisMedio,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.grisOscuro,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorEstado.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Membresía (Gym)',
                    style: TextStyle(color: AppColors.blancoPuro, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorEstado),
                    ),
                    child: Text(
                      estadoMembresia.toUpperCase(),
                      style: TextStyle(color: colorEstado, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Inicio: $fechaInicio  •  Fin: $fechaFin',
                style: const TextStyle(color: AppColors.grisClaro, fontSize: 11),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.verdePrimario),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        final nuevo = estadoMembresia.toLowerCase() == 'activa' ? 'inactiva' : 'activa';
                        onEstadoChanged(nuevo);
                      },
                      child: Text(
                        estadoMembresia.toLowerCase() == 'activa' ? 'DESACTIVAR' : 'ACTIVAR',
                        style: const TextStyle(color: AppColors.verdePrimario, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verdePrimario,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onRenovarAsignar,
                      child: const Text(
                        'ASIGNAR / RENOVAR',
                        style: TextStyle(color: AppColors.fondoNegro, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}