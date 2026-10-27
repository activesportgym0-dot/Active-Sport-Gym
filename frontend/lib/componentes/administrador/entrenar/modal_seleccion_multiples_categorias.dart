import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class ModalSeleccionMultiplesCategorias extends StatefulWidget {
  final List<String> categoriasDisponibles;
  final List<String> categoriasSeleccionadasIniciales;
  final Function(List<String>) onCategoriasGuardadas;
  final String tituloModal;

  const ModalSeleccionMultiplesCategorias({
    super.key,
    required this.categoriasDisponibles,
    required this.categoriasSeleccionadasIniciales,
    required this.onCategoriasGuardadas,
    this.tituloModal = 'CATEGORÍAS',
  });

  @override
  State<ModalSeleccionMultiplesCategorias> createState() => _ModalSeleccionMultiplesCategoriasState();
}

class _ModalSeleccionMultiplesCategoriasState extends State<ModalSeleccionMultiplesCategorias> {
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
        if (_seleccionadas.length < 3) {
          _seleccionadas.add(categoria);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Máximo puedes seleccionar 3 categorías'),
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
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: BoxDecoration(
        color: AppColors.fondoNegro,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: AppColors.grisMedio.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.tituloModal,
                  style: EstiloTexto.enlaceNegritaRoboto.copyWith(
                    color: AppColors.blancoPuro,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
          Divider(color: AppColors.grisMedio.withOpacity(0.2), height: 1),
          const SizedBox(height: 10),
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
                      color: estaSeleccionada ? AppColors.blancoPuro : AppColors.grisMedio,
                      fontSize: 13,
                    ),
                  ),
                  value: estaSeleccionada,
                  activeColor: AppColors.verdePrimario,
                  checkColor: AppColors.fondoNegro,
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
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.fondoNegro,
                foregroundColor: AppColors.blancoPuro,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: AppColors.grisMedio.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                elevation: 0,
              ),
              onPressed: () {
                widget.onCategoriasGuardadas(_seleccionadas);
                Navigator.pop(context);
              },
              child: Text(
                'Confirmar categorías',
                style: EstiloTexto.botonPrincipal.copyWith(
                  color: AppColors.blancoPuro,
                  fontSize: 15,
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