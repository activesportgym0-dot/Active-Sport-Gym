import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/models/ejercicio_catalogo_model.dart';

/// Mini buscador de ejercicios que se muestra DENTRO de la tarjeta "Ejercicio N":
/// buscador, desplegable de categoría y lista de ejercicios del catálogo.
/// Reemplaza al modal inferior (ModalBuscadorEjercicios).
class MiniBuscadorEjercicios extends StatefulWidget {
  final List<EjercicioCatalogoModel> catalogo;

  /// Nombres de las categorías (sin "Todos", que se agrega solo).
  final List<String> categorias;
  final bool cargando;
  final ValueChanged<EjercicioCatalogoModel> onSeleccionar;
  final double alturaLista;

  const MiniBuscadorEjercicios({
    super.key,
    required this.catalogo,
    required this.categorias,
    required this.onSeleccionar,
    this.cargando = false,
    this.alturaLista = 330,
  });

  @override
  State<MiniBuscadorEjercicios> createState() => _MiniBuscadorEjerciciosState();
}

class _MiniBuscadorEjerciciosState extends State<MiniBuscadorEjercicios> {
  static const String _todas = 'Todos';

  final TextEditingController _searchController = TextEditingController();
  String _categoriaFiltro = _todas;

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

  List<EjercicioCatalogoModel> get _filtrados {
    final texto = _searchController.text.toLowerCase().trim();

    return widget.catalogo.where((e) {
      final coincideTexto = texto.isEmpty ||
          e.nombre.toLowerCase().contains(texto) ||
          e.descripcion.toLowerCase().contains(texto) ||
          e.maquina.toLowerCase().contains(texto);
      final coincideCategoria = _categoriaFiltro == _todas || e.perteneceA(_categoriaFiltro);
      return coincideTexto && coincideCategoria;
    }).toList();
  }

  Widget _imagen(String url) {
    const double ancho = 96;
    const double alto = 68;
    final placeholder = Container(
      width: ancho,
      height: alto,
      color: Colors.black26,
      child: const Icon(Icons.fitness_center, color: Colors.white38, size: 26),
    );

    if (url.isEmpty) return placeholder;
    if (url.startsWith('assets/')) {
      return Image.asset(url, width: ancho, height: alto, fit: BoxFit.cover);
    }
    return Image.network(
      url,
      width: ancho,
      height: alto,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }

  Widget _construirDesplegableCategoria() {
    return PopupMenuButton<String>(
      color: AppColors.grisOscuro,
      onSelected: (valor) => setState(() => _categoriaFiltro = valor),
      itemBuilder: (context) => [_todas, ...widget.categorias]
          .map(
            (c) => PopupMenuItem<String>(
              value: c,
              child: Text(
                c,
                style: TextStyle(
                  color: c == _categoriaFiltro ? AppColors.verdePrimario : Colors.white,
                  fontSize: 13,
                  fontWeight: c == _categoriaFiltro ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.grisOscuro,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _categoriaFiltro,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 14),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.verdePrimario, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _construirTarjeta(EjercicioCatalogoModel ejercicio) {
    return GestureDetector(
      onTap: () => widget.onSeleccionar(ejercicio),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.grisOscuro,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _imagen(ejercicio.imagen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ejercicio.etiqueta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.verdePrimario, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ejercicio.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ejercicio.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 10, height: 1.25),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios, color: AppColors.verdePrimario, size: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtrados;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fondoNegro,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buscador
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Buscar ejercicios, rutinas...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
              filled: true,
              fillColor: AppColors.grisOscuro,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 10),

          // Categoría
          _construirDesplegableCategoria(),
          const SizedBox(height: 10),

          // Lista de ejercicios (con su propio scroll)
          SizedBox(
            height: widget.alturaLista,
            child: widget.cargando
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.verdePrimario),
                  )
                : lista.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron ejercicios.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: lista.length,
                        itemBuilder: (context, index) => _construirTarjeta(lista[index]),
                      ),
          ),
        ],
      ),
    );
  }
}
