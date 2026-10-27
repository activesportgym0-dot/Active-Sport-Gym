import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class ModalBuscadorEjercicios extends StatefulWidget {
  final List<Map<String, dynamic>> catalogoEjercicios;
  final Function(Map<String, dynamic> ejercicioSeleccionado) onEjercicioSeleccionado;

  const ModalBuscadorEjercicios({
    super.key,
    required this.catalogoEjercicios,
    required this.onEjercicioSeleccionado,
  });

  @override
  State<ModalBuscadorEjercicios> createState() => _ModalBuscadorEjerciciosState();
}

class _ModalBuscadorEjerciciosState extends State<ModalBuscadorEjercicios> {
  final TextEditingController _searchController = TextEditingController();
  String categoriaFiltro = 'Todos';
  
  final List<String> categoriasDisponibles = ['Todos', 'Cardio', 'Tren superior', 'Piernas', 'Glúteos', 'Resistencia'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase().trim();

    final ejerciciosFiltrados = widget.catalogoEjercicios.where((ejercicio) {
      final titulo = ejercicio['title']?.toString().toLowerCase() ?? '';
      final descripcion = ejercicio['description']?.toString().toLowerCase() ?? '';
      final categoria = ejercicio['category']?.toString().toLowerCase() ?? '';

      final coincideBusqueda = query.isEmpty || titulo.contains(query) || descripcion.contains(query);
      final coincideCategoria = categoriaFiltro.toLowerCase() == 'todos' || categoria == categoriaFiltro.toLowerCase();

      return coincideBusqueda && coincideCategoria;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SELECCIONAR EJERCICIO',
                style: TextStyle(color: AppColors.verdePrimario, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Buscar ejercicios, rutinas...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
              filled: true,
              fillColor: AppColors.fondoNegro,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categoriasDisponibles.map((cat) {
                bool seleccionado = categoriaFiltro == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat, style: TextStyle(fontSize: 11, color: seleccionado ? Colors.black : Colors.white)),
                    selected: seleccionado,
                    selectedColor: AppColors.verdePrimario,
                    backgroundColor: AppColors.fondoNegro,
                    onSelected: (bool selected) {
                      setState(() => categoriaFiltro = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 15),

          Expanded(
            child: ejerciciosFiltrados.isEmpty
                ? const Center(
                    child: Text('No se encontraron ejercicios.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  )
                : ListView.builder(
                    itemCount: ejerciciosFiltrados.length,
                    itemBuilder: (context, index) {
                      final ej = ejerciciosFiltrados[index];
                      return GestureDetector(
                        onTap: () {
                          widget.onEjercicioSeleccionado(ej);
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.fondoNegro,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.verdePrimario.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  ej['imagePath'] ?? 'assets/images/3.jpg',
                                  width: 60,
                                  height: 45,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${ej['category']?.toString().toUpperCase()} - RESISTENCIA',
                                      style: const TextStyle(color: AppColors.verdePrimario, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ej['title'] ?? '',
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ej['description'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: AppColors.verdePrimario, size: 14),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}