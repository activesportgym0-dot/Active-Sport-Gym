import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class TarjetaNotificacionAdmin extends StatelessWidget {
  final Map<String, dynamic> noti;
  final VoidCallback onDelete;

  const TarjetaNotificacionAdmin({
    super.key,
    required this.noti,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.verdePrimario.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  noti['tipo'].toUpperCase(),
                  style: EstiloTexto.textoNormalRoboto.copyWith(
                    color: AppColors.verdePrimario,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            noti['titulo'],
            style: EstiloTexto.enlaceNegritaRoboto.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            noti['mensaje'],
            style: EstiloTexto.textoNormalRoboto.copyWith(color: AppColors.grisClaro, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Destino: ${noti['destino']}',
                style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 10, color: AppColors.grisMedio),
              ),
              Text(
                noti['fecha'],
                style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 10, color: AppColors.grisMedio),
              ),
            ],
          ),
        ],
      ),
    );
  }
}