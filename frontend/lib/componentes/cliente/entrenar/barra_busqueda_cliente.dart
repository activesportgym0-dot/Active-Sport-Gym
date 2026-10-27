import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class BarraBusquedaCliente extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onOpenFilters;
  final bool tieneFiltrosActivos; // 👈 Asegúrate de incluirlo aquí

  const BarraBusquedaCliente({
    super.key,
    required this.searchController,
    required this.onOpenFilters,
    this.tieneFiltrosActivos = false, // 👈 Y aquí como opcional con valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.grisOscuro,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
              ),
              child: TextField(
                controller: searchController,
                style: EstiloTexto.campoTexto,
                decoration: InputDecoration(
                  hintText: 'Buscar suplementos, marcas...',
                  hintStyle: EstiloTexto.hintTexto,
                  prefixIcon: const Icon(Icons.search, color: AppColors.grisMedio, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onOpenFilters,
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                // 👈 Se ilumina en verde si hay filtros activos
                color: tieneFiltrosActivos ? AppColors.verdePrimario : AppColors.grisOscuro,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.grisMedio.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.tune,
                color: tieneFiltrosActivos ? Colors.black : AppColors.verdePrimario,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}