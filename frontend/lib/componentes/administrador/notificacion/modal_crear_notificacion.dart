import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/estilotexto.dart';
class ModalCrearNotificacion extends StatefulWidget {
  final Function(Map<String, dynamic> nuevaNoti) onCrear;
  const ModalCrearNotificacion({super.key, required this.onCrear});
  @override
  State<ModalCrearNotificacion> createState() => _ModalCrearNotificacionState();
}
class _ModalCrearNotificacionState extends State<ModalCrearNotificacion> {
  final tituloController = TextEditingController();
  final mensajeController = TextEditingController();
  final idUsuarioController = TextEditingController();
  String tipoSeleccionado = 'stock';
  bool enviarATodos = true;
  String? errorMensaje;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENVIAR NUEVA NOTIFICACIÓN',
            style: EstiloTexto.tituloBienvenida.copyWith(fontSize: 18, color: AppColors.verdePrimario),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView(
              children: [
                TextField(
                  controller: tituloController,
                  style: EstiloTexto.campoTexto,
                  decoration: InputDecoration(
                    labelText: 'Título de la notificación',
                    labelStyle: EstiloTexto.hintTexto,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grisMedio.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.verdePrimario),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mensajeController,
                  maxLines: 3,
                  style: EstiloTexto.campoTexto,
                  decoration: InputDecoration(
                    labelText: 'Mensaje detallado',
                    labelStyle: EstiloTexto.hintTexto,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grisMedio.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.verdePrimario),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  dropdownColor: AppColors.grisOscuro,
                  style: EstiloTexto.campoTexto,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Notificación',
                    labelStyle: EstiloTexto.hintTexto,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grisMedio.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.verdePrimario),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'stock', child: Text('Stock')),
                    DropdownMenuItem(value: 'evento', child: Text('Evento')),
                    DropdownMenuItem(value: 'membresia', child: Text('Membresía')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        tipoSeleccionado = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Enviar a todos los clientes', style: EstiloTexto.textoNormalRoboto),
                  value: enviarATodos,
                  activeColor: AppColors.verdePrimario,
                  onChanged: (val) {
                    setState(() {
                      enviarATodos = val;
                    });
                  },
                ),
                if (!enviarATodos) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: idUsuarioController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: EstiloTexto.campoTexto,
                    decoration: InputDecoration(
                      labelText: 'ID del Usuario específico',
                      labelStyle: EstiloTexto.hintTexto,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.grisMedio.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.verdePrimario),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (errorMensaje != null) ...[
            Text(
              errorMensaje!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.verdePrimario),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCELAR', style: EstiloTexto.botonPrincipal.copyWith(fontSize: 14, color: AppColors.verdePrimario)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdePrimario,
                    foregroundColor: AppColors.fondoNegro,
                  ),
                  onPressed: () {
                    final titulo = tituloController.text.trim();
                    final mensaje = mensajeController.text.trim();

                    if (titulo.isEmpty || mensaje.isEmpty) {
                      setState(() => errorMensaje = 'El título y el mensaje son obligatorios.');
                      return;
                    }

                    int? idUsuario;
                    if (!enviarATodos) {
                      idUsuario = int.tryParse(idUsuarioController.text.trim());
                      if (idUsuario == null || idUsuario <= 0) {
                        setState(() => errorMensaje = 'Ingresa un ID de usuario válido.');
                        return;
                      }
                    }

                    // idUsuario null = notificación global para todos los clientes
                    widget.onCrear({
                      'titulo': titulo,
                      'mensaje': mensaje,
                      'tipo': tipoSeleccionado,
                      'id_usuario': idUsuario,
                    });
                    Navigator.pop(context);
                  },
                  child: Text('ENVIAR', style: EstiloTexto.botonPrincipal.copyWith(fontSize: 14, color: AppColors.fondoNegro)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
