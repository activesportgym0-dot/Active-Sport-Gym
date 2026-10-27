import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';

class ModalReglaHorario extends StatefulWidget {
  final Map<String, dynamic>? registroExistente;
  final Function(String tipo, String titulo, String contenido) onSave;

  const ModalReglaHorario({
    super.key,
    this.registroExistente,
    required this.onSave,
  });

  @override
  State<ModalReglaHorario> createState() => _ModalReglaHorarioState();
}

class _ModalReglaHorarioState extends State<ModalReglaHorario> {
  late String _tipoSeleccionado;
  late TextEditingController _tituloController;
  late TextEditingController _contenidoController;

  @override
  void initState() {
    super.initState();
    _tipoSeleccionado = widget.registroExistente?['tipo'] ?? 'Horario';
    _tituloController = TextEditingController(text: widget.registroExistente?['titulo'] ?? '');
    _contenidoController = TextEditingController(text: widget.registroExistente?['contenido'] ?? '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.fondoNegro,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.registroExistente == null ? 'CREAR NUEVO REGISTRO' : 'EDITAR REGISTRO',
            style: EstiloTexto.tituloBienvenida.copyWith(fontSize: 18, color: AppColors.verdePrimario),
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: _tipoSeleccionado,
            dropdownColor: AppColors.grisOscuro,
            style: EstiloTexto.textoNormalRoboto.copyWith(color: AppColors.blancoPuro),
            decoration: InputDecoration(
              labelText: 'Tipo de Registro',
              labelStyle: EstiloTexto.hintTexto,
              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.grisMedio)),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.verdePrimario)),
            ),
            items: ['Horario', 'Regla'].map((String tipo) {
              return DropdownMenuItem<String>(
                value: tipo,
                child: Text(tipo),
              );
            }).toList(),
            onChanged: (String? nuevoValor) {
              if (nuevoValor != null) {
                setState(() {
                  _tipoSeleccionado = nuevoValor;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tituloController,
            style: EstiloTexto.campoTexto,
            decoration: InputDecoration(
              labelText: 'Título (Ej: Lunes a Viernes / Norma 1)',
              labelStyle: EstiloTexto.hintTexto,
              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.grisMedio)),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.verdePrimario)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contenidoController,
            maxLines: 3,
            style: EstiloTexto.campoTexto,
            decoration: InputDecoration(
              labelText: 'Contenido / Descripción detallada',
              labelStyle: EstiloTexto.hintTexto,
              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.grisMedio)),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.verdePrimario)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdePrimario,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (_tituloController.text.trim().isEmpty || _contenidoController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Todos los campos son obligatorios'), backgroundColor: Colors.redAccent),
                  );
                  return;
                }
                widget.onSave(_tipoSeleccionado, _tituloController.text.trim(), _contenidoController.text.trim());
                Navigator.pop(context);
              },
              child: Text(
                widget.registroExistente == null ? 'GUARDAR REGISTRO' : 'ACTUALIZAR REGISTRO',
                style: EstiloTexto.botonPrincipal.copyWith(color: AppColors.fondoNegro, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}