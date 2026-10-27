import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class TarjetaEjercicioCliente extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback onTap;

  const TarjetaEjercicioCliente({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: AppColors.grisMedio,
                    child: const Icon(Icons.fitness_center, color: AppColors.blancoPuro),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
              const Icon(Icons.chevron_right, color: AppColors.verdePrimario, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}