import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class AdminExerciseCard extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminExerciseCard({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Verificamos si la imagen es una URL de red (Supabase) o un asset local
    final bool isNetworkImage = imagePath.startsWith('http://') || imagePath.startsWith('https://');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del ejercicio (Soporta red o asset local)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isNetworkImage
                  ? Image.network(
                      imagePath,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                    )
                  : Image.asset(
                      imagePath,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                    ),
            ),
            const SizedBox(width: 12),
            
            // Información principal del ejercicio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: EstiloTexto.politicasRoboto.copyWith(
                      color: AppColors.verdePrimario,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                      color: AppColors.blancoPuro,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: EstiloTexto.textoNormalRoboto.copyWith(
                      color: AppColors.grisMedio,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Botones de edición y eliminación
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.verdePrimario, size: 20),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      width: 70,
      height: 70,
      color: AppColors.grisMedio,
      child: const Icon(Icons.fitness_center, color: AppColors.blancoPuro),
    );
  }
}