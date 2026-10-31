import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
import 'package:frontend/models/regla_horario_model.dart'; // 👈 AJUSTA la carpeta si la tuya es distinta

class ModalReglaHorario extends StatefulWidget {
  final Map<String, dynamic>? registroExistente;

  /// Devuelve null si se guardó bien, o un texto con el error para mostrarlo en el modal.
  final Future<String?> Function(String tipo, String titulo, String contenido) onSave;

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

  bool _guardando = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    // Si en la base de datos hay un tipo distinto a Horario/Regla, el dropdown
    // se rompería; en ese caso arrancamos en 'Horario'.
    final tipoInicial = widget.registroExistente?['tipo'];
    _tipoSeleccionado = ReglaHorarioModel.tipos.contains(tipoInicial)
        ? tipoInicial as String
        : ReglaHorarioModel.tipoHorario;
    _tituloController = TextEditingController(text: widget.registroExistente?['titulo'] ?? '');
    _contenidoController = TextEditingController(text: widget.registroExistente?['contenido'] ?? '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final titulo = _tituloController.text.trim();
    final contenido = _contenidoController.text.trim();

    if (titulo.isEmpty || contenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _guardando = true;
      _errorMsg = null;
    });

    final error = await widget.onSave(_tipoSeleccionado, titulo, contenido);
    if (!mounted) return;

    if (error == null) {
      Navigator.pop(context);
    } else {
      setState(() {
        _guardando = false;
        _errorMsg = error;
      });
    }
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
            items: ReglaHorarioModel.tipos.map((String tipo) {
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
          // Solo aparece cuando el servidor devuelve un error (no altera el diseño normal)
          if (_errorMsg != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _errorMsg!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
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
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.fondoNegro),
                    )
                  : Text(
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