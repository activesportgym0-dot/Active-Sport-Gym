import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class AdminProductoCard extends StatelessWidget {
  final String name;
  final String brand;
  final String price;
  final String stock;
  final String imagePath;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminProductoCard({
    super.key,
    required this.name,
    required this.brand,
    required this.price,
    required this.stock,
    required this.imagePath,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _placeholder() {
    return Container(
      width: 65,
      height: 65,
      color: AppColors.grisOscuro,
      child: const Icon(Icons.shopping_bag_outlined, color: AppColors.grisMedio),
    );
  }

  // La imagen puede ser un asset local o una URL de Cloudinary.
  Widget _construirImagen() {
    if (imagePath.isEmpty) return _placeholder();

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: 65,
        height: 65,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }

    return Image.network(
      imagePath,
      width: 65,
      height: 65,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _construirImagen(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: EstiloTexto.enlaceNegritaRoboto.copyWith(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Marca: $brand',
                  style: EstiloTexto.textoNormalRoboto.copyWith(color: AppColors.grisClaro, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock: $stock | $price',
                  style: EstiloTexto.textoNormalRoboto.copyWith(color: AppColors.verdePrimario, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.verdePrimario, size: 18),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
