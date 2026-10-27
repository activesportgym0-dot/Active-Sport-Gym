import 'package:flutter/material.dart';
// Asegúrate de cambiar esta ruta por la ubicación exacta donde tengas tu CategoryChip compartido o de admin:
import 'package:frontend/componentes/administrador/entrenar/category_chip.dart';

class BarraCategoriasHome extends StatelessWidget {
  final List<String> categorias;
  final String categoriaSeleccionada;
  final Function(String) onCategoriaSelected;

  const BarraCategoriasHome({
    super.key,
    required this.categorias,
    required this.categoriaSeleccionada,
    required this.onCategoriaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categorias.map((cat) {
          bool estaSeleccionado = categoriaSeleccionada == cat;
          return CategoryChip(
            label: cat,
            isSelected: estaSeleccionado,
            onTap: () => onCategoriaSelected(cat),
          );
        }).toList(),
      ),
    );
  }
}