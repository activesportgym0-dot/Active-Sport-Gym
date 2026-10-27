import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class DetalleSeccionCard extends StatelessWidget {
  final String titulo;
  final String contenido;
  final IconData icono;

  const DetalleSeccionCard({
    super.key,
    required this.titulo,
    required this.contenido,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    if (contenido.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: AppColors.verdePrimario, size: 20),
              const SizedBox(width: 8),
              Text(
                titulo.toUpperCase(),
                style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                  color: AppColors.verdePrimario,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            contenido,
            style: EstiloTexto.textoNormalRoboto.copyWith(
              color: AppColors.blancoPuro,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}