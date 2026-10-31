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

  // Icono que acompaña a cada tipo de notificación
  IconData _iconoTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'stock':
        return Icons.inventory_2_outlined;
      case 'evento':
        return Icons.event_outlined;
      case 'membresia':
        return Icons.card_membership;
      case 'rutina':
        return Icons.fitness_center;
      default:
        return Icons.notifications_none;
    }
  }

  Widget _placeholderImagen() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.black26,
      child: const Icon(Icons.broken_image_outlined, color: AppColors.grisMedio, size: 32),
    );
  }

  // Imagen opcional de la notificación (viene de Cloudinary en imagen_url)
  Widget _construirImagen(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progreso) {
          if (progreso == null) return child;
          return Container(
            height: 150,
            width: double.infinity,
            color: Colors.black26,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.verdePrimario,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _placeholderImagen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String tipo = (noti['tipo'] ?? '').toString();
    final String titulo = (noti['titulo'] ?? '').toString();
    final String mensaje = (noti['mensaje'] ?? '').toString();
    final String destino = (noti['destino'] ?? '').toString();
    final String fecha = (noti['fecha'] ?? '').toString();
    final String imagenUrl = (noti['imagen_url'] ?? '').toString();
    final bool esGlobal = destino.toLowerCase().startsWith('todos');

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
          // Imagen (solo si la notificación tiene una)
          if (imagenUrl.isNotEmpty) ...[
            _construirImagen(imagenUrl),
            const SizedBox(height: 10),
          ],

          // Tipo y botón de eliminar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.verdePrimario.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconoTipo(tipo), color: AppColors.verdePrimario, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      tipo.toUpperCase(),
                      style: EstiloTexto.textoNormalRoboto.copyWith(
                        color: AppColors.verdePrimario,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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

          // Título y mensaje
          Text(
            titulo,
            style: EstiloTexto.enlaceNegritaRoboto.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            mensaje,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: EstiloTexto.textoNormalRoboto.copyWith(color: AppColors.grisClaro, fontSize: 12),
          ),

          const Divider(color: Colors.white12, height: 18),

          // Destino y fecha
          Row(
            children: [
              Icon(
                esGlobal ? Icons.people_outline : Icons.person_outline,
                color: AppColors.grisMedio,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  destino,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 10, color: AppColors.grisMedio),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today_outlined, color: AppColors.grisMedio, size: 11),
              const SizedBox(width: 4),
              Text(
                fecha,
                style: EstiloTexto.textoNormalRoboto.copyWith(fontSize: 10, color: AppColors.grisMedio),
              ),
            ],
          ),
        ],
      ),
    );
  }
}