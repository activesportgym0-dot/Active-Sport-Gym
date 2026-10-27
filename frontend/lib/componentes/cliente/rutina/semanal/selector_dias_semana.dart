import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class SelectorDiasSemana extends StatelessWidget {
  final String diaSeleccionado;
  final Function(String dia) onDiaSeleccionado;

  const SelectorDiasSemana({
    super.key,
    required this.diaSeleccionado,
    required this.onDiaSeleccionado,
  });

  final List<String> dias = const ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: dias.map((dia) {
        final bool seleccionado = diaSeleccionado == dia;
        return GestureDetector(
          onTap: () => onDiaSeleccionado(dia),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: seleccionado ? AppColors.verdePrimario : AppColors.grisOscuro,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: seleccionado ? AppColors.verdePrimario : Colors.grey.withOpacity(0.3),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              dia,
              style: EstiloTexto.nosiferDiasSemana.copyWith(
                color: seleccionado ? Colors.black : Colors.white,
                fontSize: dia.length > 1 ? 15 : 15, // Ajuste perfecto para 'Mi'
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}