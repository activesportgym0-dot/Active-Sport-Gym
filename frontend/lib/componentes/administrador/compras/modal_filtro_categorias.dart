import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class ModalFiltroCategorias extends StatefulWidget {
  final List<String> categoriasDisponibles;
  final List<String> categoriasSeleccionadasIniciales;
  final ValueChanged<List<String>> onAplicarFiltros;

  const ModalFiltroCategorias({
    super.key,
    required this.categoriasDisponibles,
    required this.categoriasSeleccionadasIniciales,
    required this.onAplicarFiltros,
  });

  @override
  State<ModalFiltroCategorias> createState() => _ModalFiltroCategoriasState();
}

class _ModalFiltroCategoriasState extends State<ModalFiltroCategorias> {
  late List<String> _seleccionadas;

  @override
  void initState() {
    super.initState();
    _seleccionadas = List.from(widget.categoriasSeleccionadasIniciales);
  }

  void _toggleCategoria(String categoria) {
    setState(() {
      if (_seleccionadas.contains(categoria)) {
        _seleccionadas.remove(categoria);
      } else {
        if (_seleccionadas.length < 5) {
          _seleccionadas.add(categoria);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Máximo puedes seleccionar 5 categorías'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _limpiarFiltros() {
    setState(() {
      _seleccionadas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        // Fondo negro semi-transparentoso con un borde gris sutil
        color: Colors.black.withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3), // Borde gris elegante
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con Título y Botón "Limpiar"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FILTRAR CATEGORÍAS',
                style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: _limpiarFiltros,
                child: Text(
                  'Limpiar',
                  style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                    color: AppColors.verdePrimario.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.withOpacity(0.2), height: 1),
          const SizedBox(height: 8),

          // Lista de categorías con Checkbox
          Expanded(
            child: ListView.builder(
              itemCount: widget.categoriasDisponibles.length,
              itemBuilder: (context, index) {
                final categoria = widget.categoriasDisponibles[index];
                final estaSeleccionada = _seleccionadas.contains(categoria);

                return CheckboxListTile(
                  title: Text(
                    categoria,
                    style: EstiloTexto.textoNormalRoboto.copyWith(
                      color: estaSeleccionada ? Colors.white : Colors.grey[300],
                      fontSize: 13,
                    ),
                  ),
                  value: estaSeleccionada,
                  activeColor: AppColors.verdePrimario,
                  checkColor: Colors.black,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (bool? value) {
                    _toggleCategoria(categoria);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Botón "Aplicar filtros" en negro puro, texto blanco y borde gris
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Colors.grey.withOpacity(0.4), // Borde gris sutil
                    width: 1,
                  ),
                ),
                elevation: 0,
              ),
              onPressed: () {
                widget.onAplicarFiltros(_seleccionadas);
                Navigator.pop(context);
              },
              child: Text(
                'Aplicar filtros',
                style: EstiloTexto.botonPrincipal.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}