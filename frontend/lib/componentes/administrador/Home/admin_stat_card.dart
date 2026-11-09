import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Tarjeta de colores del home del administrador.
///  - Con [valor]: muestra un número grande (ejercicios, productos, membresías...).
///  - Sin [valor] (vacío): es un botón simple; el [titulo] va grande (ej. "Control de pedidos").
class AdminStatCard extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String titulo;
  final String detalle; // línea pequeña opcional, ej. "de 20 registrados"
  final Color color;
  final VoidCallback? onTap;

  const AdminStatCard({
    super.key,
    required this.icono,
    required this.valor,
    required this.titulo,
    this.detalle = '',
    this.color = AppColors.verdePrimario,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.18), AppColors.grisOscuro],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: valor.isEmpty
                  // Botón sin número: el título es lo principal
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Oswald',
                            color: AppColors.blancoPuro,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        if (detalle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            detalle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.grisClaro, fontSize: 10),
                          ),
                        ],
                      ],
                    )
                  // Con número grande
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          valor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Oswald',
                            color: AppColors.blancoPuro,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.blancoPuro, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        if (detalle.isNotEmpty)
                          Text(
                            detalle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.grisClaro, fontSize: 10),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}