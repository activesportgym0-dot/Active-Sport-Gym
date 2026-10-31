import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
class TarjetaProductoCliente extends StatelessWidget {
  final Map<String, dynamic> producto;
  final VoidCallback onVerMas;
  const TarjetaProductoCliente({
    super.key,
    required this.producto,
    required this.onVerMas,
  });
  // La imagen es una URL de Cloudinary (o un asset local, si algún producto lo trae)
  Widget _construirImagen(String ruta) {
    const iconoVacio = Icon(Icons.image, color: Colors.white54, size: 40);
    if (ruta.isEmpty) return const SizedBox(width: 60, height: 60, child: Center(child: iconoVacio));

    if (ruta.startsWith('assets/')) {
      return Image.asset(
        ruta,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => iconoVacio,
      );
    }
    return Image.network(
      ruta,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const SizedBox(width: 60, height: 60, child: Center(child: iconoVacio)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _construirImagen((producto['imagen'] ?? '').toString()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto['nombre'],
                  style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Marca: ${producto['marca']}',
                  style: TextStyle(fontFamily: 'Roboto', color: Colors.grey[400], fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  producto['stock'],
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    // Agotado se muestra en rojo; con unidades disponibles, en verde
                    color: producto['stock_int'] == 0 ? Colors.redAccent : AppColors.verdePrimario,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                producto['precio'],
                style: const TextStyle(fontFamily: 'Teko', color: AppColors.verdePrimario, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdePrimario,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: const Size(60, 26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: onVerMas,
                child: const Text('Ver más', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
