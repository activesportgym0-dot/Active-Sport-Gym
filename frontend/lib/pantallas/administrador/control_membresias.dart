import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class ControlMembresiaAdmin extends StatelessWidget {
  final String estadoMembresia;
  final String fechaInicio;
  final String fechaFin;
  final Function(String nuevoEstado) onEstadoChanged;
  final VoidCallback onRenovarAsignar;

  const ControlMembresiaAdmin({
    super.key,
    required this.estadoMembresia,
    required this.fechaInicio,
    required this.fechaFin,
    required this.onEstadoChanged,
    required this.onRenovarAsignar,
  });

  Color _obtenerColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':
        return AppColors.verdePrimario;
      case 'vencida':
        return Colors.redAccent;
      case 'inactiva':
      default:
        return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _obtenerColorEstado(estadoMembresia);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorEstado.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorEstado.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.card_membership, color: AppColors.verdePrimario, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'ESTADO DE MEMBRESÍA',
                    style: TextStyle(
                      color: AppColors.blancoPuro,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorEstado),
                ),
                child: Text(
                  estadoMembresia.toUpperCase(),
                  style: TextStyle(
                    color: colorEstado,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.grisMedio, height: 1),
          ),

          // Selector de estados
          const Text(
            'CAMBIAR ESTADO DE MEMBRESÍA',
            style: TextStyle(color: AppColors.grisClaro, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['activa', 'inactiva', 'vencida'].map((est) {
              final bool seleccionado = estadoMembresia.toLowerCase() == est;
              final colorChip = _obtenerColorEstado(est);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onEstadoChanged(est),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: seleccionado ? colorChip : AppColors.fondoNegro,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: seleccionado ? colorChip : AppColors.grisMedio.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      est.toUpperCase(),
                      style: TextStyle(
                        color: seleccionado ? AppColors.fondoNegro : AppColors.blancoPuro,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Fechas visuales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha Inicio', style: TextStyle(color: AppColors.grisClaro, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(fechaInicio, style: const TextStyle(color: AppColors.blancoPuro, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha Fin (Vencimiento)', style: TextStyle(color: AppColors.grisClaro, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(fechaFin, style: const TextStyle(color: AppColors.blancoPuro, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botón para Asignar / Renovar
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: onRenovarAsignar,
              icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.fondoNegro),
              label: const Text(
                'ASIGNAR / RENOVAR PLAN',
                style: TextStyle(
                  color: AppColors.fondoNegro,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdePrimario,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}