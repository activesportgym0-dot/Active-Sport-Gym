import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class ControlMembresiaAdmin extends StatelessWidget {
  final bool membresiaActiva;
  final ValueChanged<bool> onChanged;

  const ControlMembresiaAdmin({
    super.key,
    required this.membresiaActiva,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONTROL DE ESTADOS',
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
            border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Membresía Activa (Gym)',
                    style: TextStyle(color: AppColors.blancoPuro, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Controla el pago mensual físico',
                    style: TextStyle(color: AppColors.grisClaro, fontSize: 10),
                  ),
                ],
              ),
              Switch(
                value: membresiaActiva,
                activeColor: AppColors.verdePrimario,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}